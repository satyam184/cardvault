import '../../core/utils/detector_utils.dart';
import '../../data/models/ocr_block.dart';

class JobTitleDetector {
  static String? detect(List<OcrBlock> blocks, {String? detectedName}) {
    if (blocks.isEmpty) return null;

    final pageHeight = blocks
        .map((b) => b.centerY)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();
    final maxArea = blocks
        .map((b) => b.area)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    OcrBlock? bestBlock;
    double bestScore = double.negativeInfinity;

    for (final block in blocks) {
      // Skip the block that was already claimed as the name
      if (detectedName != null && block.text.trim() == detectedName.trim()) {
        continue;
      }

      final score = _scoreTitle(block, pageHeight, maxArea);
      if (score > bestScore) {
        bestScore = score;
        bestBlock = block;
      }
    }

    return bestScore >= 25 ? bestBlock?.text.trim() : null;
  }

  static double _scoreTitle(OcrBlock block, double pageHeight, double maxArea) {
    final text = block.text.trim();
    if (text.isEmpty) return double.negativeInfinity;

    double score = 0;

    // ── Hard disqualifiers ───────────────────────────────────────────────────
    if (text.contains('@')) return double.negativeInfinity;
    if (text.contains('://') || text.contains('www.')) {
      return double.negativeInfinity;
    }
    if (RegExp(r'\d{4,}').hasMatch(text)) {
      return double.negativeInfinity;
    } // phone/zip

    // ── Primary signal: contains a known title keyword ────────────────────
    if (DetectorUtils.containsTitleKeyword(text)) score += 70;

    // Without a keyword, it's very hard to be confident — low base
    // (we still allow weak candidates to bubble up if nothing better exists)

    // ── Company suffix penalty ────────────────────────────────────────────
    if (DetectorUtils.containsCompanySuffix(text)) score -= 50;

    // ── Length heuristic: titles are 1–6 words ────────────────────────────
    final wordCount = text.split(RegExp(r'\s+')).length;
    if (wordCount >= 1 && wordCount <= 6) score += 10;
    if (wordCount > 8) score -= 20;

    // ── Usually smaller font than name, larger than contact details ───────
    final relSize = DetectorUtils.relativeFontSize(block, maxArea);
    // Ideal zone: 20%–70% of max font size
    if (relSize >= 0.20 && relSize <= 0.70) score += 15;

    // ── Vertical position: title usually appears just below the name ──────
    final relY = DetectorUtils.relativeY(block, pageHeight);
    if (relY >= 0.15 && relY <= 0.55) score += 10;

    // ── Casing patterns ───────────────────────────────────────────────────
    // Title case is common for job titles
    if (DetectorUtils.isTitleCase(text)) score += 10;
    // ALL CAPS less common for titles vs companies
    if (text == text.toUpperCase()) score -= 5;

    return score;
  }
}
