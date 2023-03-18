import 'package:flutter/material.dart';
import 'package:my_app/models/user.dart';
import 'package:my_app/services/authentication.dart';
import 'package:provider/provider.dart';
import 'package:my_app/views/home/playlist_screen.dart';
import 'package:my_app/models/music.dart';
import 'package:my_app/services/music/music.dart';
import 'package:my_app/config.dart';
import 'package:audioplayers/audioplayers.dart';

class HomeScreen extends StatelessWidget {
  final AppConfig config;
  HomeScreen({required this.config});

  final AudioPlayer audioPlayer = AudioPlayer();

  void togglePlayback(Music music) async {
    if (audioPlayer.state == PlayerState.playing) {
      await audioPlayer.pause();
    } else {
      await audioPlayer.play(UrlSource(music.preview));
    }
  }

  //Pour gérer l'état de lecture de la musique
  ValueNotifier<bool> isPlaying = ValueNotifier<bool>(false);

  ValueNotifier<int> playingIndex = ValueNotifier<int>(-1);

  @override
  Widget build(BuildContext context) {
    final authService =
        Provider.of<AuthenticationService>(context, listen: false);
    AppUser? currentUser = authService.currentUser;

    ValueNotifier<String> searchQuery = ValueNotifier<String>("");

    List<Music> searchResults(List<Music> musicList, String query) {
      return musicList
          .where((music) =>
              music.title.toLowerCase().contains(query.toLowerCase()) ||
              music.artiste.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    final musicService = MusicService(config: config);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: const Text('Accueil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authService.signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Rechercher',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    searchQuery.value = value;
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<Music>>(
              future: musicService.getAllMusic(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text("Erreur : ${snapshot.error}");
                } else {
                  List<Music> musicList = snapshot.data!;
                  return ValueListenableBuilder<String>(
                    valueListenable: searchQuery,
                    builder: (context, query, child) {
                      List<Music> filteredMusicList =
                          searchResults(musicList, query);
                      return Expanded(
                        child: ListView.builder(
                          itemCount: filteredMusicList.length,
                          itemBuilder: (context, index) {
                            Music music = filteredMusicList[index];
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(music.title,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium),
                                          Text(music.artiste,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: ValueListenableBuilder<int>(
                                        valueListenable: playingIndex,
                                        builder:
                                            (context, currentIndex, child) {
                                          return Icon(currentIndex == index &&
                                                  audioPlayer.state ==
                                                      PlayerState.playing
                                              ? Icons.pause
                                              : Icons.play_arrow);
                                        },
                                      ),
                                      onPressed: () async {
                                        if (audioPlayer.state ==
                                                PlayerState.playing &&
                                            playingIndex.value == index) {
                                          await audioPlayer.pause();
                                          playingIndex.value = -1;
                                        } else {
                                          await audioPlayer
                                              .play(UrlSource(music.preview));
                                          await audioPlayer.resume();
                                          playingIndex.value = index;
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () {
                                        // Ajouter votre logique pour le bouton d'ajout ici
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
