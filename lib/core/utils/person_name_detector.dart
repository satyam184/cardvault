import '../../core/utils/detector_utils.dart';
import '../../data/models/ocr_block.dart';

class PersonNameDetector {
  static String? detect(List<OcrBlock> blocks) {
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
      final score = _scoreName(block, pageHeight, maxArea);
      if (score > bestScore) {
        bestScore = score;
        bestBlock = block;
      }
    }

    // Reject if even the best candidate scored below threshold
    return bestScore >= 30 ? bestBlock?.text.trim() : null;
  }

  static double _scoreName(OcrBlock block, double pageHeight, double maxArea) {
    final text = block.text.trim();
    if (text.isEmpty) return double.negativeInfinity;

    double score = 0;

    // ── Hard disqualifiers ───────────────────────────────────────────────────
    if (text.contains('@')) return double.negativeInfinity;
    if (text.contains('://') || text.contains('www.'))
      return double.negativeInfinity;
    if (RegExp(r'\d').hasMatch(text))
      return double.negativeInfinity; // no digits in names
    if (text.split(RegExp(r'\s+')).length > 5) return -80; // too many words

    // ── Disqualifiers with heavy penalty ─────────────────────────────────────
    if (DetectorUtils.containsTitleKeyword(text)) score -= 60;
    if (DetectorUtils.containsCompanySuffix(text)) score -= 60;

    // ── Positive signals ─────────────────────────────────────────────────────

    // 1. Honorific prefix is the strongest signal
    if (DetectorUtils.hasHonorificPrefix(text)) score += 50;

    // 2. Word structure: 2–4 proper name words
    final words = text.split(RegExp(r'\s+'));
    final nameWordCount = words.where(DetectorUtils.looksLikeNameWord).length;
    if (nameWordCount == words.length &&
        words.length >= 2 &&
        words.length <= 4) {
      score += 40; // ALL words look like name words
    } else if (nameWordCount >= words.length - 1 && words.length >= 2) {
      score += 20; // most words look like name words
    }

    // 3. Name suffix (Jr., PhD after a name)
    if (DetectorUtils.hasNameSuffix(text)) score += 15;

    // 4. Title case (each word capitalised)
    if (DetectorUtils.isTitleCase(text)) score += 15;

    // 5. Bold font weight — names are almost always the heaviest text on a card.
    //    Score is context-sensitive:
    //      • Bold alone              → +25 (strong standalone signal)
    //      • Bold + looks like names → +35 (name-word structure reinforces it)
    //      • Bold + honorific        → already at +50, so no extra boost needed
    if (DetectorUtils.isBold(block)) {
      final isStructuredName =
          nameWordCount == words.length &&
          words.length >= 2 &&
          words.length <= 4;
      score += isStructuredName ? 35 : 25;
    }

    // 6. ALL CAPS — common on cards but ambiguous; small positive
    if (text == text.toUpperCase() && !text.contains(' ')) {
      score += 5; // single word all-caps could be a surname badge
    } else if (text == text.toUpperCase()) {
      score += 10; // multi-word all-caps is also acceptable for names
    }

    // 7. Relative font size — name is usually large but not always the largest
    final relSize = DetectorUtils.relativeFontSize(block, maxArea);
    score += relSize * 20; // up to +20

    // 8. Vertical position — names tend to be in upper half, but not top-most
    //    (the top-most is often the company logo/name on many card layouts)
    final relY = DetectorUtils.relativeY(block, pageHeight);
    if (relY < 0.5) score += 10;
    if (relY < 0.25) score -= 5; // might be logo area

    return score;
  }
}
