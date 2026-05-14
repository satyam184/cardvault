import 'package:flutter_bloc/flutter_bloc.dart';
import 'scanner_event.dart';
import 'scanner_state.dart';
import '../../../core/utils/ocr_service.dart';
import '../../../core/utils/ai_service.dart';
import '../../../data/models/contact_model.dart';
import 'package:uuid/uuid.dart';

class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  final OCRService _ocrService;
  final AIService _aiService;

  ScannerBloc({
    required OCRService ocrService,
    required AIService aiService,
  }) : _ocrService = ocrService,
       _aiService = aiService,
       super(ScannerInitial()) {
    
    on<CaptureFront>((event, emit) {
      final currentState = state;
      if (currentState is ScannerCapturing) {
        emit(ScannerCapturing(
          frontImage: event.image,
          backImage: currentState.backImage,
          isFrontCaptured: true,
          isBackCaptured: currentState.isBackCaptured,
        ));
      } else {
        emit(ScannerCapturing(
          frontImage: event.image,
          isFrontCaptured: true,
        ));
      }
    });

    on<CaptureBack>((event, emit) {
      final currentState = state;
      if (currentState is ScannerCapturing) {
        emit(ScannerCapturing(
          frontImage: currentState.frontImage,
          backImage: event.image,
          isFrontCaptured: currentState.isFrontCaptured,
          isBackCaptured: true,
        ));
      } else {
        emit(ScannerCapturing(
          backImage: event.image,
          isBackCaptured: true,
        ));
      }
    });

    on<StartAnalysis>((event, emit) async {
      final currentState = state;
      if (currentState is! ScannerCapturing || currentState.frontImage == null) {
        emit(ScannerError("Front image is required"));
        return;
      }

      emit(ScannerAnalyzing("Recognizing text from images..."));
      
      try {
        final frontText = await _ocrService.recognizeText(currentState.frontImage!.path);
        String? backText;
        if (currentState.backImage != null) {
          backText = await _ocrService.recognizeText(currentState.backImage!.path);
        }

        emit(ScannerAnalyzing("AI is parsing card details..."));
        
        final parsedData = await _aiService.parseCardText(frontText, backText: backText);
        
        final contact = BusinessContact(
          id: const Uuid().v4(),
          name: parsedData['name'] ?? "Unknown",
          company: parsedData['company'],
          jobTitle: parsedData['jobTitle'],
          email: parsedData['email'],
          phone: parsedData['phone'],
          website: parsedData['website'],
          address: parsedData['address'],
          linkedin: parsedData['linkedin'],
          socialHandles: Map<String, String>.from(parsedData['socialHandles'] ?? {}),
          folderId: 'default', // Default for now
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
