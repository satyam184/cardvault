import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../auth/bloc/auth_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final logoSize = isTablet ? 100.0 : 60.0;
    final fontSize = isTablet ? 48.0 : 32.0;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        // We still want a minimum delay for the premium splash feel
        await Future.delayed(const Duration(milliseconds: 1500));

        if (state.status == AuthStatus.authenticated) {
          if (context.mounted) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          }
        } else if (state.status == AuthStatus.unauthenticated) {
          if (context.mounted) {
            Navigator.pushReplacementNamed(context, '/auth');
          }
        }
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(color: AppColors.background),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background Glow
              Container(
                    width: isTablet ? 300 : 200,
                    height: isTablet ? 300 : 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          blurRadius: isTablet ? 150 : 100,
                          spreadRadius: isTablet ? 75 : 50,
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
                        padding: EdgeInsets.all(isTablet ? 30 : 20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(
                            isTablet ? 32 : 24,
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.05),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.account_balance_wallet_outlined,
                          size: logoSize,
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
                        style: Theme.of(context).textTheme.displayLarge
                            ?.copyWith(
                              fontSize: fontSize,
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
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary.withValues(alpha: 0.7),
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
      ),
    );
  }
}
