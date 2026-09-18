import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

class CameraScreen extends StatefulWidget {
  final Future<String?> Function()? onPickFromGallery;

  const CameraScreen({Key? key, this.onPickFromGallery}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  double _currentZoomLevel = 1.0;
  double _minZoomLevel = 1.0;
  double _maxZoomLevel = 1.0;
  bool _isCameraInitialized = false;
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
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
        _minZoomLevel = await _cameraController!.getMinZoomLevel();
        _maxZoomLevel = await _cameraController!.getMaxZoomLevel();
        _currentZoomLevel = _minZoomLevel;

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

  void _toggleZoom() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    try {
      // Toggle between 1x and 2x (or max if max is less than 2)
      double nextZoom = _currentZoomLevel == _minZoomLevel 
          ? (_maxZoomLevel >= 2.0 ? 2.0 : _maxZoomLevel) 
          : _minZoomLevel;
      await _cameraController!.setZoomLevel(nextZoom);
      setState(() {
        _currentZoomLevel = nextZoom;
      });
    } catch (e) {
      debugPrint("Error toggling zoom: $e");
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
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xFF4A7C59))),
      );

      XFile picture = await _cameraController!.takePicture();
      
      final croppedPath = await _cropToFrame(picture.path);

      if (mounted) {
        Navigator.pop(context); // pop the loading dialog
        Navigator.pop(context, croppedPath); // pop the camera screen with image
      }
      debugPrint("Picture saved and cropped at: $croppedPath");
    } catch (e) {
      if (mounted) Navigator.pop(context); // close dialog on error
      debugPrint("Error taking picture: $e");
    }
  }

  Future<String> _cropToFrame(String imagePath) async {
    final size = MediaQuery.of(context).size;
    final double rectSize = size.width * 0.75;
    final double left = (size.width - rectSize) / 2;
    final double top = (size.height - rectSize) / 2 - 40;

    final Map<String, dynamic> cropParams = {
      'path': imagePath,
      'screenWidth': size.width,
      'screenHeight': size.height,
      'rectLeft': left,
      'rectTop': top,
      'rectSize': rectSize,
    };

    // Run cropping in background isolate to prevent UI freeze
    return await compute(_processCrop, cropParams);
  }

  static String _processCrop(Map<String, dynamic> params) {
    final String path = params['path'];
    final double screenWidth = params['screenWidth'];
    final double screenHeight = params['screenHeight'];
    final double rectLeft = params['rectLeft'];
    final double rectTop = params['rectTop'];
    final double rectSize = params['rectSize'];

    final bytes = File(path).readAsBytesSync();
    img.Image? originalImage = img.decodeImage(bytes);
    if (originalImage == null) return path;

    // Ensure the image is oriented correctly before math
    originalImage = img.bakeOrientation(originalImage);

    final int imgWidth = originalImage.width;
    final int imgHeight = originalImage.height;

    // Calculate BoxFit.cover math to find exact pixel match
    double scaleX = screenWidth / imgWidth;
    double scaleY = screenHeight / imgHeight;
    double scale = scaleX > scaleY ? scaleX : scaleY; // BoxFit.cover uses max scale

    double displayedImgWidth = imgWidth * scale;
    double displayedImgHeight = imgHeight * scale;

    double offsetX = (displayedImgWidth - screenWidth) / 2;
    double offsetY = (displayedImgHeight - screenHeight) / 2;

    int cropLeft = ((rectLeft + offsetX) / scale).round();
    int cropTop = ((rectTop + offsetY) / scale).round();
    int cropSize = (rectSize / scale).round();

    // Prevent out of bounds
    cropLeft = cropLeft.clamp(0, imgWidth - cropSize);
    cropTop = cropTop.clamp(0, imgHeight - cropSize);

    img.Image cropped = img.copyCrop(
      originalImage,
      x: cropLeft,
      y: cropTop,
      width: cropSize,
      height: cropSize,
    );

    final croppedBytes = img.encodeJpg(cropped, quality: 90);
    final croppedFile = File('${Directory.systemTemp.path}/food_scan_${DateTime.now().millisecondsSinceEpoch}.jpg');
    croppedFile.writeAsBytesSync(croppedBytes);

    return croppedFile.path;
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
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: 100,
                // In portrait mode, the camera's aspect ratio is inverted (e.g. 9:16 instead of 16:9).
                // So the height should be width * aspectRatio.
                height: 100 * _cameraController!.value.aspectRatio,
                child: CameraPreview(_cameraController!),
              ),
            ),
          ),

          // 2. Dark Overlay & Target Frame
          Positioned.fill(
            child: CustomPaint(
              painter: ScannerOverlayPainter(),
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

                      // Zoom Toggle (Bottom)
                      GestureDetector(
                        onTap: _toggleZoom,
                        child: Column(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _currentZoomLevel == _minZoomLevel ? "1x" : "2x",
                                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text("Zoom", style: TextStyle(color: Colors.white, fontSize: 12)),
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}