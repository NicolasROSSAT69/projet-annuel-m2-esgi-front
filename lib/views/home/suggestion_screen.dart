import 'package:flutter/material.dart';
import 'package:my_app/models/user.dart';
import 'package:my_app/services/authentication.dart';
import 'package:provider/provider.dart';
import 'package:my_app/config.dart';

class SuggestionScreen extends StatelessWidget {
  final AppConfig config;
  SuggestionScreen({required this.config});

  @override
  Widget build(BuildContext context) {
    final authService =
        Provider.of<AuthenticationService>(context, listen: false);

    // Récupérer l'utilisateur courant
    AppUser? currentUser = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: const Text('Mes suggestions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authService.signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: currentUser != null
            ? Text('Suggestions de ${currentUser.username}')
            : const Text('Aucun utilisateur connecté'),
      ),
    );
  }
}
