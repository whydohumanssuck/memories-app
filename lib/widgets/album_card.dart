import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/album.dart';
import '../providers/gallery_provider.dart';

class AlbumCard extends StatelessWidget {
  final Album album;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onRemove;

  const AlbumCard({
    super.key,
    required this.album,
    required this.isSelected,
    required this.onTap,
    required this.onRename,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gallery = Provider.of<GalleryProvider>(context, listen: false);
    final coverPhoto = gallery.findPhotoById(album.coverPhotoId);
    final hasCover = album.coverPhotoId.isNotEmpty && coverPhoto != null;

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          children: [
            Container(
              width: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: isDark ? const Color(0xFF1E1E24).withOpacity(0.6) : Theme.of(context).colorScheme.surfaceVariant,
                border: Border.all(
                  color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      child: hasCover
                          ? Image(
                                image: coverPhoto!.url.startsWith('http')
                                    ? NetworkImage(coverPhoto.url) as ImageProvider
                                    : FileImage(File(coverPhoto.url)),
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey.shade800,
                                  child: const Icon(Icons.broken_image, color: Colors.white54),
                                ),
                              )
                          : Container(
                              alignment: Alignment.center,
                              color: isDark ? const Color(0xFF2A2A35) : Theme.of(context).colorScheme.primaryContainer,
                              child: Icon(Icons.photo, size: 36, color: isDark ? Colors.white38 : null),
                            ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          album.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap to open',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, size: 18, color: isDark ? Colors.white70 : null),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'rename', child: Text('Rename')),
                  const PopupMenuItem(value: 'remove', child: Text('Delete')),
                ],
                onSelected: (value) {
                  if (value == 'rename') onRename();
                  if (value == 'remove') onRemove();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
