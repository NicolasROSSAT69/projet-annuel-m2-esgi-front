class Music {
  final int id;
  final String title;

  Music({required this.id, required this.title});

  factory Music.fromJson(Map<String, dynamic> json) {
    return Music(id: json['id'], title: json['title']);
  }
}
