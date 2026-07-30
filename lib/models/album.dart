class Album {
  final String id;
  final String title;
  final String coverPhotoId;

  Album({
    required this.id,
    required this.title,
    required this.coverPhotoId,
  });

  Album copyWith({
    String? id,
    String? title,
    String? coverPhotoId,
  }) {
    return Album(
      id: id ?? this.id,
      title: title ?? this.title,
      coverPhotoId: coverPhotoId ?? this.coverPhotoId,
    );
  }
}
