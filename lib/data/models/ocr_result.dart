import '../../data/models/ocr_block.dart';

class OcrResult {
  final String fulltext;
  final List<OcrBlock> blocks;
  OcrResult({required this.fulltext, required this.blocks});
}
