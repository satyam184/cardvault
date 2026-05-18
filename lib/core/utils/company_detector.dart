import '../../core/utils/detector_utils.dart';
import '../../data/models/ocr_block.dart';

class CompanyDetector {
  static String? detect(List<OcrBlock> blocks, String? email, String? website) {
    OcrBlock? bestBlock;
    double bestScore = 0;

    final emailDomain = DetectorUtils.extractDomain(email);
    final websiteDomain = DetectorUtils.extractDomain(website);

    for (final block in blocks) {
      final text = block.text.trim();
      double score = 0;

      score += block.area * 0.002;
      if (block.centerY < 300) {
        score += 25;
      }
      if (text == text.toUpperCase()) {
        score += 20;
      }
      if (DetectorUtils.containsCompanyKeyword(text)) {
        score += 50;
      }
      if (emailDomain != null && text.toLowerCase().contains(emailDomain)) {
        score += 60;
      }
      if (websiteDomain != null && text.toLowerCase().contains(websiteDomain)) {
        score += 60;
      }
      if (RegExp(r'\d').hasMatch(text)) {
        score -= 40;
      }

      if (DetectorUtils.containsDesignation(text)) {
        score -= 50;
      }
      if (text.contains('@')) {
        score -= 100;
      }
      if (score > bestScore) {
        bestScore = score;
        bestBlock = block;
      }
    }
    return bestBlock?.text;
  }
}
