import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

/// Screen #4: Gallery (Integrated)
/// Displays an in-app gallery reading directly from device storage.
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({
    super.key,
    this.allowMultiple = true,
  });

  final bool allowMultiple;

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  int _selectedTabIndex = 0; // 0: Photos, 1: Collections
  
  // Storage for our assets from photo_manager
  List<AssetEntity> _assets = [];
  List<AssetPathEntity> _albums = [];
  AssetPathEntity? _selectedAlbum;
  
  final Set<AssetEntity> _selectedAssets = {};
  
  bool _isLoading = true;
  bool _hasPermission = false;

  static const Color _forestGreen = Color(0xFF1B4332);
  static const Color _mutedGreen = Color(0xFF6B8F71);
  static const Color _softSage = Color(0xFFCFDCC6);
  static const Color _ivoryBackground = Color(0xFFF8F7F2);

  @override
  void initState() {
    super.initState();
    _requestPermissionAndLoadPhotos();
  }

  Future<void> _requestPermissionAndLoadPhotos() async {
    // Determine the permission state
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    
    if (ps.isAuth || ps == PermissionState.limited) {
      // Permission granted! Load photos.
      if (mounted) {
        setState(() => _hasPermission = true);
        await _fetchAlbumsAndPhotos();
      }
    } else {
      // Permission denied
      if (mounted) {
        setState(() {
          _hasPermission = false;
          _isLoading = false;
        });
      }
    }
  }

  void _openSettings() {
    PhotoManager.openSetting();
  }

  Future<void> _fetchAlbumsAndPhotos() async {
    // Fetch all albums (folders) containing images
    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
      type: RequestType.image,
    );

    if (paths.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _albums = paths;
      _selectedAlbum = paths.first; // Usually "Recent" or "All"
    });

    await _loadPhotosFromAlbum(_selectedAlbum!);
  }

  Future<void> _loadPhotosFromAlbum(AssetPathEntity album) async {
    setState(() => _isLoading = true);
    
    // Fetch latest 100 photos from the selected album
    final List<AssetEntity> entities = await album.getAssetListPaged(
      page: 0,
      size: 100, // adjust this to load more or less
    );

    setState(() {
      _assets = entities;
      _isLoading = false;
    });
  }

  Future<void> _toggleSelection(AssetEntity asset) async {
    if (!widget.allowMultiple) {
      // Immediately pick and return the photo
      showDialog(
        context: context, 
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator(color: _forestGreen)),
      );
      
      final File? file = await asset.file;
      
      if (!mounted) return;
      Navigator.of(context).pop(); // dismiss loading dialog
      
      if (file != null) {
        Navigator.of(context).pop(file.path);
      }
      return;
    }

    setState(() {
      if (_selectedAssets.contains(asset)) {
        _selectedAssets.remove(asset);
      } else {
        _selectedAssets.add(asset);
      }
    });
  }

  Future<void> _confirmSelection() async {
    if (_selectedAssets.isEmpty) return;

    // Convert AssetEntity back to actual File paths for the rest of the app
    final List<String> selectedPaths = [];
    
    // Show a quick loading indicator if processing many files
    showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: _forestGreen)),
    );

    for (var asset in _selectedAssets) {
      final File? file = await asset.file; // This extracts the actual local File path
      if (file != null) {
        selectedPaths.add(file.path);
      }
    }
    
    if (!mounted) return;
    Navigator.of(context).pop(); // pop loading dialog

    if (selectedPaths.isEmpty || !mounted) return;

    if (selectedPaths.length == 1) {
      Navigator.of(context).pop(selectedPaths.first);
    } else {
      Navigator.of(context).pop(selectedPaths);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Scaffold(
        backgroundColor: _ivoryBackground,
        body: Column(
          children: [
            const SizedBox(height: 10),
            // Drag Handle Bar at Top
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Top Header: Tabs (Photos | Collections)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: _softSage.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTabPill('Photos', 0),
                        _buildTabPill('Albums', 1),
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Body Content
            Expanded(
              child: _buildBody(),
            ),

            // Bottom Confirm Floating Bar
            if (_selectedAssets.isNotEmpty && _assets.isNotEmpty)
              _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBody() {
    if (!_hasPermission) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.no_photography_outlined, size: 64, color: _mutedGreen),
              const SizedBox(height: 16),
              const Text('Gallery Access Required',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _forestGreen),
              ),
              const SizedBox(height: 8),
              const Text('Please allow access to your photos to use the integrated gallery.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _mutedGreen),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _requestPermissionAndLoadPhotos,
                style: FilledButton.styleFrom(backgroundColor: _forestGreen),
                child: const Text('Request Permission'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _openSettings,
                child: const Text(
                  'Open System Settings',
                  style: TextStyle(color: _forestGreen),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: _forestGreen),
      );
    }
    
    if (_selectedTabIndex == 0) {
      return _buildPhotosGrid();
    } else {
      return _buildCollectionsView();
    }
  }

  Widget _buildTabPill(String label, int index) {
    final bool isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _forestGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : _forestGreen,
          ),
        ),
      ),
    );
  }

  Widget _buildPhotosGrid() {
    if (_assets.isEmpty) {
      return const Center(
        child: Text('No photos found on this device', style: TextStyle(color: _mutedGreen)),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.0,
      ),
      itemCount: _assets.length,
      itemBuilder: (context, index) {
        final asset = _assets[index];
        final bool isSelected = _selectedAssets.contains(asset);

        return GestureDetector(
          onTap: () => _toggleSelection(asset),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Photo Thumbnail (Loaded efficiently via photo_manager)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AssetThumbnail(asset: asset),
              ),

              // Selection Border & Dark Tint Overlay
              if (isSelected)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _forestGreen,
                      width: 3,
                    ),
                  ),
                ),

              // Green Circular Checkmark Overlay Badge
              if (isSelected)
                Center(
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _forestGreen,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),

              // Selection Number Badge in Top-Right
              if (isSelected && _selectedAssets.length > 1)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: _forestGreen,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${_selectedAssets.toList().indexOf(asset) + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomActionBar() {
    final count = _selectedAssets.length;
    final selectedList = _selectedAssets.toList();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Preview Thumbnails Overlap Stack
            SizedBox(
              height: 44,
              width: selectedList.length > 1 ? 70 : 44,
              child: Stack(
                children: [
                  for (int i = 0; i < selectedList.length.clamp(0, 3); i++)
                    Positioned(
                      left: i * 16.0,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: SizedBox(
                            width: 40,
                            height: 40,
                            child: AssetThumbnail(asset: selectedList[i], boxFit: BoxFit.cover),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                count == 1 ? '1 Photo Selected' : '$count Photos Selected',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _forestGreen,
                ),
              ),
            ),
            FilledButton(
              onPressed: _confirmSelection,
              style: FilledButton.styleFrom(
                backgroundColor: _forestGreen,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
              ),
              child: Text(
                count == 1 ? 'Choose Photo' : 'Choose $count Photos',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectionsView() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: _albums.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final album = _albums[index];
        final bool isSelected = _selectedAlbum == album;

        return InkWell(
          onTap: () {
            setState(() {
              _selectedAlbum = album;
              _selectedTabIndex = 0; // Switch back to Photos grid
            });
            _loadPhotosFromAlbum(album);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? _forestGreen : _softSage.withValues(alpha: 0.5),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _softSage.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.photo_album,
                    color: _forestGreen,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        album.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _forestGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      FutureBuilder<int>(
                        future: album.assetCountAsync,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              '${snapshot.data} items',
                              style: const TextStyle(
                                fontSize: 13,
                                color: _mutedGreen,
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: _forestGreen,
                  )
                else
                  const Icon(
                    Icons.chevron_right,
                    color: _mutedGreen,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Helper Widget to load an AssetEntity thumbnail efficiently with state caching
class AssetThumbnail extends StatefulWidget {
  const AssetThumbnail({
    super.key,
    required this.asset,
    this.boxFit = BoxFit.cover,
  });

  final AssetEntity asset;
  final BoxFit boxFit;

  @override
  State<AssetThumbnail> createState() => _AssetThumbnailState();
}

class _AssetThumbnailState extends State<AssetThumbnail> {
  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    _loadBytes();
  }

  @override
  void didUpdateWidget(covariant AssetThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.asset.id != widget.asset.id) {
      _loadBytes();
    }
  }

  Future<void> _loadBytes() async {
    final bytes = await widget.asset.thumbnailDataWithSize(const ThumbnailSize.square(300));
    if (mounted) {
      setState(() {
        _bytes = bytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_bytes == null) {
      return Container(
        color: Colors.grey.shade200,
        child: const Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF1B4332),
            ),
          ),
        ),
      );
    }
    return Image.memory(
      _bytes!,
      fit: widget.boxFit,
      errorBuilder: (_, __, ___) => Container(
        color: Colors.grey.shade200,
        child: const Icon(Icons.broken_image, color: Colors.grey),
      ),
    );
  }
}
