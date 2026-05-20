abstract class AIProvider {
  String get name;
  bool get isConfigured;

  Future<Map<String, dynamic>> parseCardText(
    String frontText, {
    String? backText,
  });
}
