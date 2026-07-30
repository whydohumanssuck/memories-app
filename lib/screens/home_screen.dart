import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/photo.dart';
import '../providers/gallery_provider.dart';
import '../widgets/album_card.dart';
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
    // Use image_picker to add photos from device
    final picker = Provider.of<GalleryProvider>(context, listen: false);
    final ImagePicker imagePicker = ImagePicker();
    
    // Show dialog to choose camera or gallery
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
    return Consumer<GalleryProvider>(
      builder: (context, gallery, child) {
        final currentAlbum = gallery.selectedAlbum;
        final photos = gallery.selectedPhotos;
        return SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                floating: true,
                backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.86),
                title: const Text('Memories!'),
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
                          : null,
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
                        '${gallery.totalPhotos} photos',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        currentAlbum?.title ?? 'No Album',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
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
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
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
        transitionDuration: const Duration(milliseconds: 550),
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
