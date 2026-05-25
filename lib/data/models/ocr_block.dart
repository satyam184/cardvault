import 'dart:ui';

class OcrBlock {
  final String text;
  final Rect rect;
  final double width;
  final double height;
  final double area;
  final double centerX;
  final double centerY;
  final FontWeight fontWeight;
  final bool isBold;
  OcrBlock({
    required this.text,
    required this.rect,
    this.fontWeight = FontWeight.normal,
  }) : width = rect.width,
       height = rect.height,
       area = rect.width * rect.height,
       centerX = rect.center.dx,
       centerY = rect.center.dy,
       isBold = fontWeight.value >= FontWeight.w600.value;
}
