import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../widgets/constances.dart';
import '../../views/widgets/loading.dart';
import 'package:my_app/services/authentication.dart';
import 'package:my_app/config.dart';

class AuthentificateScreen extends StatefulWidget {
  final AppConfig config;
  const AuthentificateScreen({required this.config});

  @override
  State<AuthentificateScreen> createState() => _AuthentificateScreenState();
}

class _AuthentificateScreenState extends State<AuthentificateScreen> {
  late AuthenticationService _auth;

  @override
  void initState() {
    super.initState();
    _auth = AuthenticationService(config: widget.config);
  }

  final _formKey = GlobalKey<FormState>();

  String error = '';
  bool loading = false;

  final pseudoController = TextEditingController();
  final passwordController = TextEditingController();
  bool showSignin = true;

  @override
  void dispose() {
    pseudoController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void toggleView() {
    setState(() {
      _formKey.currentState!.reset();
      error = '';
      pseudoController.text = '';
      passwordController.text = '';
      showSignin = !showSignin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Loading()
        : Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.blueGrey,
              elevation: 0.0,
              title: Text(showSignin ? 'Connexion' : 'Inscription'),
              actions: <Widget>[
                TextButton.icon(
                  icon: const Icon(Icons.person, color: Colors.white),
                  label: Text(
                    showSignin ? 'Inscription' : 'Connexion',
                    style: const TextStyle(color: Colors.white),
                  ),
                  onPressed: () => toggleView(),
                )
              ],
            ),
            body: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: pseudoController,
                      decoration:
                          textInputDecoration.copyWith(hintText: 'pseudo'),
                      validator: (value) =>
                          value!.isEmpty ? 'Entrez un pseudo' : null,
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      controller: passwordController,
                      decoration: textInputDecoration.copyWith(
                          hintText: 'mot de passe'),
                      obscureText: true,
                      validator: (value) => value!.length < 6
                          ? 'Entrez un mot de passe de plus de 6 caractères'
                          : null,
                    ),
                    const SizedBox(height: 10.0),
                    FilledButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey, // Background color
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() => loading = true);
                          var pseudo = pseudoController.value.text;
                          var password = passwordController.value.text;

                          //ToDo call api auth

                          dynamic result = showSignin
                              ? await _auth.signIn(pseudo, password)
                              : await _auth.signUp(pseudo, password);
                          if (result == null) {
                            setState(() {
                              loading = false;
                              error =
                                  'Veuillez entrer un pseudo et un mot de passe valide';
                            });
                          }
                        }
                      },
                      child: Text(
                        showSignin ? 'Connexion' : 'Inscription',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      error,
                      style: const TextStyle(color: Colors.red, fontSize: 14.0),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
