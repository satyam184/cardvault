import '../../data/models/ocr_block.dart';
import '../../data/models/ocr_result.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  // Future<String> recognizeText(String imagePath) async {
  //   final InputImage inputImage = InputImage.fromFilePath(imagePath);
  //   final RecognizedText recognizedText = await _textRecognizer.processImage(
  //     inputImage,
  //   );

  //   return recognizedText.text;
  // }

  // void dispose() {
  //   _textRecognizer.close();
  // }

  Future<OcrResult> recognizeText(String imagePath) async {
    final InputImage inputImage = InputImage.fromFilePath(imagePath);
    final RecognizedText recognizedText = await _textRecognizer.processImage(
      inputImage,
    );

    final blocks = <OcrBlock>[];
    for (final block in recognizedText.blocks) {
      blocks.add(OcrBlock(text: block.text.trim(), rect: block.boundingBox));
    }
    return OcrResult(fulltext: recognizedText.text, blocks: blocks);
  }

  void dispose() {
    _textRecognizer.close();
  }
}
