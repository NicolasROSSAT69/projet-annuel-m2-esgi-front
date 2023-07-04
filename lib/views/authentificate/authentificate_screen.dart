import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:my_app/views/widgets/constances.dart';
import 'package:my_app/views/widgets/loading.dart';
import 'package:my_app/services/authentication.dart';
import 'package:my_app/config.dart';
import 'package:provider/provider.dart';

class AuthentificateScreen extends StatefulWidget {
  final AppConfig config;
  const AuthentificateScreen({required this.config});

  @override
  State<AuthentificateScreen> createState() => _AuthentificateScreenState();
}

class _AuthentificateScreenState extends State<AuthentificateScreen> {
  final _formKey = GlobalKey<FormState>();

  String error = '';
  bool loading = false;

  final pseudoController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool showSignin = true;

  @override
  void dispose() {
    pseudoController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
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
    final _auth = Provider.of<AuthenticationService>(context);

    return loading
        ? const Loading()
        : Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.blueGrey,
              elevation: 0.0,
              leading: IconButton(
                icon: const Icon(Icons.info_outline, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/mentionslegales');
                },
              ),
              title: Text(showSignin ? 'connexion'.tr() : 'inscription'.tr()),
              actions: <Widget>[
                DropdownButton<Locale>(
                  value: context.locale,
                  onChanged: (Locale? newValue) {
                    if (newValue != null) {
                      context.setLocale(newValue);
                    }
                  },
                  items: context.supportedLocales
                      .map<DropdownMenuItem<Locale>>((Locale value) {
                    return DropdownMenuItem<Locale>(
                      value: value,
                      child: Text(value.languageCode),
                    );
                  }).toList(),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.person, color: Colors.white),
                  label: Text(
                    showSignin ? 'inscription'.tr() : 'connexion'.tr(),
                    style: const TextStyle(color: Colors.white),
                  ),
                  onPressed: () => toggleView(),
                )
              ],
            ),
            body: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
              child: Center(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/img/MelodySphereLogo.png'),
                          const SizedBox(height: 30.0),
                          TextFormField(
                            controller: pseudoController,
                            decoration: textInputDecoration.copyWith(
                                hintText: 'pseudo'.tr()),
                            validator: (value) =>
                                value!.isEmpty ? 'Entrez un pseudo'.tr() : null,
                          ),
                          if (!showSignin) const SizedBox(height: 10.0),
                          if (!showSignin)
                            TextFormField(
                              controller: emailController,
                              decoration: textInputDecoration.copyWith(
                                  hintText: 'email'.tr()),
                              validator: (value) => value!.isEmpty
                                  ? 'Entrez un email'.tr()
                                  : null,
                            ),
                          const SizedBox(height: 10.0),
                          TextFormField(
                            controller: passwordController,
                            decoration: textInputDecoration.copyWith(
                                hintText: 'mot_de_passe'.tr()),
                            obscureText: true,
                            validator: (value) => value!.length < 6
                                ? 'Entrez un mot de passe de plus de 6 caractères'
                                    .tr()
                                : null,
                          ),
                          if (!showSignin) const SizedBox(height: 10.0),
                          if (!showSignin)
                            TextFormField(
                              controller: confirmPasswordController,
                              decoration: textInputDecoration.copyWith(
                                  hintText: 'confirmer_mot_de_passe'.tr()),
                              obscureText: true,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Confirmez votre mot de passe'.tr();
                                } else if (value != passwordController.text) {
                                  return 'Les mots de passe ne correspondent pas'
                                      .tr();
                                }
                                return null;
                              },
                            ),
                          const SizedBox(height: 10.0),
                          FilledButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.blueGrey, // Background color
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() => loading = true);
                                var pseudo = pseudoController.value.text;
                                var password = passwordController.value.text;
                                var email = emailController.value.text;

                                dynamic result = showSignin
                                    ? await _auth.signIn(pseudo, password)
                                    : await _auth.signUp(
                                        pseudo, email, password);
                                if (result == null) {
                                  setState(() {
                                    loading = false;
                                    error =
                                        'Veuillez entrer un pseudo et un mot de passe valide'
                                            .tr();
                                  });
                                }
                              }
                            },
                            child: Text(
                              showSignin
                                  ? 'connexion'.tr()
                                  : 'inscription'.tr(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          Text(
                            error,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 14.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
  }
}
