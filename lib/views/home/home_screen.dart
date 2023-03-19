import 'package:flutter/material.dart';
import 'package:my_app/models/user.dart';
import 'package:my_app/services/authentication.dart';
import 'package:provider/provider.dart';
import 'package:my_app/views/home/playlist_screen.dart';
import 'package:my_app/models/music.dart';
import 'package:my_app/services/music/music.dart';
import 'package:my_app/config.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends StatefulWidget {
  final AppConfig config;
  HomeScreen({required this.config});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AudioPlayer audioPlayer = AudioPlayer();

  //Pour gérer l'état de lecture de la musique
  ValueNotifier<bool> isPlaying = ValueNotifier<bool>(false);

  ValueNotifier<int> playingIndex = ValueNotifier<int>(-1);

  @override
  void initState() {
    super.initState();
    audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      //if (state == PlayerState.stopped) {
      if (state == PlayerState.completed) {
        setState(() {
          playingIndex.value = -1;
        });
      }
    });
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

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
              music.artiste.toLowerCase().contains(query.toLowerCase()) ||
              music.genreMusical.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    final musicService = MusicService(config: widget.config);

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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blueGrey),
              child: Image.asset(
                'assets/img/MelodySphereLogo.png',
                width: 100,
                height: 100,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Accueil'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.music_note),
              title: const Text('Ma playlists'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/playlist');
              },
            ),
            ListTile(
              leading: const Icon(Icons.tips_and_updates),
              title: const Text('Mes suggestions'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/suggestion');
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Mon historique'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/historique');
              },
            ),
            ListTile(
              leading: const Icon(Icons.policy),
              title: const Text('Mentions légales'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/mentionslegales');
              },
            ),
            // Ajoutez d'autres éléments de liste ici pour les autres pages
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Rechercher',
                      prefixIcon: const Icon(Icons.search),
                      fillColor: Colors
                          .white, // Couleur de fond de la barre de recherche
                      filled: true,
                      labelStyle: const TextStyle(
                          color:
                              Colors.blueGrey), // Couleur du texte "Rechercher"
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Colors
                                .blueGrey), // Couleur de la bordure lorsqu'elle est concentrée
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Colors
                                .grey), // Couleur de la bordure lorsqu'elle est activée
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                    onChanged: (value) {
                      searchQuery.value = value;
                    },
                  ),
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
                                    // Ajouter ce morceau de code pour afficher l'image
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: CachedNetworkImage(
                                        imageUrl: music.coverSmall,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            const CircularProgressIndicator(),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                      ),
                                    ),
                                    const SizedBox(width: 15),
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
                                          Text(music.genreMusical,
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
                                          //Enregistrement de la musique
                                          //écouté pour faire l'historique d'écoute de l'utilisateur
                                          musicService.postAddEcoute(
                                              currentUser!, music);
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
