import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/photo.dart';

class PhotoGrid extends StatelessWidget {
  final List<Photo> photos;
  final void Function(Photo) onPhotoTap;
  final void Function(Photo)? onPhotoLongPress;

  const PhotoGrid({
    super.key,
    required this.photos,
    required this.onPhotoTap,
    this.onPhotoLongPress,
  });

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 120),
          child: Center(
            child: Text(
              'No photos in this album yet.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
      );
    }

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final photo = photos[index];
          return GestureDetector(
            onTap: () => onPhotoTap(photo),
            onLongPress: onPhotoLongPress == null ? null : () => onPhotoLongPress!(photo),
            child: Hero(
              tag: photo.id,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: RepaintBoundary(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildPhotoPreview(photo),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                            ),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            photo.title,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
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
        childCount: photos.length,
      ),
    );
  }

  Widget _buildPhotoPreview(Photo photo) {
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
          color: Colors.grey.shade900,
          child: const Icon(Icons.broken_image, color: Colors.white54),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: photo.uri,
      fit: BoxFit.cover,
      memCacheWidth: 400,
      placeholder: (_, __) => Container(
        color: Colors.grey.shade900,
        child: const Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      errorWidget: (_, __, ___) => Container(
        color: Colors.grey.shade900,
        child: const Icon(Icons.broken_image, color: Colors.white54),
      ),
    );
  }
}
