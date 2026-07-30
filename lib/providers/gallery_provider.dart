import 'package:flutter/material.dart';
import '../models/album.dart';
import '../models/photo.dart';

class GalleryProvider extends ChangeNotifier {
  final List<Album> _albums = [];
  final List<Photo> _trash = [];
  String? _selectedAlbumId;

  GalleryProvider() {
    _initializeSampleLibrary();
  }

  List<Album> get albums => List.unmodifiable(_albums);
  List<Photo> get trash => List.unmodifiable(_trash);
  List<Photo> get photos => List.unmodifiable(_photos);

  Album? get selectedAlbum {
    if (_albums.isEmpty || _selectedAlbumId == null) return null;
    return _albums.firstWhere(
      (album) => album.id == _selectedAlbumId,
      orElse: () => _albums.first,
    );
  }

  List<Photo> get selectedPhotos => selectedAlbum == null
      ? []
      : _photosForAlbum(selectedAlbum!.id);

  Photo? findPhotoById(String id) {
    final match = _photos.where((photo) => photo.id == id);
    return match.isEmpty ? null : match.first;
  }

  void _initializeSampleLibrary() {
    final album1 = Album(id: 'album-1', title: 'Sunrise Stories', coverPhotoId: 'photo-1');
    final album2 = Album(id: 'album-2', title: 'City Nights', coverPhotoId: 'photo-4');
    final album3 = Album(id: 'album-3', title: 'Vectors & Art', coverPhotoId: 'photo-svg');

    _albums.addAll([album1, album2, album3]);
    _selectedAlbumId = album1.id;

    _photos.addAll([
      Photo(
        id: 'photo-1',
        title: 'Early morning',
        url: 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?auto=format&fit=crop&w=800&q=80',
        albumId: album1.id,
      ),
      Photo(
        id: 'photo-2',
        title: 'Peak sky',
        url: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=800&q=80',
        albumId: album1.id,
      ),
      Photo(
        id: 'photo-3',
        title: 'Field light',
        url: 'https://images.unsplash.com/photo-1496483353456-90997957cf99?auto=format&fit=crop&w=800&q=80',
        albumId: album1.id,
      ),
      Photo(
        id: 'photo-4',
        title: 'Neon street',
        url: 'https://images.unsplash.com/photo-1496307042754-b4aa456c4a2d?auto=format&fit=crop&w=800&q=80',
        albumId: album2.id,
      ),
      Photo(
        id: 'photo-5',
        title: 'Bridge lights',
        url: 'https://images.unsplash.com/photo-1470770841072-f978cf4d019e?auto=format&fit=crop&w=800&q=80',
        albumId: album2.id,
      ),
      Photo(
        id: 'photo-6',
        title: 'Metro glow',
        url: 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=800&q=80',
        albumId: album2.id,
      ),
      Photo(
        id: 'photo-svg',
        title: 'Illustration',
        url: 'https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/acid.svg',
        albumId: album3.id,
        isSvg: true,
      ),
    ]);
  }

  final List<Photo> _photos = [];

  List<Photo> _photosForAlbum(String albumId) {
    return _photos.where((photo) => photo.albumId == albumId).toList();
  }

  void selectAlbum(String albumId) {
    if (_selectedAlbumId != albumId) {
      _selectedAlbumId = albumId;
      notifyListeners();
    }
  }

  void createAlbum(String title) {
    final newAlbum = Album(
      id: 'album-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      coverPhotoId: '',
    );
    _albums.insert(0, newAlbum);
    _selectedAlbumId = newAlbum.id;
    notifyListeners();
  }

  void renameAlbum(String albumId, String updatedTitle) {
    final index = _albums.indexWhere((album) => album.id == albumId);
    if (index >= 0) {
      _albums[index] = _albums[index].copyWith(title: updatedTitle);
      notifyListeners();
    }
  }

  void changeAlbumCover(String albumId, String photoId) {
    final index = _albums.indexWhere((album) => album.id == albumId);
    if (index >= 0) {
      _albums[index] = _albums[index].copyWith(coverPhotoId: photoId);
      notifyListeners();
    }
  }

  void deletePhoto(Photo photo) {
    _photos.removeWhere((item) => item.id == photo.id);
    _trash.add(photo.copyWith(deletedAt: DateTime.now()));
    notifyListeners();
  }

  void restorePhoto(String photoId) {
    final removed = _trash.firstWhere((photo) => photo.id == photoId, orElse: () => Photo.empty());
    if (removed.id.isEmpty) return;
    _trash.removeWhere((photo) => photo.id == photoId);
    _photos.add(removed.copyWith(deletedAt: null));
    notifyListeners();
  }

  void permanentlyDelete(String photoId) {
    _trash.removeWhere((photo) => photo.id == photoId);
    notifyListeners();
  }

  void emptyBin() {
    _trash.clear();
    notifyListeners();
  }

  void addPhoto(String albumId, Photo photo) {
    _photos.add(photo.copyWith(albumId: albumId));
    notifyListeners();
  }

  void removeAlbum(String albumId) {
    final albumPhotos = _photosForAlbum(albumId);
    _trash.addAll(albumPhotos.map((photo) => photo.copyWith(deletedAt: DateTime.now())));
    _photos.removeWhere((photo) => photo.albumId == albumId);
    _albums.removeWhere((album) => album.id == albumId);
    if (_selectedAlbumId == albumId && _albums.isNotEmpty) {
      _selectedAlbumId = _albums.first.id;
    }
    notifyListeners();
  }
}
