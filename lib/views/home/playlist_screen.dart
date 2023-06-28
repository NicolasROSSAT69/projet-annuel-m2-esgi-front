import 'package:flutter/material.dart';
import 'package:my_app/models/user.dart';
import 'package:my_app/services/authentication.dart';
import 'package:provider/provider.dart';
import 'package:my_app/config.dart';
import 'package:my_app/services/playlist/playlist.dart';
import 'package:my_app/models/playlist.dart';
import 'package:audioplayers/audioplayers.dart';

class PlaylistScreen extends StatefulWidget {
  final AppConfig config;
  PlaylistScreen({required this.config});

  @override
  _PlaylistScreenState createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  Future<List<Playlist>>? _playlistsFuture;
  AppUser? currentUser;
  PlaylistService? playlistService;
  final TextEditingController _playlistController = TextEditingController();

  final AudioPlayer audioPlayer = AudioPlayer();
  ValueNotifier<int> playingIndex = ValueNotifier<int>(-1);

  @override
  void initState() {
    super.initState();
    final authService =
        Provider.of<AuthenticationService>(context, listen: false);
    // Récupérer l'utilisateur courant
    currentUser = authService.currentUser;
    playlistService = PlaylistService(config: widget.config);
    if (currentUser != null) {
      _playlistsFuture = playlistService!.getAllPlaylist(currentUser!);
    }

    audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (state == PlayerState.completed) {
        setState(() {
          playingIndex.value = -1;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: const Text('Mes playlists'),
      ),
      body: currentUser != null
          ? FutureBuilder<List<Playlist>>(
              future: _playlistsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                }

                // Check if snapshot.data is null
                if (snapshot.data == null) {
                  return const Center(
                      child: Text('Aucune playlist disponible'));
                }

                final playlists = snapshot.data!;

                return ListView.builder(
                  itemCount: playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = playlists[index];
                    return ExpansionTile(
                      title: Text(playlist.name),
                      subtitle: Text(
                          'Nombre de musiques: ${playlist.musiques.length}'),
                      trailing: Row(
                        // <-- Modification ici
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              // La logique pour supprimer la playlist
                            },
                          ),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                      children: playlist.musiques.map((music) {
                        int musicIndex = playlist.musiques.indexOf(music);
                        return ListTile(
                          leading: Image.network(music.coverSmall),
                          title: Text(music.title),
                          subtitle: Text(music.artiste),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ValueListenableBuilder<int>(
                                valueListenable: playingIndex,
                                builder: (context, currentIndex, child) {
                                  return IconButton(
                                    icon: Icon(
                                      currentIndex == musicIndex &&
                                              audioPlayer.state ==
                                                  PlayerState.playing
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                    ),
                                    onPressed: () async {
                                      if (audioPlayer.state ==
                                              PlayerState.playing &&
                                          playingIndex.value == musicIndex) {
                                        await audioPlayer.pause();
                                        playingIndex.value = -1;
                                      } else {
                                        await audioPlayer
                                            .play(UrlSource(music.preview));
                                        await audioPlayer.resume();
                                        playingIndex.value = musicIndex;
                                      }
                                    },
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  // Suppression de la musique de la playlist
                                  await playlistService!
                                      .removeMusicFromPlaylist(currentUser!.id,
                                          playlist.id, music.id.toString());

                                  // Suppression de la musique de la liste locale
                                  setState(() {
                                    playlist.musiques.removeAt(musicIndex);
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                );
              },
            )
          : const Center(child: Text('Aucun utilisateur connecté')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPlaylistDialog(),
        child: Icon(Icons.add),
        backgroundColor: Colors.blueGrey,
      ),
    );
  }

  void _showAddPlaylistDialog() {
    showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          // <-- Ajout de dialogContext
          return AlertDialog(
            title: const Text('Ajouter une nouvelle playlist'),
            content: TextFormField(
              controller: _playlistController,
              decoration: const InputDecoration(hintText: "Nom de la playlist"),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Annuler'),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
              ),
              TextButton(
                child: const Text('Ajouter'),
                onPressed: () async {
                  // Votre logique pour ajouter la playlist
                  String playlistName = _playlistController.text;
                  Navigator.of(dialogContext).pop();
                  // Ajout de la playlist
                  await playlistService!
                      .addPlaylist(currentUser!.id, playlistName);

                  // Rafraîchir la liste de playlists
                  refreshPlaylists();
                  // nettoyage du champ
                  _playlistController.text = '';
                },
              ),
            ],
          );
        });
  }

  void refreshPlaylists() {
    setState(() {
      _playlistsFuture = playlistService!.getAllPlaylist(currentUser!);
    });
  }
}
