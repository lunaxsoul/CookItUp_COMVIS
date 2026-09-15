import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/classifier_service.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.classifier});

  final ClassifierService classifier;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _picker = ImagePicker();

  File? _selectedImage;
  bool _isClassifying = false;
  String? _errorMessage;

  Future<void> _pickImage(ImageSource source) async {
    setState(() => _errorMessage = null);

    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 90,
      );

      if (picked == null) return;

      final croppedPath = await Navigator.of(context).push<String>(
        MaterialPageRoute(
          builder: (_) => PhotoCropScreen(imagePath: picked.path),
          fullscreenDialog: true,
        ),
      );

      if (croppedPath == null) return;
      if (!mounted) return;

      setState(() {
        _selectedImage = File(croppedPath);
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Gagal mengambil gambar: $e';
      });
    }
  }

  Future<void> _analyzeImage() async {
    final image = _selectedImage;

    if (image == null) return;

    setState(() {
      _isClassifying = true;
      _errorMessage = null;
    });

    try {
      final prediction = await widget.classifier.classify(image);

      if (!mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            prediction: prediction,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Gagal menganalisis gambar: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isClassifying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F2),
      body: SafeArea(
        child: Stack(
          children: [
            _buildDecorations(),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 20, 28, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBackButton(),
                    const SizedBox(height: 38),
                    const Text(
                      'Choose a food photo',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF183B32),
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Select a clear photo of your meal\nfor better recognition.',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.45,
                        color: Color(0xFF78928B),
                      ),
                    ),
                    const SizedBox(height: 65),
                    Center(
                      child: GestureDetector(
                        onTap: _isClassifying
                            ? null
                            : () => _pickImage(ImageSource.camera),
                        child: _buildImageCircle(),
                      ),
                    ),
                    const SizedBox(height: 55),
                    if (_errorMessage != null) ...[
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Color(0xFFB23A3A),
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                    ],
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        onPressed: _isClassifying
                            ? null
                            : () => _pickImage(ImageSource.gallery),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF285F53),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'From Gallery',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    if (_selectedImage != null) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          onPressed: _isClassifying ? null : _analyzeImage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF183B32),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: _isClassifying
                              ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : const Text(
                            'Analyze',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: OutlinedButton(
                        onPressed: _isClassifying
                            ? null
                            : () {
                          if (_selectedImage != null) {
                            setState(() {
                              _selectedImage = null;
                              _errorMessage = null;
                            });
                          } else {
                            Navigator.of(context).maybePop();
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF285F53),
                          side: const BorderSide(
                            color: Color(0xFFAFC4BE),
                            width: 1.3,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCircle() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 190,
      height: 190,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFEEF1E7),
      ),
      child: _selectedImage == null
          ? const Center(
        child: Icon(
          Icons.image_outlined,
          size: 72,
          color: Color(0xFF285F53),
        ),
      )
          : ClipOval(
        child: Image.file(
          _selectedImage!,
          width: 190,
          height: 190,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return IconButton(
      onPressed: () => Navigator.of(context).maybePop(),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: 40,
        minHeight: 40,
      ),
      icon: const Icon(
        Icons.arrow_back,
        size: 27,
        color: Color(0xFF183B32),
      ),
    );
  }

  Widget _buildDecorations() {
    return IgnorePointer(
      child: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 18, bottom: 8),
          child: Opacity(
            opacity: 0.28,
            child: Icon(
              Icons.spa_outlined,
              size: 95,
              color: const Color(0xFFA8C3A0),
            ),
          ),
        ),
      ),
    );
  }
}

class PhotoCropScreen extends StatefulWidget {
  const PhotoCropScreen({
    super.key,
    required this.imagePath,
  });

  final String imagePath;

  @override
  State<PhotoCropScreen> createState() => _PhotoCropScreenState();
}

