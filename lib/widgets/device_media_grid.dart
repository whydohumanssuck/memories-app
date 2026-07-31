import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import '../screens/media_viewer_screen.dart';

class DeviceMediaGrid extends StatelessWidget {
  final List<AssetEntity> assets;

  const DeviceMediaGrid({super.key, required this.assets});

  @override
  Widget build(BuildContext context) {
    if (assets.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Text(
              'No photos or videos found on this device.',
              style: TextStyle(color: Colors.white60),
            ),
          ),
        ),
      );
    }

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final asset = assets[index];
          final bool isVideo = asset.type == AssetType.video;
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MediaViewerScreen(asset: asset),
                ),
              );
            },
            child: RepaintBoundary(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image(
                    image: AssetEntityImageProvider(asset, isOriginal: false),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade900,
                      child: const Icon(Icons.broken_image, color: Colors.white54),
                    ),
                  ),
                  if (isVideo)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                        child: const Icon(Icons.play_arrow, color: Colors.white, size: 22),
                      ),
                    ),
                  if (isVideo && asset.duration > 0)
                    Positioned(
                      right: 3,
                      bottom: 3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _formatDuration(asset.duration),
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
        childCount: assets.length,
      ),
    );
  }

  String _formatDuration(int totalSeconds) {
    final Duration d = Duration(seconds: totalSeconds);
    final minutes = d.inMinutes.toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    if (d.inHours > 0) {
      return '${d.inHours}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }
}
