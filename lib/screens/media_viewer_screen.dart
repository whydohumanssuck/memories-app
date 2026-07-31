import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:video_player/video_player.dart';

class MediaViewerScreen extends StatefulWidget {
  final AssetEntity asset;

  const MediaViewerScreen({super.key, required this.asset});

  @override
  State<MediaViewerScreen> createState() => _MediaViewerScreenState();
}

class _MediaViewerScreenState extends State<MediaViewerScreen> {
  VideoPlayerController? _videoController;
  bool _isVideo = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _isVideo = widget.asset.type == AssetType.video;
    if (!_isVideo) return;

    final File? file = await widget.asset.file;
    if (file == null || !mounted) return;
    final VideoPlayerController controller = VideoPlayerController.file(file);
    await controller.initialize();
    if (!mounted) {
      controller.dispose();
      return;
    }
    setState(() => _videoController = controller);
    controller.play();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: _isVideo
                ? (_videoController != null && _videoController!.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _videoController!.value.aspectRatio,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            VideoPlayer(_videoController!),
                            _buildPlayPauseButton(),
                          ],
                        ),
                      )
                    : const CircularProgressIndicator(color: Colors.white70))
                : InteractiveViewer(
                    maxScale: 5,
                    child: Image(
                      image: AssetEntityImageProvider(widget.asset, isOriginal: true),
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.broken_image,
                        color: Colors.white54,
                        size: 64,
                      ),
                    ),
                  ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.asset.title ?? 'Untitled',
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isVideo ? 'Video' : 'Photo',
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
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
        ],
      ),
    );
  }

  Widget _buildPlayPauseButton() {
    return GestureDetector(
      onTap: () {
        final vc = _videoController;
        if (vc == null) return;
        setState(() {
          vc.value.isPlaying ? vc.pause() : vc.play();
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
        child: Icon(
          _videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }
}
