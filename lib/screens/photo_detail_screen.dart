import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/photo.dart';

class PhotoDetailScreen extends StatelessWidget {
  final Photo photo;

  const PhotoDetailScreen({super.key, required this.photo});

  @override
  Widget build(BuildContext context) {
    final bool isLocal = !photo.url.startsWith('http');
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Hero(
              tag: photo.id,
              child: photo.isSvg
                  ? SvgPicture.network(photo.url, fit: BoxFit.contain)
                  : Image(
                      image: isLocal
                          ? FileImage(File(photo.url)) as ImageProvider
                          : NetworkImage(photo.url) as ImageProvider,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white54, size: 64),
                    ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  color: Colors.black.withOpacity(0.35),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(photo.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text('Swipe down or tap close to return', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
