class Music {
  final int id;
  final String title;
  final String artiste;
  final String preview;

  Music(
      {required this.id,
      required this.title,
      required this.artiste,
      required this.preview});

  factory Music.fromJson(Map<String, dynamic> json) {
    return Music(
        id: json['id'],
        title: json['title'],
        artiste: json['artist']['name'],
        preview: json['preview']);
  }
}
