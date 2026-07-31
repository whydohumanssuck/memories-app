import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/photo.dart';
import '../providers/gallery_provider.dart';

class PhotoSearchDelegate extends SearchDelegate<Photo?> {
  @override
  String get searchFieldLabel => 'Search photos...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context);
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearchList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchList(context);

  Widget _buildSearchList(BuildContext context) {
    final gallery = Provider.of<GalleryProvider>(context, listen: false);
    final results = gallery.searchPhotos(query);

    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('Search your photos', style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('No photos found', style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final photo = results[index];
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 48,
              height: 48,
              child: photo.url.startsWith('http')
                  ? CachedNetworkImage(
                      imageUrl: photo.url,
                      fit: BoxFit.cover,
                      memCacheWidth: 120,
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image, size: 24),
                      ),
                    )
                  : Image(
                      image: FileImage(File(photo.url)),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image, size: 24),
                      ),
                    ),
            ),
          ),
          title: Text(photo.title),
          subtitle: Text(photo.isFavorite ? '❤️ Favorite' : ''),
          trailing: IconButton(
            icon: Icon(
              photo.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: photo.isFavorite ? Colors.red : null,
            ),
            onPressed: () {
              gallery.toggleFavorite(photo.id);
              (context as Element).markNeedsBuild();
            },
          ),
          onTap: () => close(context, photo),
        );
      },
    );
  }
}
