import '../../core/utils/detector_utils.dart';
import '../../data/models/ocr_block.dart';

class CompanyDetector {
  static String? detect(
    List<OcrBlock> blocks,
    String? email,
    String? website, {
    String? detectedName,
    String? detectedTitle,
  }) {
    if (blocks.isEmpty) return null;

    final pageHeight = blocks
        .map((b) => b.centerY)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();
    final maxArea = blocks
        .map((b) => b.area)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    final emailDomain = DetectorUtils.extractDomain(email);
    final websiteDomain = DetectorUtils.extractDomain(website);

    OcrBlock? bestBlock;
    double bestScore = double.negativeInfinity;

    for (final block in blocks) {
      // Skip blocks already claimed by name or title
      final t = block.text.trim();
      if (detectedName != null && t == detectedName.trim()) continue;
      if (detectedTitle != null && t == detectedTitle.trim()) continue;

      final score = _scoreCompany(
        block,
        pageHeight,
        maxArea,
        emailDomain,
        websiteDomain,
      );
      if (score > bestScore) {
        bestScore = score;
        bestBlock = block;
      }
    }

    return bestScore >= 20 ? bestBlock?.text.trim() : null;
  }

  static double _scoreCompany(
    OcrBlock block,
    double pageHeight,
    double maxArea,
    String? emailDomain,
    String? websiteDomain,
  ) {
    final text = block.text.trim();
    if (text.isEmpty) return double.negativeInfinity;

    double score = 0;

    // ── Hard disqualifiers ───────────────────────────────────────────────────
    if (text.contains('@')) {
      return double.negativeInfinity;
    }
    if (text.contains('://') || text.contains('www.')) {
      return double.negativeInfinity;
    }
    if (RegExp(r'\d{5,}').hasMatch(text)) {
      return double.negativeInfinity; // phone/zip
    }

    // ── Strongest signals ────────────────────────────────────────────────────

    // Domain match is the most reliable signal available
    if (emailDomain != null && text.toLowerCase().contains(emailDomain)) {
      score += 80;
    }
    if (websiteDomain != null && text.toLowerCase().contains(websiteDomain)) {
      score += 80;
    }

    // Legal company suffix
    if (DetectorUtils.containsCompanySuffix(text)) {
      score += 60;
    }

    // ── Title keyword penalty ────────────────────────────────────────────────
    if (DetectorUtils.containsTitleKeyword(text)) {
      score -= 60;
    }

    // ── Casing: ALL CAPS is very common for company names on cards ────────
    if (text == text.toUpperCase()) score += 25;

    // ── Font size: company name/logo tends to be large ────────────────────
    final relSize = DetectorUtils.relativeFontSize(block, maxArea);
    score += relSize * 25; // up to +25

    // ── Position: companies appear at top or bottom of the card ──────────
    final relY = DetectorUtils.relativeY(block, pageHeight);
    if (relY <= 0.20) {
      score += 20;
    } // very top (logo area)
    else if (relY >= 0.80) {
      score += 10;
    } // footer branding

    // ── Numbers: some company names have them (e.g. "3M", "7-Eleven") ────
    // so only penalise if it looks like a phone number structure
    if (RegExp(r'\d[\s\-]\d{3}[\s\-]\d{4}').hasMatch(text)) score -= 60;

    return score;
  }
}
