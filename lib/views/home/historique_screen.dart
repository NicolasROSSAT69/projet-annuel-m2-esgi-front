import 'package:flutter/material.dart';
import 'package:my_app/models/user.dart';
import 'package:my_app/services/authentication.dart';
import 'package:provider/provider.dart';
import 'package:my_app/config.dart';

class HistoriqueScreen extends StatelessWidget {
  final AppConfig config;
  HistoriqueScreen({required this.config});

  @override
  Widget build(BuildContext context) {
    final authService =
        Provider.of<AuthenticationService>(context, listen: false);

    // Récupérer l'utilisateur courant
    AppUser? currentUser = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: const Text('Mon historique'),
      ),
      body: Center(
        child: currentUser != null
            ? Text('Historique de ${currentUser.username}')
            : const Text('Aucun utilisateur connecté'),
      ),
    );
  }
}
