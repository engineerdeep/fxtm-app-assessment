import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get finnhubApiKey {
    return dotenv.env['FINNHUB_API_KEY'] ?? '';
  }

  static String get finnhubBaseUrl {
    return dotenv.env['FINNHUB_BASE_URL'] ?? '';
  }

  static String get finnhubWsUrl {
    return dotenv.env['FINNHUB_WS_URL'] ?? '';
  }

  static Future<void> initialize() async {
    await dotenv.load();
  }
}
