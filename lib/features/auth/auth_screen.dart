import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/common_widgets/glass_card.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.background, AppColors.surface],
                ),
              ),
            ),
          ),
          // Animated Background Circles
          const _AnimatedBackground(),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 50),
                  const Icon(LucideIcons.creditCard, color: AppColors.primary, size: 60)
                      .animate()
                      .fadeIn()
                      .scale(),
                  const SizedBox(height: 20),
                  Text(
                    isLogin ? 'Welcome Back' : 'Create Account',
                    style: Theme.of(context).textTheme.displayLarge,
                  ).animate().fadeIn(delay: 200.ms).slideX(),
                  Text(
                    isLogin ? 'Sign in to continue' : 'Join CardVault today',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 40),
                  
                  _AuthForm(
                    isLogin: isLogin,
                    onSubmitted: () {
                      Navigator.pushReplacementNamed(context, '/dashboard');
                    },
                  ),
                  
                  const SizedBox(height: 30),
                  const _SocialLoginSection(),
                  
                  const SizedBox(height: 30),
                  Center(
                    child: TextButton(
                      onPressed: () => setState(() => isLogin = !isLogin),
                      child: Text(
                        isLogin ? "Don't have an account? Sign Up" : "Already have an account? Login",
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedBackground extends StatelessWidget {
  const _AnimatedBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top Right Glow
        Positioned(
          top: -150,
          right: -150,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withOpacity(0.15),
                  AppColors.primary.withOpacity(0),
                ],
              ),
            ),
          ),
        ),
        // Bottom Left Glow
        Positioned(
          bottom: -200,
          left: -200,
          child: Container(
            width: 500,
            height: 500,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.secondary.withOpacity(0.1),
                  AppColors.secondary.withOpacity(0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AuthForm extends StatelessWidget {
  final bool isLogin;
  final VoidCallback onSubmitted;

  const _AuthForm({required this.isLogin, required this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!isLogin)
          const _CustomTextField(icon: LucideIcons.user, label: 'Full Name')
              .animate()
              .fadeIn()
              .slideY(begin: 0.1),
        const SizedBox(height: 20),
        const _CustomTextField(icon: LucideIcons.mail, label: 'Email Address'),
        const SizedBox(height: 20),
        const _CustomTextField(icon: LucideIcons.lock, label: 'Password', isPassword: true),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: onSubmitted,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
            child: Text(isLogin ? 'Login' : 'Sign Up', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ).animate().fadeIn(delay: 400.ms).scale(),
      ],
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPassword;

  const _CustomTextField({
    required this.icon,
    required this.label,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        obscureText: isPassword,
        decoration: InputDecoration(
          icon: Icon(icon, color: AppColors.primary, size: 20),
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        style: const TextStyle(color: AppColors.textPrimary),
      ),
    );
  }
}

class _SocialLoginSection extends StatelessWidget {
  const _SocialLoginSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          children: [
            Expanded(child: Divider(color: Colors.white10)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('OR', style: TextStyle(color: AppColors.textMuted)),
            ),
            Expanded(child: Divider(color: Colors.white10)),
          ],
        ),
        const SizedBox(height: 30),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SocialButton(icon: LucideIcons.chrome),
            SizedBox(width: 20),
            _SocialButton(icon: LucideIcons.apple),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 500.ms);
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;

  const _SocialButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      width: 60,
      height: 60,
      borderRadius: 15,
      padding: EdgeInsets.zero,
      child: Center(child: Icon(icon, color: Colors.white)),
    );
  }
}
