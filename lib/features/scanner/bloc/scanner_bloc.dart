import '../../../core/utils/business_card_parser.dart';
import '../../../data/models/ocr_result.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'scanner_event.dart';
import 'scanner_state.dart';
import '../../../core/utils/ocr_service.dart';
import '../../../core/utils/ai_service.dart';
import '../../../data/models/contact_model.dart';
import 'package:uuid/uuid.dart';

class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  final OCRService ocrService;
  final AIService aiService;
  final BusinessCardParser parser;

  ScannerBloc({
    required this.ocrService,
    required this.aiService,
    required this.parser,
  }) : super(ScannerInitial()) {
    on<CaptureFront>((event, emit) {
      final currentState = state;
      if (currentState is ScannerCapturing) {
        emit(
          ScannerCapturing(
            frontImage: event.image,
            backImage: currentState.backImage,
            isFrontCaptured: true,
            isBackCaptured: currentState.isBackCaptured,
          ),
        );
      } else {
        emit(ScannerCapturing(frontImage: event.image, isFrontCaptured: true));
      }
    });

    on<CaptureBack>((event, emit) {
      final currentState = state;
      if (currentState is ScannerCapturing) {
        emit(
          ScannerCapturing(
            frontImage: currentState.frontImage,
            backImage: event.image,
            isFrontCaptured: currentState.isFrontCaptured,
            isBackCaptured: true,
          ),
        );
      } else {
        emit(ScannerCapturing(backImage: event.image, isBackCaptured: true));
      }
    });

    on<StartAnalysis>((event, emit) async {
      final currentState = state;
      if (currentState is! ScannerCapturing ||
          currentState.frontImage == null) {
        emit(ScannerError("Front image is required"));
        return;
      }

      emit(ScannerAnalyzing("Wait..."));

      try {
        final frontResult = await ocrService.recognizeText(
          currentState.frontImage!.path,
        );
        OcrResult? backResult;
        if (currentState.backImage != null) {
          backResult = await ocrService.recognizeText(
            currentState.backImage!.path,
          );
        }

        emit(ScannerAnalyzing("Almost done..."));

        final parsedResult = parser.parse(
          front: frontResult,
          back: backResult,
        );

        Map<String, dynamic> parsedData;

        if (parsedResult.needsAI) {
          debugPrint('USED AI TO PARSE');
          parsedData = await aiService.parseCardText(
            frontResult.fulltext,
            backText: backResult?.fulltext ?? '',
          );
        } else {
          parsedData = parsedResult.data;
        }

        final contact = BusinessContact(
          id: const Uuid().v4(),
          name: parsedData['name'] ?? "Unknown",
          company: parsedData['company'] ?? "Unknown",
          jobTitle: parsedData['jobTitle'],
          email: parsedData['email'],
          phone: parsedData['phone'],
          website: parsedData['website'],
          address: parsedData['address'],
          linkedin: parsedData['linkedin'],
          socialHandles: Map<String, String>.from(
            parsedData['socialHandles'] ?? {},
          ),
          folderId: 'default',
          frontImagePath: currentState.frontImage!.path,
          backImagePath: currentState.backImage?.path,
          createdAt: DateTime.now(),
        );

        emit(ScannerSuccess(contact));
      } catch (e) {
        emit(ScannerError("Analysis failed: ${e.toString()}"));
      }
    });

    on<ResetScanner>((event, emit) {
      emit(ScannerInitial());
    });
  }
}
