import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get openRouterApiKey => dotenv.env['OPENROUTER_API_KEY'] ?? '';
  static String get baseUrl =>
      dotenv.env['BASE_URL'] ?? 'https://cardvault-backend.luminoai.online';
}
