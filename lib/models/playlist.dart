import 'package:my_app/models/music.dart';

class Playlist {
  final String id;
  final String user;
  final String name;
  final List<Music> musiques;

  Playlist({
    required this.id,
    required this.user,
    required this.name,
    required this.musiques,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    List<dynamic> musiquesJson = json['musiques'];

    return Playlist(
      id: json['_id'],
      user: json['user'],
      name: json['name'],
      musiques: musiquesJson
          .map((musicJson) => Music.fromJsonForPlaylist(musicJson))
          .toList(),
    );
  }
}
