import 'package:cardvault/core/utils/confidence_calculator.dart';

import '../../core/utils/company_detector.dart';
import '../../core/utils/parsed_card_result.dart';
import '../../core/utils/person_name_detector.dart';
import '../../data/models/ocr_result.dart';

class BusinessCardParser {
  ParsedCardResult parse({required OcrResult front, OcrResult? back}) {
    final combinedText =
        '''
            ${front.fulltext}
            ${back?.fulltext ?? ''}
        ''';

    final emailRegex = RegExp(
      r'[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}',
    );

    final phoneRegex = RegExp(r'(\+?\d[\d\s-]{8,}\d)');

    final websiteRegex = RegExp(r'(www\.)?[A-Za-z0-9-]+\.[A-Za-z]{2,}');

    final linkedinRegex = RegExp(
      r'(https?:\/\/)?(www\.)?linkedin\.com\/[A-Za-z0-9\/\-\_]+',
    );

    final addressRegex = RegExp(r'\d{1,5}\s\w+(\s\w+){1,}');

    final email = emailRegex.firstMatch(combinedText)?.group(0);

    final phone = phoneRegex.firstMatch(combinedText)?.group(0);

    final website = websiteRegex.firstMatch(combinedText)?.group(0);

    final linkedIn = linkedinRegex.firstMatch(combinedText)?.group(0);

    final address = addressRegex.firstMatch(combinedText)?.group(0);

    final name = PersonNameDetector.detect(front.blocks);

    final company = CompanyDetector.detect(front.blocks, email, website);

    final data = {
      'name': name,
      'company': company,
      'email': email,
      'phone': phone,
      'website': website,
      'linkedin': linkedIn,
      'address': address,
    };

    final confidence = ConfidenceCalculator.calculate(data);

    final needsAI = confidence < 80 || name == null || company == null;

    return ParsedCardResult(
      data: data,
      confidenceScore: confidence,
      needsAI: needsAI,
    );
  }
}
