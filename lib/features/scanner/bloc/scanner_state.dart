import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/contact_model.dart';

abstract class ScannerState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ScannerInitial extends ScannerState {}

class ScannerCapturing extends ScannerState {
  final XFile? frontImage;
  final XFile? backImage;
  final bool isFrontCaptured;
  final bool isBackCaptured;

  ScannerCapturing({
    this.frontImage,
    this.backImage,
    this.isFrontCaptured = false,
    this.isBackCaptured = false,
  });

  @override
  List<Object?> get props => [frontImage, backImage, isFrontCaptured, isBackCaptured];
}

class ScannerAnalyzing extends ScannerState {
  final String message;
  ScannerAnalyzing(this.message);
  @override
  List<Object?> get props => [message];
}

class ScannerSuccess extends ScannerState {
  final BusinessContact contact;
  ScannerSuccess(this.contact);
  @override
  List<Object?> get props => [contact];
}

class ScannerError extends ScannerState {
  final String message;
  ScannerError(this.message);
  @override
  List<Object?> get props => [message];
}
