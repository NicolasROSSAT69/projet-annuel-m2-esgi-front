import 'package:flutter/material.dart';
import 'package:my_app/config.dart';
import 'package:my_app/models/legal_mentions.dart';
import 'package:my_app/services/legal_mentions/legal_mentions_service.dart';

class MentionsLegalescreen extends StatelessWidget {
  final AppConfig config;
  final LegalMentionsService legalMentionsService;

  MentionsLegalescreen({required this.config})
      : legalMentionsService = LegalMentionsService(config: config);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: const Text('Mentions légales'),
      ),
      body: Center(
        child: FutureBuilder<LegalMentions>(
          future: legalMentionsService.getAllLegalMentions(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Erreur : ${snapshot.error}');
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.content.length,
                itemBuilder: (context, index) {
                  final section = snapshot.data!.content[index];
                  return Container(
                    padding: const EdgeInsets.all(16.0),
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[50],
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          section.title,
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          section.text,
                          style: const TextStyle(fontSize: 16.0),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
