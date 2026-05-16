import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() async {
    // Simulate initial loading or just a delay for the premium feel
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: AppColors.background),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background Glow
            Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.15),
                        blurRadius: 100,
                        spreadRadius: 50,
                      ),
                    ],
                  ),
                )
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.2, 1.2),
                  duration: 2.seconds,
                  curve: Curves.easeInOut,
                ),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Container
                Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.05),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        LucideIcons.wallet,
                        size: 60,
                        color: AppColors.primary,
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 800.ms)
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      duration: 800.ms,
                      curve: Curves.easeInOutCubic,
                    )
                    .shimmer(delay: 1200.ms, duration: 1500.ms),

                const SizedBox(height: 24),

                // App Name
                Text(
                      'CardVault',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        letterSpacing: 2,
                        fontWeight: FontWeight.w900,
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 800.ms)
                    .slideY(
                      begin: 0.2,
                      end: 0,
                      duration: 800.ms,
                      curve: Curves.easeOutCubic,
                    ),

                const SizedBox(height: 8),

                // Tagline
                Text(
                  'Your Premium Business Hub',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary.withOpacity(0.7),
                    letterSpacing: 1.2,
                  ),
                ).animate().fadeIn(delay: 800.ms, duration: 800.ms),
              ],
            ),

            // Version Indicator
            Positioned(
              bottom: 40,
              child: Text(
                'v1.0.0',
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: AppColors.textMuted),
              ).animate().fadeIn(delay: 1500.ms),
            ),
          ],
        ),
      ),
    );
  }
}
