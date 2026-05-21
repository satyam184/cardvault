import '../../core/utils/company_detector.dart';
import '../../core/utils/job_title_detector.dart';
import '../../core/utils/person_name_detector.dart';
import '../../data/models/ocr_result.dart';

class BusinessCardParser {
  static const int _aiThresholdScore = 80;

  ParsedCardResult parse({required OcrResult front, OcrResult? back}) {
    final frontText = front.fulltext.trim();
    final backText = back?.fulltext.trim() ?? '';
    final combinedText = '$frontText\n$backText';

    final email = _extractEmail(combinedText);
    final phones = _extractPhones(combinedText);
    final websites = _extractWebsites(combinedText, email);
    final linkedIn = _extractLinkedIn(combinedText);
    final address = _extractAddress(combinedText);
    final name = PersonNameDetector.detect(front.blocks);
    final company = CompanyDetector.detect(
      front.blocks,
      email,
      websites.firstOrNull,
    );
    final jobTitle = JobTitleDetector.detect(front.blocks, detectedName: name);

    final data = ParsedCardData(
      name: name,
      company: company,
      jobTitle: jobTitle,
      email: email,
      primaryPhone: phones.firstOrNull,
      additionalPhones: phones.skip(1).toList(),
      primaryWebsite: websites.firstOrNull,
      additionalWebsites: websites.skip(1).toList(),
      linkedIn: linkedIn,
      address: address,
    );

    final fieldScores = _scoreFields(data);
    final confidence = _computeOverallConfidence(fieldScores);
    final needsAI =
        confidence < _aiThresholdScore || name == null || company == null;

    return ParsedCardResult(
      data: data.toMap(),
      fieldScores: fieldScores,
      confidenceScore: confidence,
      needsAI: needsAI,
    );
  }

  // ─── Extractors ────────────────────────────────────────────────────────────

  String? _extractEmail(String text) {
    // RFC 5321-compliant local part; TLD 2–63 chars
    final regex = RegExp(r'[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,63}');
    return regex.firstMatch(text)?.group(0)?.toLowerCase();
  }

  List<String> _extractPhones(String text) {
    // Handles: +91 98765 43210 | (800) 555-1234 | 1-800-555-1234 | +1.800.555.1234
    final regex = RegExp(
      r'(?<!\d)(\+?[\d]{1,3}[\s.\-]?)?'
      r'(\(?\d{2,4}\)?[\s.\-]?)'
      r'(\d{2,4}[\s.\-]?){1,4}'
      r'\d{2,4}(?!\d)',
    );
    return regex
        .allMatches(text)
        .map((m) => m.group(0)!.trim())
        .where((p) => p.replaceAll(RegExp(r'\D'), '').length >= 7)
        .toSet() // deduplicate
        .toList();
  }

  List<String> _extractWebsites(String text, String? email) {
    // Intentionally exclude email domains to avoid false positives
    final emailDomain = email?.split('@').last;

    final regex = RegExp(
      r'(?:https?://)?(?:www\.)?'
      r'([A-Za-z0-9](?:[A-Za-z0-9\-]{0,61}[A-Za-z0-9])?'
      r'(?:\.[A-Za-z0-9](?:[A-Za-z0-9\-]{0,61}[A-Za-z0-9])?)*'
      r'\.[A-Za-z]{2,63})'
      r'(?:/[^\s]*)?',
      caseSensitive: false,
    );

    // Block-listed TLDs / common false positives
    const blocklist = {'gmail.com', 'yahoo.com', 'outlook.com', 'hotmail.com'};

    return regex
        .allMatches(text)
        .map((m) => m.group(0)!.trim())
        .where((url) {
          final domain = url
              .replaceFirst(RegExp(r'^https?://'), '')
              .replaceFirst(RegExp(r'^www\.'), '')
              .split('/')[0]
              .toLowerCase();
          return domain != emailDomain && !blocklist.contains(domain);
        })
        .toSet()
        .toList();
  }

