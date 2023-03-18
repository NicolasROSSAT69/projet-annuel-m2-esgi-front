class Music {
  final int id;
  final String title;
  final String artiste;

  Music({required this.id, required this.title, required this.artiste});

  factory Music.fromJson(Map<String, dynamic> json) {
    return Music(
        id: json['id'], title: json['title'], artiste: json['artist']['name']);
  }
}
