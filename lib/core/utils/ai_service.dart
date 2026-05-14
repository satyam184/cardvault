import 'dart:convert';
import 'package:groq_sdk/groq_sdk.dart';
import '../constants/api_constants.dart';

class AIService {
  late final Groq _groq;

  AIService() {
    _groq = Groq(ApiConstants.groqApiKey);
  }

  Future<Map<String, dynamic>> parseCardText(String frontText, {String? backText}) async {
    if (ApiConstants.groqApiKey.isEmpty) {
      throw Exception("Groq API Key is missing");
    }

    final combinedText = "Front text: $frontText\n${backText != null ? "Back text: $backText" : ""}";
    
    final prompt = """
    Extract contact information from the following business card text. 
    Provide the result in valid JSON format with the following keys:
    - name (String)
    - company (String or null)
    - jobTitle (String or null)
    - email (String or null)
    - phone (String or null)
    - website (String or null)
    - address (String or null)
    - linkedin (String or null)
    - socialHandles (Object with key-value pairs or empty object)

    Business Card Text:
    $combinedText
    
    Return ONLY the JSON object.
    """;

    try {
      final chat = _groq.startNewChat('llama-3.3-70b-versatile');
      final (response, usage) = await chat.sendMessage(prompt);

      final content = response.choices.first.message;
      
      // Find the JSON block
      String jsonString = content.trim();
      if (jsonString.contains("```json")) {
        jsonString = jsonString.split("```json")[1].split("```")[0].trim();
      } else if (jsonString.contains("```")) {
        jsonString = jsonString.split("```")[1].split("```")[0].trim();
      }
      
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw Exception("Groq extraction failed: $e");
    }
  }
}