  String? _extractLinkedIn(String text) {
    final regex = RegExp(
      r'(?:https?://)?(?:www\.)?linkedin\.com/(in|pub|company)/[A-Za-z0-9_\-]+/?',
      caseSensitive: false,
    );
    return regex.firstMatch(text)?.group(0);
  }

  String? _extractAddress(String text) {
    // Multi-strategy: numbered street address OR P.O. Box OR known patterns
    final streetRegex = RegExp(
      r'\d{1,5}\s+(?:[A-Z][a-z]+\s+){1,4}'
      r'(?:Street|St|Avenue|Ave|Road|Rd|Boulevard|Blvd|Lane|Ln|Drive|Dr|Court|Ct|Way|Place|Pl)\.?'
      r'(?:,\s*(?:Suite|Ste|Apt|#)\s*\w+)?'
      r'(?:,\s*[A-Za-z\s]+)?'
      r'(?:,\s*[A-Z]{2}\s+\d{5}(?:-\d{4})?)?',
      caseSensitive: false,
    );

    final poBoxRegex = RegExp(
      r'P\.?\s*O\.?\s*Box\s+\d+(?:,\s*[A-Za-z\s]+)?(?:,\s*[A-Z]{2}\s+\d{5})?',
      caseSensitive: false,
    );

    return streetRegex.firstMatch(text)?.group(0)?.trim() ??
        poBoxRegex.firstMatch(text)?.group(0)?.trim();
  }

  // ─── Confidence Scoring ────────────────────────────────────────────────────

  /// Returns a 0–100 score per field based on format validity + presence.
  Map<String, int> _scoreFields(ParsedCardData data) {
    return {
      'name': _scoreNullable(data.name, weight: 20),
      'company': _scoreNullable(data.company, weight: 15),
      'jobTitle': _scoreNullable(data.jobTitle, weight: 10),
      'email': _scoreEmail(data.email),
      'phone': _scoreNullable(data.primaryPhone, weight: 15),
      'website': _scoreNullable(data.primaryWebsite, weight: 10),
      'linkedin': _scoreNullable(data.linkedIn, weight: 5),
      'address': _scoreNullable(data.address, weight: 10),
    };
  }

  int _scoreNullable(String? value, {required int weight}) =>
      value != null && value.isNotEmpty ? weight : 0;

  int _scoreEmail(String? email) {
    if (email == null) return 0;
    // Extra validation: must have a dot in the domain part
    final parts = email.split('@');
    if (parts.length == 2 && parts[1].contains('.')) return 15;
    return 5;
  }

  /// Weighted average capped at 100.
  int _computeOverallConfidence(Map<String, int> scores) {
    final total = scores.values.fold(0, (a, b) => a + b);
    return total.clamp(0, 100);
  }
}

// ─── Supporting Data Classes ──────────────────────────────────────────────────

class ParsedCardData {
  final String? name;
  final String? company;
  final String? jobTitle;
  final String? email;
  final String? primaryPhone;
  final List<String> additionalPhones;
  final String? primaryWebsite;
  final List<String> additionalWebsites;
  final String? linkedIn;
  final String? address;

  const ParsedCardData({
    this.name,
    this.company,
    this.jobTitle,
    this.email,
    this.primaryPhone,
    this.additionalPhones = const [],
    this.primaryWebsite,
    this.additionalWebsites = const [],
    this.linkedIn,
    this.address,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'company': company,
    'jobTitle': jobTitle,
    'email': email,
    'phone': primaryPhone,
    'additionalPhones': additionalPhones,
    'website': primaryWebsite,
    'additionalWebsites': additionalWebsites,
    'linkedin': linkedIn,
    'address': address,
  };
}

class ParsedCardResult {
  final Map<String, dynamic> data;
  final Map<String, int> fieldScores;
  final int confidenceScore;
  final bool needsAI;

  const ParsedCardResult({
    required this.data,
    required this.fieldScores,
    required this.confidenceScore,
    required this.needsAI,
  });
}
