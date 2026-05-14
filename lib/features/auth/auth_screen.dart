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
          _buildAnimatedBg(),
          
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
                  
                  _buildForm(),
                  
                  const SizedBox(height: 30),
                  _buildSocialLogin(),
                  
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

  Widget _buildAnimatedBg() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.1),
            ),
          ).animate(onPlay: (controller) => controller.repeat()).scale(
                begin: const Offset(1, 1),
                end: const Offset(1.2, 1.2),
                duration: 5.seconds,
                curve: Curves.easeInOut,
              ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        if (!isLogin)
          _buildTextField(LucideIcons.user, 'Full Name')
              .animate()
              .fadeIn()
              .slideY(begin: 0.1),
        const SizedBox(height: 20),
        _buildTextField(LucideIcons.mail, 'Email Address'),
        const SizedBox(height: 20),
        _buildTextField(LucideIcons.lock, 'Password', isPassword: true),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: () {
              // Navigate to Dashboard
              Navigator.pushReplacementNamed(context, '/dashboard');
            },
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

  Widget _buildTextField(IconData icon, String label, {bool isPassword = false}) {
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

  Widget _buildSocialLogin() {
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _socialButton(LucideIcons.chrome),
            const SizedBox(width: 20),
            _socialButton(LucideIcons.apple),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _socialButton(IconData icon) {
    return GlassCard(
      width: 60,
      height: 60,
      borderRadius: 15,
      padding: EdgeInsets.zero,
      child: Center(child: Icon(icon, color: Colors.white)),
    );
  }
}
