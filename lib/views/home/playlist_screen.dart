import 'package:flutter/material.dart';
import 'package:my_app/models/user.dart';
import 'package:my_app/services/authentication.dart';
import 'package:provider/provider.dart';
import 'package:my_app/config.dart';
import 'package:my_app/services/playlist/playlist.dart';
import 'package:my_app/models/playlist.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:my_app/views/widgets/dropdown.dart';

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
  final TextEditingController _playlistControllerName = TextEditingController();
  final TextEditingController _playlistControllerNumber =
      TextEditingController();

  List<String> items = ["Rock", "Pop", "Hip-hop", "Rap", "R&B"];

  String? selectedItem = 'Rock';

  final dropdownKey = GlobalKey<DropdownButtonWidgetState>();

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
        title: Text('Mes_playlists'.tr()),
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
                  return Center(child: Text('Aucune_playlist_disponible'.tr()));
                }

                final playlists = snapshot.data!;

                return ListView.builder(
                  itemCount: playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = playlists[index];
                    return ExpansionTile(
                      title: Text(playlist.name),
                      subtitle: Text('Nombre_de_musiques'.tr() +
                          ':' +
                          playlist.musiques.length.toString()),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              // Suppression de la playlist
                              await playlistService!
                                  .removePlaylist(currentUser!.id, playlist.id);

                              // // Suppression de la playlist de la liste locale
                              setState(() {
                                playlists.removeAt(index);
                              });
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
                          subtitle: Text("Titre : " +
                              music.artiste +
                              " Genre : " +
                              music.genreMusical),
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
        onPressed: () => _showInfoPlaylistDialog(),
        child: Icon(Icons.add),
        backgroundColor: Colors.blueGrey,
      ),
    );
  }

  void _showAddPlaylistDialog() {
    showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: Text('Ajouter_une_nouvelle_playlist'.tr()),
            content: TextFormField(
              controller: _playlistController,
              decoration: InputDecoration(hintText: 'Nom_de_la_playlist'.tr()),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Annuler'.tr()),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
              ),
              TextButton(
                child: Text('Ajouter'.tr()),
                onPressed: () async {
                  // La logique pour ajouter la playlist
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

  void _showInfoPlaylistDialog() {
    showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: Text('Creer_une_playlist'.tr()),
            content: Column(
              mainAxisSize: MainAxisSize
                  .min, // Utilisez cette ligne pour éviter les problèmes de débordement
              children: <Widget>[
                ListTile(
                  title: Text('Playlist_personnalisee'.tr()),
                  onTap: () async {
                    Navigator.of(context).pop();
                    _showAddPlaylistDialog(); // Ferme le dialogue
                  },
                ),
                ListTile(
                  title: Text('Playlist_aleatoire_par_genre'.tr()),
                  onTap: () async {
                    Navigator.of(context).pop();
                    _showAddPlaylistAleaDialog(); // Ferme le dialogue
                  },
                )
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Annuler'.tr()),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
              ),
            ],
          );
        });
  }

  void _showAddPlaylistAleaDialog() {
    showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: Text('Creer_une_playlist_aleatoire'.tr()),
            content: Column(
              mainAxisSize: MainAxisSize
                  .min, // Utilisez cette ligne pour éviter les problèmes de débordement
              children: <Widget>[
                TextFormField(
                  controller: _playlistControllerName,
                  decoration:
                      InputDecoration(hintText: 'Nom_de_la_playlist'.tr()),
                ),
                TextFormField(
                  controller: _playlistControllerNumber,
                  decoration: InputDecoration(
                      hintText: 'Nombre_de_musique_souhaite'.tr()),
                ),
                DropdownButtonWidget(
                  key: dropdownKey,
                  items: items,
                )
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Annuler'.tr()),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
              ),
              TextButton(
                child: Text('Ajouter'.tr()),
                onPressed: () async {
                  String playlistName = _playlistControllerName.text;
                  String playlistNumber = _playlistControllerNumber.text;
                  String selectedGenre =
                      dropdownKey.currentState?.getSelectedItem() ?? 'Rock';

                  await playlistService!.addPlaylistAleatoireByGenre(
                      currentUser!.id,
                      playlistName,
                      playlistNumber,
                      selectedGenre);
                  Navigator.of(dialogContext).pop();
                  _playlistControllerName.text = '';
                  _playlistControllerNumber.text = '';

                  // Rafraîchir la liste de playlists
                  refreshPlaylists();
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
