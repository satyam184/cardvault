import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../utils/injection.dart';
import '../utils/connectivity_service.dart';
import 'glass_card.dart';

class ConnectivityWrapper extends StatelessWidget {
  final Widget child;

  const ConnectivityWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final connectivityService = sl<ConnectivityService>();

    return ValueListenableBuilder<bool>(
      valueListenable: connectivityService,
      builder: (context, isConnected, _) {
        if (!isConnected) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.bottomRight,
                  radius: 1.5,
                  colors: [
                    AppColors.secondary.withValues(alpha: 0.05),
                    AppColors.background,
                  ],
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated Pulsing Wi-Fi Off Icon
                      Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.05),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.error.withValues(alpha: 0.1),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(
                          LucideIcons.wifiOff,
                          size: 64,
                          color: AppColors.error,
                        ),
                      )
                          .animate(onPlay: (controller) => controller.repeat(reverse: true))
                          .scale(
                            begin: const Offset(1, 1),
                            end: const Offset(1.08, 1.08),
                            duration: 1.5.seconds,
                            curve: Curves.easeInOut,
                          ),
                      const SizedBox(height: 40),

                      // Connection Lost Title
                      Text(
                        'Connection Lost',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                      ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2),
                      const SizedBox(height: 16),

                      // Informative Subtitle
                      Text(
                        'Your device is offline. Please check your internet connection. We will automatically reconnect you when you\'re back online.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.5,
                              fontSize: 15,
                            ),
                      ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                      const SizedBox(height: 40),

                      // Glassmorphic Manual Retry Button
                      GestureDetector(
                        onTap: () async {
                          await connectivityService.checkConnection();
                        },
                        child: GlassCard(
                          borderRadius: 16,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                LucideIcons.refreshCw,
                                color: Colors.white,
                                size: 20,
                              ).animate(onPlay: (controller) => controller.repeat())
                              .rotate(duration: 2.seconds),
                              const SizedBox(width: 12),
                              const Text(
                                'Retry Connection',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
                      const SizedBox(height: 24),

                      // Small status text
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.amber,
                              shape: BoxShape.circle,
                            ),
                          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                          .scale(begin: const Offset(1, 1), end: const Offset(1.5, 1.5), duration: 800.ms),
                          const SizedBox(width: 8),
                          const Text(
                            'Waiting for network...',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 600.ms),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return child;
      },
    );
  }
}
