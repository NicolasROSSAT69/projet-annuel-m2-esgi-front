import 'package:flutter/material.dart';
import 'package:my_app/models/user.dart';
import 'package:my_app/services/authentication.dart';
import 'package:provider/provider.dart';
import 'package:my_app/config.dart';
import 'package:my_app/services/music/music.dart';
import 'package:my_app/models/music.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:easy_localization/easy_localization.dart';

class HistoriqueScreen extends StatefulWidget {
  final AppConfig config;
  HistoriqueScreen({required this.config});

  @override
  _HistoriqueScreenState createState() => _HistoriqueScreenState();
}

class _HistoriqueScreenState extends State<HistoriqueScreen> {
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

    // Récupérer l'utilisateur courant
    AppUser? currentUser = authService.currentUser;

    final musicService = MusicService(config: widget.config);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text('Mon_historique'.tr()),
      ),
      body: currentUser != null
          ? FutureBuilder(
              future: musicService.getUserListeningHistory(currentUser),
              builder: (context, AsyncSnapshot<List<int>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Erreur : ${snapshot.error}');
                } else {
                  List<int> musicIds = snapshot.data!;
                  Set<int> uniqueMusicIds =
                      musicIds.toSet(); // Conversion en Set
                  musicIds = uniqueMusicIds.toList(); // Reconversion en List
                  return ListView.builder(
                    itemCount: musicIds.length,
                    itemBuilder: (context, index) {
                      String musicId = musicIds[index].toString();
                      return Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: FutureBuilder(
                          future: musicService.getMusicById(musicId),
                          builder:
                              (context, AsyncSnapshot<Music> musicSnapshot) {
                            if (musicSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (musicSnapshot.hasError) {
                              return Text('Erreur : ${musicSnapshot.error}');
                            } else {
                              Music music = musicSnapshot.data!;
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListTile(
                                  leading: Image.network(music.coverSmall),
                                  title: Text(music.title),
                                  subtitle: Text(music.artiste),
                                  trailing: IconButton(
                                    icon: ValueListenableBuilder<int>(
                                      valueListenable: playingIndex,
                                      builder: (context, currentIndex, child) {
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
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
                  );
                }
              },
            )
          : const Text('Aucun utilisateur connecté'),
    );
  }
}
