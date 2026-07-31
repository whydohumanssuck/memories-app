import 'dart:io';
import 'package:flutter/material.dart';
import '../models/photo.dart';

class PhotoGrid extends StatelessWidget {
  final List<Photo> photos;
  final void Function(Photo) onPhotoTap;
  final void Function(Photo)? onFavoriteTap;

  const PhotoGrid({
    super.key,
    required this.photos,
    required this.onPhotoTap,
    this.onFavoriteTap,
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
          final ImageProvider imgProvider = photo.url.startsWith('http')
              ? NetworkImage(photo.url) as ImageProvider
              : FileImage(File(photo.url)) as ImageProvider;
          return GestureDetector(
            onTap: () => onPhotoTap(photo),
            child: Hero(
              tag: photo.id,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image(
                      image: imgProvider,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade900,
                        child: const Icon(Icons.broken_image, color: Colors.white54),
                      ),
                    ),
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
          );
        },
        childCount: photos.length,
      ),
    );
  }
}