class _PhotoCropScreenState extends State<PhotoCropScreen> {
  ui.Image? _image;
  int _rotation = 0;
  String _selectedRatio = 'Original';
  Rect? _cropRect;
  Offset? _lastPanPosition;
  CropHandle? _activeHandle;
  bool _isSaving = false;

  final List<String> _ratios = [
    'Original',
    '1:1',
    '3:2',
    '4:3',
    '16:9',
  ];

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final bytes = await File(widget.imagePath).readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();

      if (!mounted) return;
      setState(() => _image = frame.image);
    } catch (_) {
      if (mounted) Navigator.of(context).pop();
    }
  }

  double? get _aspectRatio {
    switch (_selectedRatio) {
      case '1:1':
        return 1;
      case '3:2':
        return 3 / 2;
      case '4:3':
        return 4 / 3;
      case '16:9':
        return 16 / 9;
      default:
        return null;
    }
  }

  Size _rotatedImageSize() {
    final image = _image!;
    final odd = _rotation.isOdd;
    return Size(
      odd ? image.height.toDouble() : image.width.toDouble(),
      odd ? image.width.toDouble() : image.height.toDouble(),
    );
  }

  void _setRatio(String ratio) {
    setState(() {
      _selectedRatio = ratio;
      _cropRect = null;
    });
  }

  void _rotate() {
    setState(() {
      _rotation = (_rotation + 1) % 4;
      _cropRect = null;
    });
  }

  Rect _initialCropRect(Size size) {
    final ratio = _aspectRatio;
    if (ratio == null) {
      return Rect.fromLTWH(0, 0, size.width, size.height);
    }

    double width = size.width;
    double height = width / ratio;

    if (height > size.height) {
      height = size.height;
      width = height * ratio;
    }

    return Rect.fromLTWH(
      (size.width - width) / 2,
      (size.height - height) / 2,
      width,
      height,
    );
  }

  void _handlePanStart(DragStartDetails details) {
    if (_cropRect == null) return;

    final rect = _cropRect!;
    final p = details.localPosition;
    const hitSize = 36.0;

    if ((p - rect.topLeft).distance < hitSize) {
      _activeHandle = CropHandle.topLeft;
    } else if ((p - rect.topRight).distance < hitSize) {
      _activeHandle = CropHandle.topRight;
    } else if ((p - rect.bottomLeft).distance < hitSize) {
      _activeHandle = CropHandle.bottomLeft;
    } else if ((p - rect.bottomRight).distance < hitSize) {
      _activeHandle = CropHandle.bottomRight;
    } else if (rect.contains(p)) {
      _activeHandle = CropHandle.move;
    } else {
      _activeHandle = null;
    }

    _lastPanPosition = p;
  }

  void _handlePanUpdate(DragUpdateDetails details, Size imageSize) {
    if (_activeHandle == null ||
        _lastPanPosition == null ||
        _cropRect == null) {
      return;
    }

    final delta = details.localPosition - _lastPanPosition!;
    final oldRect = _cropRect!;
    Rect newRect;

    if (_activeHandle == CropHandle.move) {
      double left = oldRect.left + delta.dx;
      double top = oldRect.top + delta.dy;

      left = left.clamp(0.0, imageSize.width - oldRect.width).toDouble();
      top = top.clamp(0.0, imageSize.height - oldRect.height).toDouble();

      newRect = Rect.fromLTWH(
        left,
        top,
        oldRect.width,
        oldRect.height,
      );
    } else {
      newRect = _resizeRect(
        oldRect,
        delta,
        imageSize,
        _activeHandle!,
      );
    }

    setState(() {
      _cropRect = newRect;
      _lastPanPosition = details.localPosition;
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    _activeHandle = null;
    _lastPanPosition = null;
  }

  Rect _resizeRect(
      Rect rect,
      Offset delta,
      Size imageSize,
      CropHandle handle,
      ) {
    final ratio = _aspectRatio;

    if (ratio == null) {
      double left = rect.left;
      double top = rect.top;
      double right = rect.right;
      double bottom = rect.bottom;

      switch (handle) {
        case CropHandle.topLeft:
          left += delta.dx;
          top += delta.dy;
          break;
        case CropHandle.topRight:
          right += delta.dx;
          top += delta.dy;
          break;
        case CropHandle.bottomLeft:
          left += delta.dx;
          bottom += delta.dy;
          break;
        case CropHandle.bottomRight:
          right += delta.dx;
          bottom += delta.dy;
          break;
        case CropHandle.move:
          break;
      }

      const minSize = 60.0;
      left = left.clamp(0.0, right - minSize).toDouble();
      right = right.clamp(left + minSize, imageSize.width).toDouble();
      top = top.clamp(0.0, bottom - minSize).toDouble();
      bottom = bottom.clamp(top + minSize, imageSize.height).toDouble();

      return Rect.fromLTRB(left, top, right, bottom);
    }

    const minSize = 70.0;
    double width = rect.width;

    if (handle == CropHandle.topLeft || handle == CropHandle.bottomLeft) {
      width -= delta.dx;
    } else {
      width += delta.dx;
    }

    width = width.clamp(minSize, imageSize.width).toDouble();
    double height = width / ratio;

    if (height < minSize) {
      height = minSize;
      width = height * ratio;
    }

    double left = rect.left;
    double top = rect.top;

    switch (handle) {
      case CropHandle.topLeft:
        left = rect.right - width;
        top = rect.bottom - height;
        break;
      case CropHandle.topRight:
        top = rect.bottom - height;
        break;
      case CropHandle.bottomLeft:
        left = rect.right - width;
        break;
      case CropHandle.bottomRight:
      case CropHandle.move:
        break;
    }

    if (left < 0) left = 0;
    if (top < 0) top = 0;

    if (left + width > imageSize.width) {
      width = imageSize.width - left;
      height = width / ratio;
    }

    if (top + height > imageSize.height) {
      height = imageSize.height - top;
      width = height * ratio;
    }

    return Rect.fromLTWH(left, top, width, height);
  }

  Future<File> _createCroppedFile() async {
    final image = _image!;
    final rotatedSize = _rotatedImageSize();
    final crop = _cropRect!;

    final rotatedRecorder = ui.PictureRecorder();
    final rotatedCanvas = Canvas(rotatedRecorder);

    switch (_rotation) {
      case 1:
        rotatedCanvas.translate(
          rotatedSize.width,
          0,
        );
        rotatedCanvas.rotate(3.14159265359 / 2);
        break;
      case 2:
        rotatedCanvas.translate(
          rotatedSize.width,
          rotatedSize.height,
        );
        rotatedCanvas.rotate(3.14159265359);
        break;
      case 3:
        rotatedCanvas.translate(
          0,
          rotatedSize.height,
        );
        rotatedCanvas.rotate(3 * 3.14159265359 / 2);
        break;
    }

    rotatedCanvas.drawImage(
      image,
      Offset.zero,
      Paint()..filterQuality = FilterQuality.high,
    );

    final rotatedPicture = rotatedRecorder.endRecording();
    final rotatedImage = await rotatedPicture.toImage(
      rotatedSize.width.round(),
      rotatedSize.height.round(),
    );

    final displayScaleX = rotatedSize.width / _cropAreaSize.width;
    final displayScaleY = rotatedSize.height / _cropAreaSize.height;

    final cropX = crop.left * displayScaleX;
    final cropY = crop.top * displayScaleY;
    final cropWidth = crop.width * displayScaleX;
    final cropHeight = crop.height * displayScaleY;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawImageRect(
      rotatedImage,
      Rect.fromLTWH(cropX, cropY, cropWidth, cropHeight),
      Rect.fromLTWH(0, 0, cropWidth, cropHeight),
      Paint()..filterQuality = FilterQuality.high,
    );

    final picture = recorder.endRecording();
    final output = await picture.toImage(
      cropWidth.round().clamp(1, 10000),
      cropHeight.round().clamp(1, 10000),
    );

    final byteData = await output.toByteData(
      format: ui.ImageByteFormat.png,
    );

    if (byteData == null) {
      throw Exception('Unable to encode cropped image.');
    }

    final Uint8List bytes = byteData.buffer.asUint8List();
    final file = File(
      '${Directory.systemTemp.path}/food_crop_${DateTime.now().millisecondsSinceEpoch}.png',
    );

    await file.writeAsBytes(bytes);
    return file;
  }

  Size get _cropAreaSize => _cropAreaSizeValue;
  Size _cropAreaSizeValue = Size.zero;

  Future<void> _confirmCrop() async {
    if (_image == null || _cropRect == null || _cropAreaSize.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      final file = await _createCroppedFile();

      if (!mounted) return;
      Navigator.of(context).pop(file.path);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to crop this image.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F2),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(child: _buildCropArea()),
            _buildAspectRatioSelector(),
            _buildBottomControls(),
            const SizedBox(height: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                icon: const Icon(
                  Icons.close,
                  size: 27,
                  color: Color(0xFF183B32),
                ),
              ),
              IconButton(
                onPressed: _isSaving ? null : _confirmCrop,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                icon: _isSaving
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF285F53),
                  ),
                )
                    : const Icon(
                  Icons.check,
                  size: 29,
                  color: Color(0xFF183B32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Adjust your photo',
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w700,
              color: Color(0xFF183B32),
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Crop the food for better results.',
            style: TextStyle(
              fontSize: 15.5,
              color: Color(0xFF78928B),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (_image == null) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF285F53)),
          );
        }

        final imageSize = _rotatedImageSize();
        final maxWidth = constraints.maxWidth - 56;
        final maxHeight = constraints.maxHeight - 18;

        double scale = maxWidth / imageSize.width;
        final heightScale = maxHeight / imageSize.height;
        if (scale > heightScale) scale = heightScale;

        final displaySize = Size(
          imageSize.width * scale,
          imageSize.height * scale,
        );

        _cropAreaSizeValue = displaySize;

        if (_cropRect == null ||
            _cropRect!.right > displaySize.width ||
            _cropRect!.bottom > displaySize.height) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() => _cropRect = _initialCropRect(displaySize));
          });
        }

        return Center(
          child: GestureDetector(
            onPanStart: _handlePanStart,
            onPanUpdate: (details) =>
                _handlePanUpdate(details, displaySize),
            onPanEnd: _handlePanEnd,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(
                width: displaySize.width,
                height: displaySize.height,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: RotatedImagePainter(
                          image: _image!,
                          rotation: _rotation,
                        ),
                      ),
                    ),
                    if (_cropRect != null)
                      Positioned.fill(
                        child: CustomPaint(
                          painter: CropOverlayPainter(
                            cropRect: _cropRect!,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAspectRatioSelector() {
    return SizedBox(
      height: 58,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 28),
        itemCount: _ratios.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final ratio = _ratios[index];
          final selected = ratio == _selectedRatio;

          return GestureDetector(
            onTap: () => _setRatio(ratio),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: ratio == 'Original' ? 84 : 68,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF285F53)
                    : const Color(0xFFF4F3EF),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF285F53)
                      : const Color(0xFFE4E4DF),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                ratio,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? Colors.white
                      : const Color(0xFF355B54),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.only(top: 28, left: 60, right: 60),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildBottomAction(
            icon: Icons.rotate_left,
            label: 'Rotate',
            onTap: _isSaving ? null : _rotate,
          ),
          _buildBottomAction(
            icon: Icons.crop,
            label: 'Crop',
            onTap: _isSaving ? null : _confirmCrop,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 80,
        child: Column(
          children: [
            Icon(
              icon,
              size: 30,
              color: const Color(0xFF285F53),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF49645E),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RotatedImagePainter extends CustomPainter {
  RotatedImagePainter({
    required this.image,
    required this.rotation,
  });

  final ui.Image image;
  final int rotation;

  @override
  void paint(Canvas canvas, Size size) {
    final sourceWidth = image.width.toDouble();
    final sourceHeight = image.height.toDouble();
    final odd = rotation.isOdd;

    final logicalWidth = odd ? sourceHeight : sourceWidth;
    final logicalHeight = odd ? sourceWidth : sourceHeight;

    final double scale = (size.width / logicalWidth)
        .clamp(0.0, size.height / logicalHeight)
        .toDouble();

    final drawWidth = logicalWidth * scale;
    final drawHeight = logicalHeight * scale;
    final dx = (size.width - drawWidth) / 2;
    final dy = (size.height - drawHeight) / 2;

    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(scale);

    switch (rotation) {
      case 1:
        canvas.translate(logicalWidth, 0);
        canvas.rotate(3.14159265359 / 2);
        break;
      case 2:
        canvas.translate(logicalWidth, logicalHeight);
        canvas.rotate(3.14159265359);
        break;
      case 3:
        canvas.translate(0, logicalHeight);
        canvas.rotate(3 * 3.14159265359 / 2);
        break;
    }

    canvas.drawImage(
      image,
      Offset.zero,
      Paint()..filterQuality = FilterQuality.high,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant RotatedImagePainter oldDelegate) {
    return oldDelegate.image != image ||
        oldDelegate.rotation != rotation;
  }
}

class CropOverlayPainter extends CustomPainter {
  CropOverlayPainter({required this.cropRect});

  final Rect cropRect;

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.30);

    final fullPath = Path()..addRect(Offset.zero & size);
    final cropPath = Path()..addRect(cropRect);
    final combined = Path.combine(
      PathOperation.difference,
      fullPath,
      cropPath,
    );

    canvas.drawPath(combined, overlayPaint);

    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.55)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final thirdWidth = cropRect.width / 3;
    final thirdHeight = cropRect.height / 3;

    for (int i = 1; i < 3; i++) {
      final x = cropRect.left + thirdWidth * i;
      canvas.drawLine(
        Offset(x, cropRect.top),
        Offset(x, cropRect.bottom),
        gridPaint,
      );
    }

    for (int i = 1; i < 3; i++) {
      final y = cropRect.top + thirdHeight * i;
      canvas.drawLine(
        Offset(cropRect.left, y),
        Offset(cropRect.right, y),
        gridPaint,
      );
    }

    final borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    canvas.drawRect(cropRect, borderPaint);

    _drawCorner(canvas, cropRect.topLeft, Corner.topLeft);
    _drawCorner(canvas, cropRect.topRight, Corner.topRight);
    _drawCorner(canvas, cropRect.bottomLeft, Corner.bottomLeft);
    _drawCorner(canvas, cropRect.bottomRight, Corner.bottomRight);
  }

  void _drawCorner(Canvas canvas, Offset point, Corner corner) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;

    const length = 18.0;

    switch (corner) {
      case Corner.topLeft:
        canvas.drawLine(point, point.translate(length, 0), paint);
        canvas.drawLine(point, point.translate(0, length), paint);
        break;
      case Corner.topRight:
        canvas.drawLine(point, point.translate(-length, 0), paint);
        canvas.drawLine(point, point.translate(0, length), paint);
        break;
      case Corner.bottomLeft:
        canvas.drawLine(point, point.translate(length, 0), paint);
        canvas.drawLine(point, point.translate(0, -length), paint);
        break;
      case Corner.bottomRight:
        canvas.drawLine(point, point.translate(-length, 0), paint);
        canvas.drawLine(point, point.translate(0, -length), paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CropOverlayPainter oldDelegate) {
    return oldDelegate.cropRect != cropRect;
  }
}

enum CropHandle {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  move,
}

enum Corner {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}