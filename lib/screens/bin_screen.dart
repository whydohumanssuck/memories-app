import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/gallery_provider.dart';

class BinScreen extends StatelessWidget {
  const BinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Consumer<GalleryProvider>(
      builder: (context, gallery, child) {
        final trash = gallery.trash;
        return SafeArea(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Text('Bin', style: TextStyle(color: isDark ? Colors.white : null)),
              iconTheme: IconThemeData(color: isDark ? Colors.white : null),
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                if (trash.isNotEmpty)
                  IconButton(
                    icon: Icon(Icons.delete_forever_outlined, color: isDark ? Colors.white70 : null),
                    onPressed: () => _confirmEmptyBin(context),
                    tooltip: 'Empty bin',
                  ),
              ],
            ),
            body: trash.isEmpty
                ? Center(
                    child: Text(
                      'No deleted photos yet.',
                      style: TextStyle(
                        color: isDark ? Colors.white60 : null,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: trash.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = trash[index];
                      return Dismissible(
                        key: ValueKey(item.id),
                        background: Container(
                          color: Colors.green,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 16),
                          child: const Icon(Icons.restore, color: Colors.white),
                        ),
                        secondaryBackground: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          child: const Icon(Icons.delete_forever, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.startToEnd) {
                            gallery.restorePhoto(item.id);
                            return false;
                          }
                          return await _confirmDeletePhoto(context);
                        },
                        child: Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          color: isDark ? const Color(0xFF1E1E24).withOpacity(0.8) : null,
                          child: ListTile(
                            leading: Hero(
                              tag: item.id,
                              child: SizedBox(
                                width: 60,
                                height: 60,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image(
                                    image: item.url.startsWith('http')
                                        ? NetworkImage(item.url) as ImageProvider
                                        : FileImage(File(item.url)),
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: Colors.grey.shade800,
                                      child: const Icon(Icons.broken_image, color: Colors.white54),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              item.title,
                              style: TextStyle(color: isDark ? Colors.white : null),
                            ),
                            subtitle: Text(
                              'Deleted ${item.deletedAt != null ? item.deletedAt!.toLocal().toString().split(' ').first : 'recently'}',
                              style: TextStyle(color: isDark ? Colors.white60 : null),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.restore, color: isDark ? Colors.white70 : null),
                              onPressed: () => gallery.restorePhoto(item.id),
                              tooltip: 'Restore',
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }

  Future<void> _confirmEmptyBin(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E24) : null,
          title: Text('Empty Bin', style: TextStyle(color: isDark ? Colors.white : null)),
          content: Text('Permanently delete all items in the bin?',
            style: TextStyle(color: isDark ? Colors.white70 : null),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel', style: TextStyle(color: isDark ? Colors.white70 : null)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Empty'),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      Provider.of<GalleryProvider>(context, listen: false).emptyBin();
    }
  }

  Future<bool> _confirmDeletePhoto(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E24) : null,
          title: Text('Delete Permanently', style: TextStyle(color: isDark ? Colors.white : null)),
          content: Text('This photo will be permanently removed from the bin.',
            style: TextStyle(color: isDark ? Colors.white70 : null),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel', style: TextStyle(color: isDark ? Colors.white70 : null)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    return confirmed == true;
  }
}
