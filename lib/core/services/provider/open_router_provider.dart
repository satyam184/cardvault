import 'dart:convert';

import 'package:cardvault/core/constants/api_constants.dart';
import 'package:cardvault/core/services/ai_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

class OpenRouterProvider extends AIProvider {
  late final Dio _dio;

  OpenRouterProvider() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.openRouterUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'HTTP-Referer': 'http://cardvault.app',
          'X-Title': 'CardVault',
        },
      ),
    );
  }

  @override
  bool get isConfigured => ApiConstants.openRouterApiKey.isNotEmpty;

  @override
  String get name => 'OpenRouter';

  @override
  Future<Map<String, dynamic>> parseCardText(
    String frontText, {
    String? backText,
  }) async {
    try {
      final response = await _dio.post(
        '/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer  ${ApiConstants.openRouterApiKey}',
          },
        ),
        data: {
          'model': 'meta-llama/llama-3.1-8b-instruct',
          'messages': [
            {'role': 'user', 'content': buildPrompt(frontText, backText)},
          ],
          'temperature': 0.1,
        },
      );
      final content =
          response.data['choices'][0]['message']['content'] as String;
      debugPrint('[$name] raw response: $content');
      return jsonDecode(stripFences(content)) as Map<String, dynamic>;
    } on DioException catch (e) {
      handleError(e);
    }
  }
}
