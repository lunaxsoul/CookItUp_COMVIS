import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraScreen extends StatefulWidget {
  final Future<String?> Function()? onPickFromGallery;

  const CameraScreen({Key? key, this.onPickFromGallery}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
  CameraController? _cameraController;
  late AnimationController _scanAnimationController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
    
    _scanAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0], // Usually the back camera
          ResolutionPreset.high,
          enableAudio: false,
        );

        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      debugPrint("Error initializing camera: $e");
    }
  }

  @override
  void dispose() {
    _scanAnimationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _cameraController;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  void _toggleFlash() async {
    if (_cameraController == null) return;
    try {
      _isFlashOn = !_isFlashOn;
      await _cameraController!.setFlashMode(
          _isFlashOn ? FlashMode.torch : FlashMode.off);
      setState(() {});
    } catch (e) {
      debugPrint("Error toggling flash: $e");
    }
  }

  Future<void> _takePicture() async {
    if (!_cameraController!.value.isInitialized) return;
    if (_cameraController!.value.isTakingPicture) return;

    try {
      XFile picture = await _cameraController!.takePicture();
      if (mounted) {
        Navigator.pop(context, picture.path);
      }
      debugPrint("Picture saved at: ${picture.path}");
    } catch (e) {
      debugPrint("Error taking picture: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized || _cameraController == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Color(0xFF4A7C59))),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Camera Preview (Full Screen)
          Positioned.fill(
            child: AspectRatio(
              aspectRatio: _cameraController!.value.aspectRatio,
              child: CameraPreview(_cameraController!),
            ),
          ),

          // 2. Dark Overlay & Target Frame
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _scanAnimationController,
              builder: (context, child) {
                return CustomPaint(
                  painter: ScannerOverlayPainter(
                    animationValue: _scanAnimationController.value,
                  ),
                );
              },
            ),
          ),

          // 3. Top App Bar Controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    "Food Scanner",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isFlashOn ? Icons.bolt : Icons.bolt_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: _toggleFlash,
                  ),
                ],
              ),
            ),
          ),

          // 4. Bottom Controls
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      "Center your food\nin the frame",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Gallery Button
                      GestureDetector(
                        onTap: () async {
                          if (widget.onPickFromGallery != null) {
                            String? path = await widget.onPickFromGallery!();
                            if (path != null && mounted) {
                              Navigator.pop(context, path);
                            }
                          }
                        },
                        child: const Column(
                          children: [
                            Icon(Icons.image_outlined, color: Colors.white, size: 28),
                            SizedBox(height: 8),
                            Text("Gallery", style: TextStyle(color: Colors.white, fontSize: 12)),
                          ],
                        ),
                      ),

                      // Capture Button
                      GestureDetector(
                        onTap: _takePicture,
                        child: Container(
                          height: 72,
                          width: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: Center(
                            child: Container(
                              height: 56,
                              width: 56,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Flash Toggle (Bottom)
                      GestureDetector(
                        onTap: _toggleFlash,
                        child: Column(
                          children: [
                            Icon(
                              _isFlashOn ? Icons.bolt : Icons.bolt_outlined,
                              color: Colors.white,
                              size: 28,
                            ),
                            const SizedBox(height: 8),
                            const Text("Flash", style: TextStyle(color: Colors.white, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for the target corners
class ScannerOverlayPainter extends CustomPainter {
  final double animationValue;

  ScannerOverlayPainter({this.animationValue = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate center square
    final double rectSize = size.width * 0.75;
    final double left = (size.width - rectSize) / 2;
    final double top = (size.height - rectSize) / 2 - 40; // Shifted slightly up
    final Rect scanRect = Rect.fromLTWH(left, top, rectSize, rectSize);

    // Semi-transparent dark overlay using Path difference to create a true transparent hole
    final bgPaint = Paint()..color = Colors.black.withOpacity(0.5);
    final fullPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final scanPath = Path()..addRect(scanRect);
    final combinedPath = Path.combine(PathOperation.difference, fullPath, scanPath);
    
    canvas.drawPath(combinedPath, bgPaint);

    // Draw the scanning bar with slight opacity
    final double scanLineY = scanRect.top + (scanRect.height * animationValue);
    
    // The gradient fade above the scanning line
    final double gradientHeight = 40.0;
    final Rect gradientRect = Rect.fromLTRB(
      scanRect.left, 
      (scanLineY - gradientHeight).clamp(scanRect.top, scanRect.bottom), 
      scanRect.right, 
      scanLineY
    );

    if (gradientRect.height > 0) {
      final gradientPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(0.0),
            Colors.white.withOpacity(0.3),
          ],
        ).createShader(gradientRect);
      canvas.drawRect(gradientRect, gradientPaint);
    }

    // The solid line itself
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 2.0;
    canvas.drawLine(
      Offset(scanRect.left, scanLineY),
      Offset(scanRect.right, scanLineY),
      linePaint,
    );

    // Draw the 4 corner brackets
    final cornerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    const double lineLength = 40.0;
    const double radius = 16.0;

    // Top Left
    canvas.drawPath(
      Path()
        ..moveTo(scanRect.left, scanRect.top + lineLength)
        ..lineTo(scanRect.left, scanRect.top + radius)
        ..quadraticBezierTo(scanRect.left, scanRect.top, scanRect.left + radius, scanRect.top)
        ..lineTo(scanRect.left + lineLength, scanRect.top),
      cornerPaint,
    );

    // Top Right
    canvas.drawPath(
      Path()
        ..moveTo(scanRect.right, scanRect.top + lineLength)
        ..lineTo(scanRect.right, scanRect.top + radius)
        ..quadraticBezierTo(scanRect.right, scanRect.top, scanRect.right - radius, scanRect.top)
        ..lineTo(scanRect.right - lineLength, scanRect.top),
      cornerPaint,
    );

    // Bottom Left
    canvas.drawPath(
      Path()
        ..moveTo(scanRect.left, scanRect.bottom - lineLength)
        ..lineTo(scanRect.left, scanRect.bottom - radius)
        ..quadraticBezierTo(scanRect.left, scanRect.bottom, scanRect.left + radius, scanRect.bottom)
        ..lineTo(scanRect.left + lineLength, scanRect.bottom),
      cornerPaint,
    );

    // Bottom Right
    canvas.drawPath(
      Path()
        ..moveTo(scanRect.right, scanRect.bottom - lineLength)
        ..lineTo(scanRect.right, scanRect.bottom - radius)
        ..quadraticBezierTo(scanRect.right, scanRect.bottom, scanRect.right - radius, scanRect.bottom)
        ..lineTo(scanRect.right - lineLength, scanRect.bottom),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant ScannerOverlayPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}