import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../constants/api_constants.dart';

class AIService {
  late final GenerativeModel _model;

  AIService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: ApiConstants.geminiApiKey,
    );
  }

  Future<Map<String, dynamic>> parseCardText(String frontText, {String? backText}) async {
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

    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);
    
    if (response.text == null) {
      throw Exception("Failed to parse card text");
    }

    try {
      // Find the JSON block in the response if Gemini adds markdown
      String jsonString = response.text!;
      if (jsonString.contains("```json")) {
        jsonString = jsonString.split("```json")[1].split("```")[0].trim();
      } else if (jsonString.contains("```")) {
        jsonString = jsonString.split("```")[1].split("```")[0].trim();
      }
      
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw Exception("Failed to decode AI response: $e");
    }
  }
}
