class Photo {
  final String id;
  final String title;
  final String url;
  final String albumId;
  final bool isSvg;
  final bool isFavorite;
  final DateTime? deletedAt;

  Photo({
    required this.id,
    required this.title,
    required this.url,
    required this.albumId,
    this.isSvg = false,
    this.isFavorite = false,
    this.deletedAt,
  });

  Photo copyWith({
    String? id,
    String? title,
    String? url,
    String? albumId,
    bool? isSvg,
    bool? isFavorite,
    DateTime? deletedAt,
  }) {
    return Photo(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      albumId: albumId ?? this.albumId,
      isSvg: isSvg ?? this.isSvg,
      isFavorite: isFavorite ?? this.isFavorite,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  factory Photo.empty() {
    return Photo(id: '', title: '', url: '', albumId: '');
  }
}
