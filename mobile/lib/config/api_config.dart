import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String getBaseUrl() {
    return dotenv.env['API_BASE_URL'] ?? 'https://decent-carola-llmnd-3709b8dc.koyeb.app/api';
  }
}
