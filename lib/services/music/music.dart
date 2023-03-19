import 'package:my_app/models/user.dart';
import 'package:my_app/services/api/api.dart';
import 'package:my_app/config.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_app/config.dart';
import 'package:my_app/models/music.dart';

class MusicService {
  final AppConfig config;
  MusicService({required this.config});

  Future<List<Music>> getAllMusic() async {
    final apiService = ApiService('${config.apiUrl}/musique/all');
    try {
      final response = await apiService.fetchData();
      List<dynamic> musicsJson = response['musicData']['data'];
      return musicsJson.map((musicJson) => Music.fromJson(musicJson)).toList();
    } catch (e) {
      print('Erreur lors de l\'envoi des données : $e');
      throw e;
    }
  }

  Future postAddEcoute(AppUser currentUser, Music music) async {
    final apiService = ApiService('${config.apiUrl}/musique/ecoute/add');

    final data = {"musiqueId": music.id, "userId": currentUser.id};

    try {
      final response = await apiService.postData(data);
    } catch (e) {
      print('Erreur lors de l\'envoi des données : $e');
      throw e;
    }
  }

  Future<List<int>> getUserListeningHistory(AppUser currentUser) async {
    final apiService = ApiService('${config.apiUrl}/musique/ecoute/all');

    Map<String, dynamic> data = {"userId": currentUser.id};

    try {
      final response = await apiService.fetchDataWithParams(data);
      List<int> listeningHistory = response['resultat'].cast<int>();
      return listeningHistory;
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
}
