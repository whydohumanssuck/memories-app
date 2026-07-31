import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/album.dart';
import '../models/photo.dart';
import '../providers/device_media_provider.dart';
import '../providers/gallery_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/album_card.dart';
import '../widgets/device_media_grid.dart';
import '../widgets/photo_grid.dart';
import 'photo_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _albumController = TextEditingController();
  final Set<String> _selectedPhotoIds = {};

  bool get _isSelecting => _selectedPhotoIds.isNotEmpty;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<DeviceMediaProvider>(context, listen: false).loadMedia();
      }
    });
  }

  @override
  void dispose() {
    _albumController.dispose();
    super.dispose();
  }

  Future<void> _createAlbum(BuildContext context) async {
    _albumController.clear();
    final result = await showDialog<String?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create New Album'),
          content: TextField(
            controller: _albumController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Album name'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(context, _albumController.text.trim()), child: const Text('Create')),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      Provider.of<GalleryProvider>(context, listen: false).createAlbum(result);
    }
  }

  Future<void> _renameAlbum(BuildContext context, String albumId, String currentTitle) async {
    _albumController.text = currentTitle;
    final result = await showDialog<String?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename Album'),
          content: TextField(
            controller: _albumController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Album name'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(context, _albumController.text.trim()), child: const Text('Save')),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      Provider.of<GalleryProvider>(context, listen: false).renameAlbum(albumId, result);
    }
  }

  Future<void> _pickImage(BuildContext context, String albumId) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (picked == null) return;
    final file = File(picked.path);
    final title = picked.path.split('/').last;
    final isSvg = picked.path.toLowerCase().endsWith('.svg');
    final photo = Photo(
      id: 'photo-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      albumId: albumId,
      uri: file.path,
      source: isSvg ? PhotoSource.svg : PhotoSource.local,
    );
    Provider.of<GalleryProvider>(context, listen: false).addPhoto(albumId, photo);
  }

  void _openPhotoDetail(BuildContext context, Photo photo, bool motionEnabled) {
    final page = PhotoDetailScreen(photo: photo);
    if (motionEnabled) {
      Navigator.of(context).push(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 450),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) {
            return FadeTransition(opacity: animation, child: page);
          },
        ),
      );
    } else {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Consumer2<GalleryProvider, DeviceMediaProvider>(
      builder: (context, gallery, deviceMedia, child) {
        final currentAlbum = gallery.selectedAlbum;
        final photos = gallery.selectedPhotos;

        return SafeArea(
          child: Stack(
            children: [
              CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                floating: true,
                expandedHeight: 120,
                backgroundColor: isDark
                    ? Colors.transparent
                    : Theme.of(context).colorScheme.surface.withOpacity(0.92),
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 16, bottom: 14),
                  title: Text(
                    'Memories!',
                    style: TextStyle(color: isDark ? Colors.white : null),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.photo_library_outlined),
                    tooltip: 'Add photo',
                    onPressed: currentAlbum == null
                        ? null
                        : () => _pickImage(context, currentAlbum.id),
                  ),
                  IconButton(
                    icon: const Icon(Icons.create_new_folder_outlined),
                    tooltip: 'Create album',
                    onPressed: () => _createAlbum(context),
                  ),
                ],
              ),
              // === DEVICE MEDIA SECTION ===
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Row(
                    children: [
                      Text(
                        'Your Photos & Videos',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : null,
                        ),
                      ),
                      const Spacer(),
                      if (deviceMedia.state == DeviceMediaState.loaded && deviceMedia.assets.isNotEmpty)
                        Text(
                          '${deviceMedia.assets.length}',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white60 : Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (deviceMedia.state == DeviceMediaState.idle ||
                  deviceMedia.state == DeviceMediaState.loading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
              if (deviceMedia.state == DeviceMediaState.denied)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E1E24).withOpacity(0.6)
                            : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.photo_library_outlined, color: isDark ? Colors.white70 : null),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Allow photo access',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : null,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Tap allow to see your photos and videos here.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.white60 : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                Provider.of<DeviceMediaProvider>(context, listen: false).loadMedia(),
                            child: const Text('Allow'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (deviceMedia.state == DeviceMediaState.loaded)
                DeviceMediaGrid(assets: deviceMedia.assets),
              // === ALBUMS SECTION ===
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                  child: Text(
                    'Albums',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : null,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    height: 160,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      scrollDirection: Axis.horizontal,
                      itemCount: gallery.albums.length,
                      itemBuilder: (context, index) {
                        final album = gallery.albums[index];
                        return AlbumCard(
                          album: album,
                          isSelected: currentAlbum?.id == album.id,
                          onTap: () => gallery.selectAlbum(album.id),
                          onRename: () => _renameAlbum(context, album.id, album.title),
                          onRemove: () => gallery.removeAlbum(album.id),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              if (photos.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 80),
                    child: Center(
                      child: Text(
                        currentAlbum == null
                            ? 'Create an album first, then tap the photo icon to add memories.'
                            : 'This album is empty. Add a photo to begin capturing memories.',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: PhotoGrid(
                    photos: photos,
                    onPhotoTap: _onPhotoTap,
                    onPhotoLongPress: _onPhotoLongPress,
                    selectedIds: _selectedPhotoIds,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
              if (_isSelecting)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E1E24).withOpacity(0.95)
                          : Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '${_selectedPhotoIds.length} selected',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : null,
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.photo_library_outlined),
                          tooltip: 'Add to album',
                          onPressed: _showAddToAlbumDialog,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          tooltip: 'Delete',
                          onPressed: _confirmDeleteSelected,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          tooltip: 'Clear selection',
                          onPressed: _clearSelection,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
