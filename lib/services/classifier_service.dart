import 'dart:io';

import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/services.dart' show rootBundle;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../models/food_prediction.dart';
import 'image_preprocessor.dart';

/// Model: AIY Vision Classifier - Food V1 (quantized MobileNetV1, 2024 class).
/// - Input : uint8 [1, 192, 192, 3], raw pixel value 0-255.
/// - Output: uint8 [1, 2024], probability got from `value / 256.0`
///   (scale=0.00390625, zero_point=0 in quantization parameter model).
class ClassifierService {
  static const _modelAsset = 'assets/models/food_classifier.tflite';
  static const _labelsAsset = 'assets/models/labels.txt';
  static const _numClasses = 2024;
  static const _outputScale = 1 / 256.0;

  Interpreter? _interpreter;
  IsolateInterpreter? _isolateInterpreter;
  List<String> _labels = const [];

  bool get isReady => _isolateInterpreter != null;

  Future<void> loadModel() async {
    if (isReady) return;

    final interpreter = await Interpreter.fromAsset(_modelAsset);
    _isolateInterpreter = await IsolateInterpreter.create(
      address: interpreter.address,
    );
    _interpreter = interpreter;

    final rawLabels = await rootBundle.loadString(_labelsAsset);
    _labels = rawLabels
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);
  }

  Future<FoodPrediction> classify(File imageFile) async {
    if (!isReady) {
      await loadModel();
    }

    final fileBytes = await imageFile.readAsBytes();
    final pixelBuffer = await compute(preprocessImageBytes, fileBytes);

    final input = pixelBuffer.reshape([1, kModelInputSize, kModelInputSize, 3]);
    final output = List.filled(_numClasses, 0).reshape([1, _numClasses]);

    await _isolateInterpreter!.run(input, output);

    final scores = (output[0] as List).cast<int>();
    var bestIndex = 0;
    var bestScore = 0;
    for (var i = 0; i < scores.length; i++) {
      if (scores[i] > bestScore) {
        bestScore = scores[i];
        bestIndex = i;
      }
    }

    final confidence = (bestScore * _outputScale).clamp(0.0, 1.0).toDouble();
    final label = bestIndex < _labels.length ? _labels[bestIndex] : 'Unknown';

    return FoodPrediction(
      image: imageFile,
      label: label,
      confidence: confidence,
    );
  }

  void dispose() {
    _isolateInterpreter?.close();
    _interpreter?.close();
    _isolateInterpreter = null;
    _interpreter = null;
  }
}
