class Album {
  final String id;
  final String title;
  final String coverPhotoId;
  final DateTime createdAt;

  Album({
    required this.id,
    required this.title,
    required this.coverPhotoId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Album copyWith({
    String? id,
    String? title,
    String? coverPhotoId,
    DateTime? createdAt,
  }) {
    return Album(
      id: id ?? this.id,
      title: title ?? this.title,
      coverPhotoId: coverPhotoId ?? this.coverPhotoId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
