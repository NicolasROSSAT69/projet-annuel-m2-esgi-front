import 'package:flutter/material.dart';
import 'package:my_app/models/user.dart';
import 'package:my_app/services/authentication.dart';
import 'package:provider/provider.dart';
import 'package:my_app/config.dart';
import 'package:my_app/services/playlist/playlist.dart';
import 'package:my_app/models/playlist.dart';

class PlaylistScreen extends StatefulWidget {
  final AppConfig config;
  PlaylistScreen({required this.config});

  @override
  _PlaylistScreenState createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  Future<List<Playlist>>? _playlistsFuture;
  AppUser? currentUser;

  @override
  void initState() {
    super.initState();
    final authService =
        Provider.of<AuthenticationService>(context, listen: false);
    // Récupérer l'utilisateur courant
    currentUser = authService.currentUser;

    if (currentUser != null) {
      _playlistsFuture =
          PlaylistService(config: widget.config).getAllPlaylist(currentUser!);
    }
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
                      children: playlist.musiques.map((music) {
                        return ListTile(
                          leading: Image.network(music.coverSmall),
                          title: Text(music.title),
                          subtitle: Text(music.artiste),
                          trailing: IconButton(
                            icon: const Icon(Icons.play_circle_filled),
                            onPressed: () {
                              // Vous pouvez ajouter ici la logique de lecture de la musique
                            },
                          ),
                        );
                      }).toList(),
                    );
                  },
                );
              },
            )
          : const Center(child: Text('Aucun utilisateur connecté')),
    );
  }
}
