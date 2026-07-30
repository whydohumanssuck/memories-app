class Photo {
  final String id;
  final String title;
  final String url;
  final String albumId;
  final bool isSvg;
  final DateTime? deletedAt;

  Photo({
    required this.id,
    required this.title,
    required this.url,
    required this.albumId,
    this.isSvg = false,
    this.deletedAt,
  });

  Photo copyWith({
    String? id,
    String? title,
    String? url,
    String? albumId,
    bool? isSvg,
    DateTime? deletedAt,
  }) {
    return Photo(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      albumId: albumId ?? this.albumId,
      isSvg: isSvg ?? this.isSvg,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  factory Photo.empty() {
    return Photo(id: '', title: '', url: '', albumId: '');
  }
}
