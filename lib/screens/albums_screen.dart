import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/album.dart';
import '../models/photo.dart';
import '../providers/gallery_provider.dart';

class AlbumsScreen extends StatefulWidget {
  const AlbumsScreen({super.key});

  @override
  State<AlbumsScreen> createState() => _AlbumsScreenState();
}

class _AlbumsScreenState extends State<AlbumsScreen> {
  final TextEditingController _albumController = TextEditingController();

  @override
  void dispose() {
    _albumController.dispose();
    super.dispose();
  }

  Future<void> _openCreateAlbumDialog(BuildContext context) async {
    _albumController.clear();
    final name = await showDialog<String?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New album'),
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

    if (name != null && name.isNotEmpty) {
      Provider.of<GalleryProvider>(context, listen: false).createAlbum(name);
    }
  }

  Future<void> _openRenameAlbumDialog(BuildContext context, Album album) async {
    _albumController.text = album.title;
    final name = await showDialog<String?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename album'),
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

    if (name != null && name.isNotEmpty) {
      Provider.of<GalleryProvider>(context, listen: false).renameAlbum(album.id, name);
    }
  }

  Future<void> _openAddPhotoDialog(BuildContext context, Album album) async {
    final picker = ImagePicker();
    List<XFile> picked = <XFile>[];
    try {
      picked = await picker.pickMultiImage(imageQuality: 90);
    } catch (_) {
      // ignore picker errors
    }
    if (picked.isEmpty) return;

    final gallery = Provider.of<GalleryProvider>(context, listen: false);
    for (final p in picked) {
      final file = File(p.path);
      final isSvg = p.path.toLowerCase().endsWith('.svg');
      gallery.addPhoto(
        album.id,
        Photo(
          id: 'photo-${DateTime.now().microsecondsSinceEpoch}-${p.path.hashCode}',
          title: p.path.split('/').last,
          albumId: album.id,
          uri: file.path,
          source: isSvg ? PhotoSource.svg : PhotoSource.local,
        ),
      );
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added ${picked.length} photo(s) to ${album.title}')),
      );
    }
  }

  Future<void> _openChangeCoverDialog(BuildContext context, Album album) async {
    final gallery = Provider.of<GalleryProvider>(context, listen: false);
    final albumPhotos = gallery.photosForAlbum(album.id);
    if (albumPhotos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No photos in this album yet. Add photos first.')),
      );
      return;
    }
    final Photo? chosen = await showDialog<Photo>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choose album cover'),
          content: SizedBox(
            width: double.maxFinite,
            height: 340,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemCount: albumPhotos.length,
              itemBuilder: (context, index) {
                final photo = albumPhotos[index];
                return GestureDetector(
                  onTap: () => Navigator.pop(context, photo),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildImagePreview(photo),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
    if (chosen == null) return;
    gallery.changeAlbumCover(album.id, chosen.id);
  }

  Widget _buildImagePreview(Photo? photo) {
    if (photo == null) {
      return Container(
        color: Colors.grey.shade800,
        child: const Center(child: Icon(Icons.photo, color: Colors.white38, size: 28)),
      );
    }

    if (photo.isSvg) {
      return photo.isLocal
          ? SvgPicture.file(File(photo.uri), fit: BoxFit.cover)
          : SvgPicture.network(photo.uri, fit: BoxFit.cover);
    }
    if (photo.isLocal) {
      return Image.file(
        File(photo.uri),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.grey.shade800,
          child: const Icon(Icons.broken_image, color: Colors.white54),
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: photo.uri,
      fit: BoxFit.cover,
      memCacheWidth: 600,
      errorWidget: (_, __, ___) => Container(
        color: Colors.grey.shade800,
        child: const Icon(Icons.broken_image, color: Colors.white54),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Consumer<GalleryProvider>(
      builder: (context, gallery, child) {
        final selectedAlbum = gallery.selectedAlbum;
        return SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                floating: true,
                expandedHeight: 110,
                backgroundColor: isDark
                    ? Colors.transparent
                    : Theme.of(context).colorScheme.surface.withOpacity(0.94),
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 16, bottom: 14),
                  title: Text('Albums', style: TextStyle(color: isDark ? Colors.white : null)),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _openCreateAlbumDialog(context),
                    tooltip: 'Create album',
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final album = gallery.albums[index];
                      final coverPhoto = album.coverPhotoId.isEmpty ? null : gallery.findPhotoById(album.coverPhotoId);
                      final albumPhotos = gallery.photosForAlbum(album.id);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E1E24).withOpacity(0.85)
                                : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.92),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.08),
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 170,
                                width: double.infinity,
                                child: _buildImagePreview(coverPhoto),
                              ),
                              ListTile(
                                title: Text(
                                  album.title,
                                  style: TextStyle(color: isDark ? Colors.white : null),
                                ),
                                subtitle: Text(
                                  '${albumPhotos.length} photos',
                                  style: TextStyle(color: isDark ? Colors.white60 : null),
                                ),
                                trailing: PopupMenuButton<String>(
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(value: 'addphoto', child: Text('Add photo')),
                                    const PopupMenuItem(value: 'cover', child: Text('Change album cover')),
                                    const PopupMenuItem(value: 'rename', child: Text('Rename')),
                                    const PopupMenuItem(value: 'remove', child: Text('Delete')),
                                  ],
                                  onSelected: (value) {
                                    switch (value) {
                                      case 'addphoto':
                                        _openAddPhotoDialog(context, album);
                                        break;
                                      case 'cover':
                                        _openChangeCoverDialog(context, album);
                                        break;
                                      case 'rename':
                                        _openRenameAlbumDialog(context, album);
                                        break;
                                      case 'remove':
                                        gallery.removeAlbum(album.id);
                                        break;
                                    }
                                  },
                                ),
                              ),
                              if (selectedAlbum?.id == album.id && albumPhotos.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Set cover from this album',
                                        style: TextStyle(
                                          color: isDark ? Colors.white : null,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      SizedBox(
                                        height: 90,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: albumPhotos.length,
                                          itemBuilder: (context, photoIndex) {
                                            final photo = albumPhotos[photoIndex];
                                            return GestureDetector(
                                              onTap: () => gallery.changeAlbumCover(album.id, photo.id),
                                              child: Container(
                                                margin: const EdgeInsets.only(right: 12),
                                                width: 90,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(18),
                                                  border: Border.all(
                                                    color: album.coverPhotoId == photo.id ? Theme.of(context).colorScheme.primary : Colors.transparent,
                                                    width: 2,
                                                  ),
                                                ),
                                                clipBehavior: Clip.hardEdge,
                                                child: _buildImagePreview(photo),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: gallery.albums.length,
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
