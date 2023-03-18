import 'package:my_app/models/user.dart';
import 'package:my_app/services/api/api.dart';
import 'package:my_app/config.dart';
import 'dart:async';
import 'package:flutter/material.dart';

class AuthenticationService extends ChangeNotifier {
  final AppConfig config;
  AppUser? currentUser;
  AuthenticationService({required this.config});

  final StreamController<AppUser?> _userController =
      StreamController<AppUser?>.broadcast();

  Stream<AppUser?> get user {
    return _userController.stream;
  }

  Future signUp(String pseudo, String email, String password) async {
    print("test signUp ok");
    final apiService = ApiService('${config.apiUrl}/auth/signup');
    final data = {"username": pseudo, "email": email, "password": password};
    try {
      final response = await apiService.postData(data);
      // appel la méthode signIn pour connecter l'utilisateur automatiquement après l'inscription
      return signIn(pseudo, password);
    } catch (e) {
      print('Erreur lors de l\'envoi des données : $e');
      // Diffuser 'null' sur le stream en cas d'échec de la connexion
      _userController.add(null);
    }
  }

  Future signIn(String pseudo, String password) async {
    //print('signIn called with pseudo: $pseudo, password: $password');
    final apiService = ApiService('${config.apiUrl}/auth/signin');

    // Créer des données JSON pour envoyer à l'API
    final data = {"username": pseudo, "password": password};

    try {
      final response = await apiService.postData(data);

      // Utiliser la méthode fromJson pour transformer la réponse en un objet AppUser
      final appUser = AppUser.fromJson(response);

      // Diffuser l'objet AppUser sur le stream
      _userController.add(appUser);
      // Stocke l'utilisateur courant dans currentUser
      currentUser = appUser;
      //print('signIn success: $appUser');
      notifyListeners();

      return appUser;
    } catch (e) {
      print('Erreur lors de l\'envoi des données : $e');
      // Diffuser 'null' sur le stream en cas d'échec de la connexion
      _userController.add(null);
    }
  }

  Future signOut() async {
    // Diffuser null sur le stream lorsque l'utilisateur se déconnecte
    _userController.add(null);
    // Réinitialiser currentUser lors de la déconnexion
    currentUser = null;
    print("signOut: User disconnected");
    notifyListeners();
  }
}
