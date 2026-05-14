import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

abstract class ScannerEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CaptureFront extends ScannerEvent {
  final XFile image;
  CaptureFront(this.image);
  @override
  List<Object?> get props => [image];
}

class CaptureBack extends ScannerEvent {
  final XFile image;
  CaptureBack(this.image);
  @override
  List<Object?> get props => [image];
}

class StartAnalysis extends ScannerEvent {}

class ResetScanner extends ScannerEvent {}
