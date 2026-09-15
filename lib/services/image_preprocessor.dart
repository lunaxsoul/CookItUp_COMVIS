import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Input model food_classifier.tflite (AIY Food V1): 192x192 RGB uint8
const kModelInputSize = 192;

/// Top-level function isolate from UI thread.
Uint8List preprocessImageBytes(Uint8List fileBytes) {
  final decoded = img.decodeImage(fileBytes);
  if (decoded == null) {
    throw const FormatException('Failed to read image.');
  }

  final resized = img.copyResize(
    decoded,
    width: kModelInputSize,
    height: kModelInputSize,
    interpolation: img.Interpolation.linear,
  );

  final buffer = Uint8List(kModelInputSize * kModelInputSize * 3);
  var offset = 0;
  for (var y = 0; y < kModelInputSize; y++) {
    for (var x = 0; x < kModelInputSize; x++) {
      final pixel = resized.getPixel(x, y);
      buffer[offset++] = pixel.r.toInt();
      buffer[offset++] = pixel.g.toInt();
      buffer[offset++] = pixel.b.toInt();
    }
  }
  return buffer;
}
