import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/gallery_provider.dart';

class BinScreen extends StatelessWidget {
  const BinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GalleryProvider>(
      builder: (context, gallery, child) {
        final trash = gallery.trash;
        return SafeArea(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: const Text('Bin'),
              actions: [
                if (trash.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.delete_forever_outlined),
                    onPressed: () => _confirmEmptyBin(context),
                    tooltip: 'Empty bin',
                  ),
              ],
            ),
            body: trash.isEmpty
                ? Center(
                    child: Text(
                      'No deleted photos yet.',
                      style: Theme.of(context).textTheme.bodyLarge,
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
                        background: Container(color: Colors.green, alignment: Alignment.centerLeft, padding: const EdgeInsets.only(left: 16), child: const Icon(Icons.restore, color: Colors.white)),
                        secondaryBackground: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 16), child: const Icon(Icons.delete_forever, color: Colors.white)),
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.startToEnd) {
                            gallery.restorePhoto(item.id);
                            return false;
                          }
                          return await _confirmDeletePhoto(context);
                        },
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          child: ListTile(
                            leading: Hero(
                              tag: item.id,
                              child: SizedBox(
                                width: 60,
                                height: 60,
                                child: Image(
                                  image: item.url.startsWith('http')
                                      ? NetworkImage(item.url) as ImageProvider
                                      : FileImage(File(item.url)),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.broken_image, size: 24),
                                  ),
                                ),
                              ),
                            ),
                            title: Text(item.title),
                            subtitle: Text('Deleted ${item.deletedAt != null ? item.deletedAt!.toLocal().toString().split(' ').first : 'recently'}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.restore),
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
        return AlertDialog(
          title: const Text('Empty Bin'),
          content: const Text('Permanently delete all items in the bin?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Empty')),
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
        return AlertDialog(
          title: const Text('Delete Permanently'),
          content: const Text('This photo will be permanently removed from the bin.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
          ],
        );
      },
    );
    return confirmed == true;
  }
}
