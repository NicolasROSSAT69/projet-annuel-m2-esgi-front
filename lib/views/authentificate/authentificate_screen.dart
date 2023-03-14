import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../widgets/constances.dart';
import '../../views/widgets/loading.dart';

class AuthentificateScreen extends StatefulWidget {
  const AuthentificateScreen({Key? key}) : super(key: key);

  @override
  State<AuthentificateScreen> createState() => _AuthentificateScreenState();
}

class _AuthentificateScreenState extends State<AuthentificateScreen> {
  final _formKey = GlobalKey<FormState>();
  String error = '';
  bool loading = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool showSignin = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void toggleView() {
    setState(() {
      _formKey.currentState!.reset();
      error = '';
      emailController.text = '';
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
                      controller: emailController,
                      decoration:
                          textInputDecoration.copyWith(hintText: 'email'),
                      validator: (value) =>
                          value!.isEmpty ? 'Entrez un email' : null,
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
                    ElevatedButton(
                      child: Text(
                        showSignin ? 'Connexion' : 'Inscription',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          setState(() => loading = true);
                          var email = emailController.value.text;
                          var password = passwordController.value.text;

                          //ToDo call api auth

                          dynamic result = null;
                          if (result == null) {
                            setState(() {
                              loading = false;
                              error = 'Veuillez entrer un email valide';
                            });
                          }
                        }
                      },
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
