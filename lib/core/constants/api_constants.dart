import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get openRouterApiKey => dotenv.env['OPENROUTER_API_KEY'] ?? '';
  static String get groqApiKey => dotenv.env['GROQ_API_KEY'] ?? '';
  static String get baseUrl => dotenv.env['BASE_URL'] ?? '';
  static String get groqUrl => dotenv.env['GROQ_URL'] ?? '';
  static String get openRouterUrl => dotenv.env['OPENROUTER_URL'] ?? '';
}
