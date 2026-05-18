import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get openRouterApiKey =>
      dotenv.env['OPENROUTER_API_KEY'] ?? dotenv.env['GROQ_API_KEY'] ?? '';
  static String get baseUrl => 'https://cardvault-backend.luminoai.online';
}
