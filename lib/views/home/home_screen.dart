import 'package:flutter/material.dart';
import 'package:my_app/models/user.dart';
import 'package:my_app/services/authentication.dart';
import 'package:provider/provider.dart';
import 'package:my_app/views/home/playlist_screen.dart';
import 'package:my_app/models/music.dart';
import 'package:my_app/services/music/music.dart';
import 'package:my_app/config.dart';

class HomeScreen extends StatelessWidget {
  final AppConfig config;
  HomeScreen({required this.config});

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
                                      icon: const Icon(Icons.play_arrow),
                                      onPressed: () {
                                        // Ajoutez votre logique pour le bouton de lecture ici
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () {
                                        // Ajoutez votre logique pour le bouton d'ajout ici
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
