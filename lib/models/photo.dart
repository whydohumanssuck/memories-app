enum PhotoSource { network, local, svg }

class Photo {
  final String id;
  final String title;
  final String albumId;
  final String uri;
  final PhotoSource source;
  final DateTime createdAt;
  final DateTime? deletedAt;

  Photo({
    required this.id,
    required this.title,
    required this.albumId,
    required this.uri,
    this.source = PhotoSource.network,
    DateTime? createdAt,
    this.deletedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isSvg => source == PhotoSource.svg;
  bool get isLocal => source == PhotoSource.local;

  Photo copyWith({
    String? id,
    String? title,
    String? albumId,
    String? uri,
    PhotoSource? source,
    DateTime? createdAt,
    DateTime? deletedAt,
  }) {
    return Photo(
      id: id ?? this.id,
      title: title ?? this.title,
      albumId: albumId ?? this.albumId,
      uri: uri ?? this.uri,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
