import 'package:flutter/material.dart';
import 'package:my_app/models/user.dart';
import 'package:my_app/services/authentication.dart';
import 'package:provider/provider.dart';
import 'package:my_app/views/home/playlist_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService =
        Provider.of<AuthenticationService>(context, listen: false);
    AppUser? currentUser = authService.currentUser;

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
            // Ajoutez d'autres éléments de liste ici pour les autres pages
          ],
        ),
      ),
      body: Center(
        child: currentUser != null
            ? Text('Bienvenue, ${currentUser.username}')
            : const Text('Aucun utilisateur connecté'),
      ),
    );
  }
}
