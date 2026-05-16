import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../scanner/scanner_screen.dart';

class DashboardFAB extends StatelessWidget {
  const DashboardFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ScannerScreen()),
        );
      },
      backgroundColor: AppColors.primary,
      label: const Text('Scan Card'),
      icon: const Icon(LucideIcons.scan),
    ).animate().scaleXY(delay: 500.ms, begin: 0, curve: Curves.elasticOut);
  }
}
