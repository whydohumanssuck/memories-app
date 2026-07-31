import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/photo.dart';
import '../providers/device_media_provider.dart';
import '../providers/gallery_provider.dart';
import '../widgets/album_card.dart';
import '../widgets/device_media_grid.dart';
import '../widgets/photo_grid.dart';
import 'photo_detail_screen.dart';
import '../widgets/search_delegate.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _albumController = TextEditingController();

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

  void _showSearch(BuildContext context) {
    showSearch(
      context: context,
      delegate: PhotoSearchDelegate(),
    );
  }

  void _showAddPhoto(BuildContext context) async {
    final picker = Provider.of<GalleryProvider>(context, listen: false);
    final ImagePicker imagePicker = ImagePicker();

    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Photo'),
        content: const Text('Choose a source'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            child: const Text('Camera'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            child: const Text('Gallery'),
          ),
        ],
      ),
    );

    if (source == null) return;

    final XFile? pickedFile = await imagePicker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (pickedFile != null && context.mounted) {
      final album = picker.selectedAlbum;
      if (album != null) {
        picker.addPhotoFromFile(album.id, pickedFile);
      }
    }
  }

  void _showCreateAlbumDialog(BuildContext context) {
    _albumController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Album'),
          content: TextField(
            controller: _albumController,
            decoration: const InputDecoration(hintText: 'Album name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final title = _albumController.text.trim();
                if (title.isNotEmpty) {
                  Provider.of<GalleryProvider>(context, listen: false).createAlbum(title);
                  Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Consumer2<GalleryProvider, DeviceMediaProvider>(
      builder: (context, gallery, deviceMedia, child) {
        final currentAlbum = gallery.selectedAlbum;
        final photos = gallery.selectedPhotos;
        return SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                floating: true,
                backgroundColor: isDark ? Colors.transparent : Theme.of(context).colorScheme.surface.withOpacity(0.86),
                title: Text(
                  'Memories!',
                  style: TextStyle(color: isDark ? Colors.white : null),
                ),
                iconTheme: IconThemeData(color: isDark ? Colors.white : null),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    onPressed: () => _showAddPhoto(context),
                    tooltip: 'Add photo',
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => _showSearch(context),
                    tooltip: 'Search photos',
                  ),
                  IconButton(
                    icon: Icon(
                      gallery.showFavoritesOnly
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: gallery.showFavoritesOnly
                          ? Colors.red
                          : (isDark ? Colors.white : null),
                    ),
                    onPressed: () => gallery.toggleShowFavorites(),
                    tooltip: 'Favorites',
                  ),
                  IconButton(
                    icon: const Icon(Icons.create_new_folder_outlined),
                    onPressed: () => _showCreateAlbumDialog(context),
                    tooltip: 'New album',
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        '${gallery.totalPhotos} curated photos',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white60 : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const Spacer(),
                      if (gallery.favoriteCount > 0)
                        Text(
                          '${gallery.favoriteCount} favorites',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.red.shade300,
                          ),
                        ),
                    ],
                  ),
                ),
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
                        color: isDark ? const Color(0xFF1E1E24).withOpacity(0.6) : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.6),
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
                    height: 140,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: gallery.albums.length,
                      itemBuilder: (context, index) {
                        final album = gallery.albums[index];
                        return AlbumCard(
                          album: album,
                          isSelected: currentAlbum?.id == album.id,
                          onTap: () => gallery.selectAlbum(album.id),
                          onRename: () => _showRenameAlbumDialog(context, album.id, album.title),
                          onRemove: () => gallery.removeAlbum(album.id),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: PhotoGrid(
                  photos: photos,
                  onPhotoTap: (photo) => _openPhotoDetail(context, photo),
                  onFavoriteTap: (photo) {
                    Provider.of<GalleryProvider>(context, listen: false).toggleFavorite(photo.id);
                  },
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openPhotoDetail(BuildContext context, Photo photo) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: PhotoDetailScreen(photo: photo),
          );
        },
      ),
    );
  }

  void _showRenameAlbumDialog(BuildContext context, String albumId, String currentTitle) {
    _albumController.text = currentTitle;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename Album'),
          content: TextField(
            controller: _albumController,
            decoration: const InputDecoration(hintText: 'Album name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final title = _albumController.text.trim();
                if (title.isNotEmpty) {
                  Provider.of<GalleryProvider>(context, listen: false).renameAlbum(albumId, title);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
