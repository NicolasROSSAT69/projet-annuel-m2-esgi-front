import 'dart:convert';
import 'package:flutter/services.dart';

class AppConfig {
  final String apiUrl;

  AppConfig({required this.apiUrl});

  static Future<AppConfig> loadConfig() async {
    final contents = await rootBundle.loadString('assets/config.json');
    final json = jsonDecode(contents);

    return AppConfig(apiUrl: json['apiUrl']);
  }
}
