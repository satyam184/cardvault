import '../../core/utils/detector_utils.dart';
import '../../data/models/ocr_block.dart';

class PersonNameDetector {
  static String? detect(List<OcrBlock> blocks) {
    OcrBlock? bestBlock;
    double bestScore = 0;
    for (final block in blocks) {
      final text = block.text.trim();
      double score = 0;
      final words = text.split(' ');
      if (DetectorUtils.isTitleCase(text)) {
        score += 30;
      }
      if (words.length >= 2 && words.length <= 3) {
        score += 20;
      }
      if (!RegExp(r'\d').hasMatch(text)) {
        score += 20;
      }
      if (block.area > 4000) {
        score += 20;
      }
      if (block.centerY < 700) {
        score += 15;
      }
      if (text.contains('@')) {
        score -= 100;
      }
      if (text.contains('www')) {
        score -= 100;
      }
      if (DetectorUtils.containsCompanyKeyword(text)) {
        score -= 50;
      }

      if (text == text.toUpperCase()) {
        score -= 20;
      }
      if (score > bestScore) {
        bestScore = score;
        bestBlock = block;
      }
    }
    return bestBlock?.text;
  }
}
