import 'dart:async';

import 'package:flutter/material.dart';

import '../models/food_prediction.dart';
import 'result_screen.dart';

class AnalyzingScreen extends StatefulWidget {
  const AnalyzingScreen({
    super.key,
    required this.analyze,
  });

  final Future<FoodPrediction> Function() analyze;

  @override
  State<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends State<AnalyzingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  Timer? _stepTimer;

  int _currentStep = 0;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _startStepAnimation();
    _runAnalysis();
  }

  void _startStepAnimation() {
    _stepTimer = Timer.periodic(const Duration(milliseconds: 700), (timer) {
      if (!mounted) return;
      if (_currentStep < 2) {
        setState(() => _currentStep++);
      }
    });
  }

  Future<void> _runAnalysis() async {
    try {
      final result = await Future.wait<dynamic>([
        widget.analyze(),
        Future<void>.delayed(const Duration(milliseconds: 1800)),
      ]);

      if (!mounted) return;

      _stepTimer?.cancel();
      setState(() => _currentStep = 2);

      await Future<void>.delayed(const Duration(milliseconds: 250));
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            prediction: result[0] as FoodPrediction,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      _stepTimer?.cancel();
      setState(() {
        _hasError = true;
        _errorMessage = 'Failed to analyse picture.';
      });
    }
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF183B32);
    const primaryText = Color(0xFFF5F7F2);
    const secondaryText = Color(0xFFB7C8C2);
    const accent = Color(0xFFB9E5D9);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _BottomWavesPainter(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: primaryText,
                        size: 24,
                      ),
                    ),
                  ),
                  const Spacer(),
                  _buildScanner(accent),
                  const SizedBox(height: 32),
                  const Text(
                    'Analyzing your food...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: primaryText,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This may take a few seconds.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: secondaryText,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 34),
                  if (_hasError)
                    _buildErrorState(primaryText, secondaryText, accent)
                  else
                    _buildSteps(secondaryText, accent),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanner(Color accent) {
    return SizedBox(
      width: 138,
      height: 138,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.rotate(
            angle: _animationController.value * 6.28318,
            child: CustomPaint(
              painter: _ScannerPainter(),
              child: Center(
                child: Transform.rotate(
                  angle: -_animationController.value * 6.28318,
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.055),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                    child: Icon(
                      Icons.auto_awesome,
                      color: accent,
                      size: 31,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSteps(Color secondaryText, Color accent) {
    const labels = [
      'Identifying ingredients...',
      'Estimating nutrition...',
      'Finding recipe references...',
    ];

    return SizedBox(
      width: 225,
      child: Column(
        children: List.generate(labels.length, (index) {
          final active = index <= _currentStep;
          final current = index == _currentStep;

          return SizedBox(
            height: 34,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 25,
                  child: Column(
                    children: [
                      Container(
                        width: current ? 14 : 12,
                        height: current ? 14 : 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: active ? accent : const Color(0xFF78938B),
                          boxShadow: current
                              ? [
                                  BoxShadow(
                                    color: accent.withOpacity(0.35),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : null,
                        ),
                        child: current
                            ? Center(
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFEDF8F4),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      if (index < labels.length - 1)
                        Expanded(
                          child: Container(
                            width: 1.5,
                            color: index < _currentStep
                                ? const Color(0xFF789F96)
                                : const Color(0xFF55766E),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 7),
                Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: Text(
                    labels[index],
                    style: TextStyle(
                      color: active
                          ? const Color(0xFFE1EBE7)
                          : secondaryText.withOpacity(0.72),
                      fontSize: 12,
                      fontWeight: current ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildErrorState(
    Color primaryText,
    Color secondaryText,
    Color accent,
  ) {
    return Column(
      children: [
        Text(
          _errorMessage,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: secondaryText,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 46,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _hasError = false;
                _currentStep = 0;
              });
              _startStepAnimation();
              _runAnalysis();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: const Color(0xFF183B32),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text(
              'Try Again',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScannerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 10;

    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.white.withOpacity(0.10);

    canvas.drawCircle(center, radius, basePaint);

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFB9E5D9);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.0,
      1.55,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BottomWavesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    void drawWave(double y, double amplitude, Color color, double phase) {
      final path = Path()..moveTo(0, y);

      path.cubicTo(
        width * 0.18,
        y - amplitude,
        width * 0.33,
        y + amplitude,
        width * 0.52,
        y,
      );
      path.cubicTo(
        width * 0.70,
        y - amplitude,
        width * 0.86,
        y + amplitude,
        width,
        y - amplitude * 0.15,
      );
      path.lineTo(width, height);
      path.lineTo(0, height);
      path.close();

      final paint = Paint()..color = color;
      canvas.drawPath(path, paint);
    }

    drawWave(
      height - 105,
      26,
      const Color(0xFF315A50),
      0,
    );
    drawWave(
      height - 67,
      24,
      const Color(0xFF55766E),
      0,
    );
    drawWave(
      height - 31,
      19,
      const Color(0xFF78938B),
      0,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
