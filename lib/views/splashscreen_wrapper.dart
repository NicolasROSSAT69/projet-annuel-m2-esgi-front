import 'package:flutter/material.dart';
import 'package:my_app/models/user.dart';
import 'package:my_app/views/authentificate/authentificate_screen.dart';
import 'package:my_app/views/home/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:my_app/config.dart';
import 'package:my_app/services/authentication.dart';

class SplashScreenWrapper extends StatelessWidget {
  final AppConfig config;
  SplashScreenWrapper({required this.config});

  @override
  Widget build(BuildContext context) {
    final authService =
        Provider.of<AuthenticationService>(context, listen: false);

    return StreamBuilder<AppUser?>(
      stream: authService.user,
      builder: (context, snapshot) {
        print('SplashScreenWrapper build called');
        if (snapshot.hasError) {
          print('SplashScreenWrapper: error: ${snapshot.error}');
        }
        if (snapshot.hasData && snapshot.data != null) {
          print('SplashScreenWrapper: user changed: ${snapshot.data}');
          return const HomeScreen();
        } else {
          return AuthentificateScreen(config: config);
        }
      },
    );
  }
}
