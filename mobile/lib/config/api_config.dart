import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String getBaseUrl() {
    return dotenv.env['API_BASE_URL'] ?? 'https://vocal-fernandina-llmndg-0b759290.koyeb.app/api';
  }
}
