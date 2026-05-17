import 'package:flutter/material.dart';

class CameraOverlay extends StatelessWidget {
  const CameraOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cardWidth = size.width * 0.85;
    final cardHeight = cardWidth / 1.586; // ID-1 standard ratio

    return Stack(
      children: [
        // Darkened background with hole
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.5),
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: cardWidth,
                  height: cardHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Border
        Align(
          alignment: Alignment.center,
          child: Container(
            width: cardWidth,
            height: cardHeight,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                _buildCorner(top: 0, left: 0),
                _buildCorner(top: 0, right: 0),
                _buildCorner(bottom: 0, left: 0),
                _buildCorner(bottom: 0, right: 0),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCorner({double? top, double? bottom, double? left, double? right}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: top != null && left != null ? const Radius.circular(5) : Radius.zero,
            topRight: top != null && right != null ? const Radius.circular(5) : Radius.zero,
            bottomLeft: bottom != null && left != null ? const Radius.circular(5) : Radius.zero,
            bottomRight: bottom != null && right != null ? const Radius.circular(5) : Radius.zero,
          ),
        ),
      ),
    );
  }
}
