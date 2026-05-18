class ParsedCardResult {
  final Map<String, dynamic> data;
  final double confidenceScore;
  final bool needsAI;

  const ParsedCardResult({
    required this.data,
    required this.confidenceScore,
    required this.needsAI,
    r,
  });
}
