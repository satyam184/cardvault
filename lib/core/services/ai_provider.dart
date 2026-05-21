import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../exceptions/exceptions.dart';

abstract class AIProvider {
  String get name;
  bool get isConfigured;

  Future<Map<String, dynamic>> parseCardText(
    String frontText, {
    String? backText,
  });

  String buildPrompt(String frontText, String? backText) {
    final combined =
        'Front text: $frontText\n'
        '${backText != null ? "Back text: $backText" : ""}';
    return '''
Extract contact information from the following business card text.
Provide the result in valid JSON format with these keys:
  name          (String)
  company       (String or null)
  jobTitle      (String or null)
  email         (String or null)
  phone         (String or null)
  website       (String or null)
  address       (String or null)
  linkedin      (String or null)
  socialHandles (Object with key-value pairs or empty object)

Business Card Text:
$combined

Return ONLY the JSON object. No markdown, no explanation.
''';
  }

  String stripFences(String raw) {
    debugPrint('raw test of promt: $raw');
    var s = raw.trim();
    if (s.contains('```json')) {
      s = s.split('```json')[1].split('```')[0].trim();
    } else if (s.contains('```')) {
      s = s.split('```')[1].split('```')[0].trim();
    }
    return s;
  }

  Never handleError(DioException e) {
    final status = e.response?.statusCode;
    final body = e.response?.data.toString() ?? '';

    if (status == 429) {
      throw QuotaExhaustedException(
        name,
        'Rate limit / quota exhausted. $body',
      );
    }
    throw Exception('$name request failed [$status]: $body');
  }
}
