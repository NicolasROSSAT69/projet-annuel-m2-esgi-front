import 'package:my_app/models/legal_mentions.dart';
import 'package:my_app/services/api/api.dart';
import 'package:my_app/config.dart';

class LegalMentionsService {
  final AppConfig config;

  LegalMentionsService({required this.config});

  Future<LegalMentions> getAllLegalMentions() async {
    final apiService = ApiService('${config.apiUrl}/conditiongenerale/get');
    try {
      final response = await apiService.fetchData();
      return LegalMentions.fromJson(response['condtionGeneral']);
    } catch (e) {
      print('Erreur lors de l\'envoi des données : $e');
      throw e;
    }
  }
}
