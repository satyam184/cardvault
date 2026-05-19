import 'package:camera/camera.dart';
import 'package:cardvault/core/utils/business_card_parser.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'bloc/scanner_bloc.dart';
import 'bloc/scanner_event.dart';
import 'bloc/scanner_state.dart';
import 'widgets/camera_overlay.dart';
import 'result_screen.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/ocr_service.dart';
import '../../core/utils/ai_service.dart';
import '../../core/utils/injection.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  CameraController? _controller;
  final _isInitialized = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _controller = CameraController(
      cameras[0],
      ResolutionPreset.high,
      enableAudio: false,
    );
    await _controller!.initialize();
    if (mounted) {
      _isInitialized.value = true;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _isInitialized.dispose();
    super.dispose();
  }

  Future<void> _capture(BuildContext context, ScannerState state) async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    final bloc = context.read<ScannerBloc>();
    final image = await _controller!.takePicture();
    if (!mounted) return;

    bool capturingFront = true;
    if (state is ScannerCapturing) {
      capturingFront = !state.isFrontCaptured;
    }

    if (capturingFront) {
      bloc.add(CaptureFront(image));
    } else {
      bloc.add(CaptureBack(image));
    }
  }

  Future<void> _selectFromGallery(
    BuildContext context,
    ScannerState state,
  ) async {
    final bloc = context.read<ScannerBloc>();
    final messenger = ScaffoldMessenger.of(context);
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      bool capturingFront = true;
      if (state is ScannerCapturing) {
        capturingFront = !state.isFrontCaptured;
      }

      if (capturingFront) {
        bloc.add(CaptureFront(image));
      } else {
        bloc.add(CaptureBack(image));
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ScannerBloc(
        ocrService: sl<OCRService>(),
        aiService: sl<AIService>(),
        parser: sl<BusinessCardParser>(),
      )..add(ResetScanner()),
      child: BlocConsumer<ScannerBloc, ScannerState>(
        listener: (context, state) {
          if (state is ScannerSuccess) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResultScreen(contact: state.contact),
              ),
            );
          }
          if (state is ScannerError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: [
                ValueListenableBuilder<bool>(
                  valueListenable: _isInitialized,
                  builder: (context, isInitialized, _) {
                    if (isInitialized) {
                      return Positioned.fill(
                        child: CameraPreview(_controller!),
                      );
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),

                const CameraOverlay(),

                ScannerUIOverlay(
                  state: state,
                  onClosePressed: () => Navigator.pop(context),
                  onCapturePressed: () => _capture(context, state),
                  onGalleryPressed: () => _selectFromGallery(context, state),
                  onConfirmPressed: () {
                    context.read<ScannerBloc>().add(StartAnalysis());
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ScannerUIOverlay extends StatelessWidget {
  final ScannerState state;
  final VoidCallback onClosePressed;
  final VoidCallback onCapturePressed;
  final VoidCallback onGalleryPressed;
  final VoidCallback onConfirmPressed;

  const ScannerUIOverlay({
    super.key,
    required this.state,
    required this.onClosePressed,
    required this.onCapturePressed,
    required this.onGalleryPressed,
    required this.onConfirmPressed,
  });

  @override
  Widget build(BuildContext context) {
    bool capturingFront = true;
    final currentState = state;
    if (currentState is ScannerCapturing) {
      capturingFront = !currentState.isFrontCaptured;
    }

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(LucideIcons.x, color: Colors.white),
                  onPressed: onClosePressed,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    capturingFront ? 'Scan Front' : 'Scan Back',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),
          const Spacer(),
          if (state is ScannerAnalyzing)
            AnalyzingOverlay(message: (state as ScannerAnalyzing).message)
          else
            ScannerControls(
              state: state,
              onCapturePressed: onCapturePressed,
              onGalleryPressed: onGalleryPressed,
              onConfirmPressed: onConfirmPressed,
            ),
        ],
      ),
    );
  }
}

class AnalyzingOverlay extends StatelessWidget {
  final String message;

  const AnalyzingOverlay({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: const BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 20),
          Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().slideY(begin: 1);
  }
}

class ScannerControls extends StatelessWidget {
  final ScannerState state;
  final VoidCallback onCapturePressed;
  final VoidCallback onGalleryPressed;
  final VoidCallback onConfirmPressed;

  const ScannerControls({
    super.key,
    required this.state,
    required this.onCapturePressed,
    required this.onGalleryPressed,
    required this.onConfirmPressed,
  });

  @override
  Widget build(BuildContext context) {
    bool isFrontCaptured = false;
    bool isBackCaptured = false;
    final currentState = state;
    if (currentState is ScannerCapturing) {
      isFrontCaptured = currentState.isFrontCaptured;
      isBackCaptured = currentState.isBackCaptured;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ThumbnailPreview(label: 'Front', isCaptured: isFrontCaptured),
              const SizedBox(width: 20),
              ThumbnailPreview(label: 'Back', isCaptured: isBackCaptured),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(
                  LucideIcons.image,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: onGalleryPressed,
              ),
              GestureDetector(
                onTap: onCapturePressed,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Center(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
              if (isFrontCaptured)
                IconButton(
                  icon: const Icon(
                    LucideIcons.check,
                    color: AppColors.primary,
                    size: 30,
                  ),
                  onPressed: onConfirmPressed,
                )
              else
                const SizedBox(width: 48),
            ],
          ),
        ],
      ),
    );
  }
}

class ThumbnailPreview extends StatelessWidget {
  final String label;
  final bool isCaptured;

  const ThumbnailPreview({
    super.key,
    required this.label,
    required this.isCaptured,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 40,
          decoration: BoxDecoration(
            color: isCaptured
                ? AppColors.primary.withValues(alpha: 0.5)
                : Colors.white10,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isCaptured ? AppColors.primary : Colors.white24,
            ),
          ),
          child: Icon(
            isCaptured ? LucideIcons.check : LucideIcons.camera,
            color: isCaptured ? Colors.white : Colors.white24,
            size: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
      ],
    );
  }
}
