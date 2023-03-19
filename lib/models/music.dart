class Music {
  final int id;
  final String title;
  final String artiste;
  final String preview;
  final String coverSmall;
  final String genreMusical;

  Music(
      {required this.id,
      required this.title,
      required this.artiste,
      required this.preview,
      required this.coverSmall,
      required this.genreMusical});

  factory Music.fromJson(Map<String, dynamic> json) {
    return Music(
        id: json['id'],
        title: json['title'],
        artiste: json['artist']['name'],
        preview: json['preview'],
        coverSmall: json['album']['cover_small'],
        genreMusical: json['genre_musical']);
  }
}
