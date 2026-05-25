import 'package:cardvault/data/models/ocr_block.dart';

class _Lexicon {
  // Honorifics that prefix names
  static const honorifics = {
    'mr',
    'mrs',
    'ms',
    'miss',
    'dr',
    'prof',
    'sir',
    'rev',
    'eng',
    'er',
  };

  // Suffixes that follow names
  static const nameSuffixes = {
    'jr',
    'sr',
    'ii',
    'iii',
    'iv',
    'phd',
    'md',
    'mba',
    'esq',
  };

  // Strong signals → this block IS a job title
  static const titleKeywords = {
    // Leadership
    'ceo', 'cto', 'cfo', 'coo', 'cmo', 'ciso', 'president', 'vice president',
    'vp', 'svp', 'evp', 'chairman', 'chairperson', 'founder', 'co-founder',
    'managing director', 'md', 'director', 'executive director',
    // Management
    'manager', 'senior manager', 'general manager', 'head', 'lead',
    'team lead', 'principal', 'associate',
    // Engineering
    'engineer', 'developer', 'architect', 'devops', 'sre', 'qa',
    'software engineer', 'data scientist', 'data analyst', 'product manager',
    // Sales / Marketing
    'sales', 'account executive', 'account manager', 'business development',
    'marketing', 'brand', 'growth', 'partnerships',
    // Other
    'consultant', 'advisor', 'specialist', 'analyst', 'coordinator',
    'officer', 'representative', 'intern', 'fellow',
    'professor', 'lecturer', 'researcher', 'scientist',
    // Seniority modifiers (alone are weak but combined are strong)
    'senior', 'junior', 'staff', 'distinguished',
  };

  // Company legal suffixes
  static const companySuffixes = {
    'inc',
    'llc',
    'ltd',
    'limited',
    'corp',
    'corporation',
    'co',
    'pvt',
    'pvt ltd',
    'private limited',
    'plc',
    'llp',
    'lp',
    'gmbh',
    'ag',
    'sa',
    'bv',
    'nv',
    'pty',
    'pty ltd',
    'group',
    'holdings',
    'ventures',
    'technologies',
    'solutions',
    'services',
    'systems',
    'consulting',
    'associates',
    'partners',
    'studio',
    'labs',
    'works',
    'enterprises',
  };

  // Words that disqualify a block from being a name
  static const nameDisqualifiers = {
    'phone',
    'mobile',
    'fax',
    'email',
    'web',
    'www',
    'address',
    'tel',
    'cell',
    'office',
    'direct',
    ...titleKeywords,
    ...companySuffixes,
  };
}

class DetectorUtils {
  /// Checks if every word in [text] starts with an uppercase letter.
  static bool isTitleCase(String text) {
    final words = text.trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return false;
    return words.every((w) => w.isNotEmpty && w[0] == w[0].toUpperCase());
  }

  /// Extracts the bare domain from an email or URL string.
  static String? extractDomain(String? input) {
    if (input == null || input.isEmpty) return null;
    if (input.contains('@')) return input.split('@').last.toLowerCase();
    return input
        .replaceFirst(RegExp(r'^https?://'), '')
        .replaceFirst('www.', '')
        .split('/')[0]
        .toLowerCase();
  }

  /// True if [text] (lowercased) contains any known company keyword.
  static bool containsCompanySuffix(String text) {
    final lower = text.toLowerCase();
    return _Lexicon.companySuffixes.any((k) => lower.contains(k));
  }

  /// True if [text] (lowercased) contains any known title keyword.
  static bool containsTitleKeyword(String text) {
    final lower = text.toLowerCase();
    return _Lexicon.titleKeywords.any((k) => lower.contains(k));
  }

  /// True if [text] (lowercased) contains any name disqualifier.
  static bool containsNameDisqualifier(String text) {
    final lower = text.toLowerCase();
    return _Lexicon.nameDisqualifiers.any((k) => lower.contains(k));
  }

  /// Normalise a block's relative vertical position into [0.0, 1.0].
  /// Pass the max centerY across all blocks as [pageHeight].
  static double relativeY(OcrBlock block, double pageHeight) {
    if (pageHeight <= 0) return 0.5;
    return (block.centerY / pageHeight).clamp(0.0, 1.0);
  }

  /// Relative font-size proxy: block area normalised by the largest block.
  static double relativeFontSize(OcrBlock block, double maxArea) {
    if (maxArea <= 0) return 0.0;
    return (block.area / maxArea).clamp(0.0, 1.0);
  }

  /// Checks for honorific prefix → high name confidence.
  static bool hasHonorificPrefix(String text) {
    final first = text
        .trim()
        .split(' ')
        .first
        .toLowerCase()
        .replaceAll('.', '');
    return _Lexicon.honorifics.contains(first);
  }

  /// Checks for name suffix at end → moderate name confidence.
  static bool hasNameSuffix(String text) {
    final last = text.trim().split(' ').last.toLowerCase().replaceAll('.', '');
    return _Lexicon.nameSuffixes.contains(last);
  }

  /// A word looks like a proper name word if it starts with uppercase,
  /// contains only letters, apostrophes, or hyphens, and is 2+ chars.
  static bool looksLikeNameWord(String word) {
    return RegExp(r"^[A-Z][a-zA-Z'\-]{1,}$").hasMatch(word);
  }

  /// Returns true if the block is rendered in bold (font weight ≥ 600).
  ///
  /// Handles three common shapes of OCR font-weight data:
  ///   • [OcrBlock.fontWeight] as a numeric value  (e.g. 700)
  ///   • [OcrBlock.fontWeight] as a string token   (e.g. "bold", "700")
  ///   • [OcrBlock.isBold]    as a direct bool flag
  ///
  /// Falls back gracefully to false when the field is absent/null so callers
  /// never need to guard against missing data.
  static bool isBold(OcrBlock block) {
    // ── Bool flag (fastest path) ─────────────────────────────────────────────
    // Most ML-based OCR SDKs (Google ML Kit, Apple Vision) expose this directly.
    if (block.isBold == true) return true;

    // ── Numeric font weight ──────────────────────────────────────────────────
    // CSS / OpenType convention: 400 = regular, 700 = bold.
    // We treat ≥ 600 as bold (covers semi-bold at 600, bold at 700, black at 900).
    final weight = block.fontWeight.value;
    return weight >= 600;

    // ── String font weight ───────────────────────────────────────────────────
    // Some engines return "bold", "700", or a custom label like "heavy".
    // if (weight is String) {
    //   final lower = weight.index.toLowerCase().trim();
    //   if (lower == 'bold' || lower == 'heavy' || lower == 'black') return true;
    //   final parsed = int.tryParse(lower);
    //   if (parsed != null) return parsed >= 600;
    // }

    // return false;
  }
}
