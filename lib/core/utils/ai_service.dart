import 'package:cardvault/core/exceptions/exceptions.dart';
import 'package:cardvault/core/services/ai_provider.dart';
import 'package:cardvault/core/services/provider/groq_provider.dart';
import 'package:cardvault/core/services/provider/open_router_provider.dart';
import 'package:flutter/material.dart';

// class AIService {
//   late final Dio _dio;

//   AIService() {
//     _dio = Dio(
//       BaseOptions(
//         baseUrl: 'https://openrouter.ai/api/v1',
//         connectTimeout: const Duration(seconds: 30),
//         receiveTimeout: const Duration(seconds: 30),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//           'HTTP-Referer': 'https://cardvault.app',
//           'X-Title': 'CardVault',
//         },
//       ),
//     );
//   }

//   Future<Map<String, dynamic>> parseCardText(
//     String frontText, {
//     String? backText,
//   }) async {
//     if (ApiConstants.openRouterApiKey.isEmpty) {
//       throw Exception("OpenRouter API Key is missing");
//     }

//     final combinedText =
//         "Front text: $frontText\n${backText != null ? "Back text: $backText" : ""}";

//     final prompt =
//         """
//     Extract contact information from the following business card text.
//     Provide the result in valid JSON format with the following keys:
//     - name (String)
//     - company (String or null)
//     - jobTitle (String or null)
//     - email (String or null)
//     - phone (String or null)
//     - website (String or null)
//     - address (String or null)
//     - linkedin (String or null)
//     - socialHandles (Object with key-value pairs or empty object)

//     Business Card Text:
//     $combinedText

//     Return ONLY the JSON object. Do not include markdown formatting or additional explanation.
//     """;

//     try {
//       final response = await _dio.post(
//         '/chat/completions',
//         options: Options(
//           headers: {'Authorization': 'Bearer ${ApiConstants.openRouterApiKey}'},
//         ),
//         data: {
//           'model': 'meta-llama/llama-3.1-8b-instruct',
//           'messages': [
//             {'role': 'user', 'content': prompt},
//           ],
//           'temperature': 0.1,
//         },
//       );

//       if (response.statusCode == 200) {
//         final content =
//             response.data['choices'][0]['message']['content'] as String;

//         // Find the JSON block
//         String jsonString = content.trim();
//         debugPrint("content: $jsonString");
//         if (jsonString.contains("```json")) {
//           jsonString = jsonString.split("```json")[1].split("```")[0].trim();
//         } else if (jsonString.contains("```")) {
//           jsonString = jsonString.split("```")[1].split("```")[0].trim();
//         }

//         return json.decode(jsonString) as Map<String, dynamic>;
//       } else {
//         throw Exception(
//           "OpenRouter returned status code ${response.statusCode}",
//         );
//       }
//     } catch (e) {
//       debugPrint("OpenRouter extraction failed: $e");
//       throw Exception("OpenRouter extraction failed: $e");
//     }
//   }
// }

class AIService {
  final List<AIProvider> _providers;
  AIService({List<AIProvider>? providers})
    : _providers = providers ?? [OpenRouterProvider(), GroqProvider()];

  Future<Map<String, dynamic>> parseCardText(
    String frontText, {
    String? backText,
  }) async {
    final errors = <String>[];

    for (final provider in _providers) {
      if (!provider.isConfigured) {
        final msg = '${provider.name}: API key not configured, skipping.';
        debugPrint(msg);
        errors.add(msg);
        continue;
      }
      try {
        debugPrint('Trying provider: ${provider.name}');
        final result = await provider.parseCardText(
          frontText,
          backText: backText,
        );
        debugPrint('${provider.name} succeeded.');
        return result;
      } on QuotaExhaustedException catch (e) {
        debugPrint('${provider.name} quota exhausted, falling back. ($e)');
        errors.add(e.toString());
      } catch (e) {
        debugPrint('${provider.name} failed unexpectedly: $e');
        errors.add('${provider.name}: $e');
      }
    }

    throw AllProviderFailedException(errors);
  }
}
