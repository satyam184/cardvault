import 'dart:ui';

class OcrBlock {
  final String text;
  final Rect rect;
  final double width;
  final double height;
  final double area;
  final double centerX;
  final double centerY;
  OcrBlock({required this.text, required this.rect})
    : width = rect.width,
      height = rect.height,
      area = rect.width * rect.height,
      centerX = rect.center.dx,
      centerY = rect.center.dy;
}
