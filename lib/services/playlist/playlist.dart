import 'package:my_app/models/user.dart';
import 'package:my_app/services/api/api.dart';
import 'package:my_app/config.dart';
import 'dart:async';
import 'package:my_app/models/playlist.dart';
import 'package:my_app/models/music.dart';

class PlaylistService {
  final AppConfig config;
  PlaylistService({required this.config});

  Future<List<Playlist>> getAllPlaylist(AppUser currentUser) async {
    final apiService = ApiService('${config.apiUrl}/playlist/all');
    try {
      Map<String, dynamic> data = {"userId": currentUser.id};
      final response = await apiService.fetchDataWithParams(data);
      List<dynamic> playlistsJson = response['playlists'];

      // Convert each playlistJson to a Playlist object, and in the process, convert the list of music IDs to a list of Music objects
      return await Future.wait(playlistsJson.map((playlistJson) async {
        List<Music> musics = await Future.wait(
          playlistJson['musiques'].map<Future<Music>>((musicId) async {
            return await getMusicById(musicId.toString());
          }).toList(),
        );
        playlistJson['musiques'] =
            musics.map((music) => music.toJson()).toList();
        return Playlist.fromJson(playlistJson);
      }).toList());
    } catch (e) {
      print('Erreur lors de l\'envoi des données : $e');
      throw e;
    }
  }

  Future<Music> getMusicById(String musicId) async {
    final apiService = ApiService('${config.apiUrl}/musique/byid');

    Map<String, dynamic> data = {"musiqueId": musicId};

    try {
      final response = await apiService.fetchDataWithParams(data);
      List<dynamic> musicDataList = response['musique'];

      // Vérifier si la liste contient des données
      if (musicDataList.isNotEmpty) {
        Music music = Music.fromJson(musicDataList[0]);
        return music;
      } else {
        throw Exception('Aucune musique trouvée avec cet ID');
      }
    } catch (e) {
      print('Erreur lors de la récupération de la musique : $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>> removeMusicFromPlaylist(
      String userId, String playlistId, String musicId) async {
    var data = {
      'userId': userId,
      'playlistId': playlistId,
      'musicId': musicId,
    };

    final apiService = ApiService('${config.apiUrl}/playlist/musique/delete');

    final response = await apiService.postData(data);

    return response;
  }

  Future<Map<String, dynamic>> addPlaylist(String userId, String name) async {
    var data = {'userId': userId, 'name': name};

    final apiService = ApiService('${config.apiUrl}/playlist/add');

    final response = await apiService.postData(data);

    return response;
  }

  Future<Map<String, dynamic>> removePlaylist(
      String userId, String playlistId) async {
    var data = {
      'userId': userId,
      'playlistId': playlistId,
    };

    final apiService = ApiService('${config.apiUrl}/playlists/delete');

    final response = await apiService.postData(data);

    return response;
  }
}
