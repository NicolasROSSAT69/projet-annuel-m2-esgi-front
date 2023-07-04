import 'package:flutter/material.dart';
import 'package:my_app/views/splashscreen_wrapper.dart';
import 'package:provider/provider.dart';
import 'package:my_app/services/authentication.dart';
import 'models/user.dart';
import 'config.dart';
import 'package:my_app/views/home/playlist_screen.dart';
import 'package:my_app/views/home/suggestion_screen.dart';
import 'package:my_app/views/home/historique_screen.dart';
import 'package:my_app/views/home/mentions_legales_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:easy_localization/easy_localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = await AppConfig.loadConfig();

  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en', 'US'), Locale('fr', 'FR')],
      path: 'assets/translations',
      fallbackLocale: Locale('en', 'US'),
      child: MyApp(config: config),
    ),
  );
}

class MyApp extends StatelessWidget {
  final AppConfig config;

  MyApp({required this.config});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppConfig>.value(value: config),
        ChangeNotifierProvider<AuthenticationService>(
          create: (_) => AuthenticationService(config: config),
        ),
        StreamProvider<AppUser?>(
          create: (context) => context.read<AuthenticationService>().user,
          initialData: null,
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        onGenerateRoute: (settings) =>
            RouteGenerator.generateRoute(settings, config: config),
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        home: SplashScreenWrapper(config: config),
      ),
    );
  }
}

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings,
      {required AppConfig config}) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
            builder: (context) => SplashScreenWrapper(config: config));
      case '/playlist':
        return MaterialPageRoute(
            builder: (context) => Builder(
                  builder: (BuildContext innerContext) {
                    final authService = Provider.of<AuthenticationService>(
                        innerContext,
                        listen: false);
                    if (authService.currentUser != null) {
                      return PlaylistScreen(config: config);
                    } else {
                      return SplashScreenWrapper(config: config);
                    }
                  },
                ));
      case '/suggestion':
        return MaterialPageRoute(
            builder: (context) => Builder(
                  builder: (BuildContext innerContext) {
                    final authService = Provider.of<AuthenticationService>(
                        innerContext,
                        listen: false);
                    if (authService.currentUser != null) {
                      return SuggestionScreen(config: config);
                    } else {
                      return SplashScreenWrapper(config: config);
                    }
                  },
                ));
      case '/historique':
        return MaterialPageRoute(
            builder: (context) => Builder(
                  builder: (BuildContext innerContext) {
                    final authService = Provider.of<AuthenticationService>(
                        innerContext,
                        listen: false);
                    if (authService.currentUser != null) {
                      return HistoriqueScreen(config: config);
                    } else {
                      return SplashScreenWrapper(config: config);
                    }
                  },
                ));
      case '/mentionslegales':
        return MaterialPageRoute(
            builder: (context) => Builder(
                  builder: (BuildContext innerContext) {
                    return MentionsLegalescreen(config: config);
                  },
                ));
      default:
        return pageNotFound();
    }
  }

  static MaterialPageRoute pageNotFound() {
    return MaterialPageRoute(
        builder: (context) => Scaffold(
            appBar: AppBar(
                title: const Text("Error"),
                centerTitle: true,
                backgroundColor: Colors.blueGrey),
            body: const Center(
              child: Text("Page not found"),
            )));
  }
}
