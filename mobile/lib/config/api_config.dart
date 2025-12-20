import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class ApiConfig {
  static String getBaseUrl() {
    // ✅ On web, skip dotenv (no .env file available)
    if (kIsWeb) {
      return 'https://vocal-fernandina-llmndg-0b759290.koyeb.app/api';
    }
    // On mobile, try to get from .env with try-catch (dotenv may not be initialized)
    try {
      final baseUrl = dotenv.env['API_BASE_URL'];
      if (baseUrl != null && baseUrl.isNotEmpty) {
        return baseUrl;
      }
    } catch (e) {
      // dotenv not initialized, use fallback
    }
    return 'https://vocal-fernandina-llmndg-0b759290.koyeb.app/api';
  }
}
