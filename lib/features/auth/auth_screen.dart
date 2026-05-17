import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/common_widgets/glass_card.dart';
import '../../core/utils/injection.dart';
import '../../core/services/token_storage_service.dart';
import 'bloc/auth_bloc.dart';
import 'bloc/login_bloc.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  bool rememberMe = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRememberedCredentials();
  }

  Future<void> _loadRememberedCredentials() async {
    try {
      final tokenService = sl<TokenStorageService>();
      final isRemembered = await tokenService.getRememberMeStatus();
      setState(() {
        rememberMe = isRemembered;
      });
      if (isRemembered) {
        final email = await tokenService.getSavedEmail();
        final password = await tokenService.getSavedPassword();
        if (email != null) _emailController.text = email;
        if (password != null) _passwordController.text = password;
      }
    } catch (e) {
      debugPrint('DEBUG: Error loading remembered credentials: $e');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final emailResetController = TextEditingController(text: _emailController.text);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Reset Password',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your email address to receive a password reset link.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailResetController,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                labelStyle: TextStyle(color: AppColors.textSecondary),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
              style: const TextStyle(color: AppColors.textPrimary),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Password reset link sent to ${emailResetController.text}'),
                  backgroundColor: AppColors.secondary,
                ),
              );
            },
            child: const Text('Reset', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<LoginBloc>(),
      child: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state.status == LoginStatus.success) {
            // Save remember me details on successful login
            sl<TokenStorageService>().saveRememberMe(
              rememberMe: rememberMe,
              email: _emailController.text,
              password: _passwordController.text,
            );

            context.read<AuthBloc>().add(LoggedIn(state.user!));
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (state.status == LoginStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error ?? 'Authentication failed'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        child: Builder(
          builder: (context) => Scaffold(
            body: Stack(
              children: [
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
                const _AnimatedBackground(),
                SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          const Icon(LucideIcons.creditCard,
                                  color: AppColors.primary, size: 60)
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
                            rememberMe: rememberMe,
                            onRememberMeChanged: (val) {
                              setState(() {
                                rememberMe = val ?? false;
                              });
                            },
                            onForgotPassword: () => _showForgotPasswordDialog(context),
                            emailController: _emailController,
                            passwordController: _passwordController,
                            nameController: _nameController,
                            onSubmitted: () {
                              final bloc = context.read<LoginBloc>();
                              if (isLogin) {
                                bloc.add(LoginSubmitted(
                                  _emailController.text,
                                  _passwordController.text,
                                ));
                              } else {
                                bloc.add(RegisterSubmitted(
                                  _nameController.text,
                                  _emailController.text,
                                  _passwordController.text,
                                ));
                              }
                            },
                          ),
                          
                          // Commented Social Login / Easy Login section
                          /*
                          const SizedBox(height: 30),
                          const _SocialLoginSection(),
                          */
                          
                          const SizedBox(height: 30),
                          Center(
                            child: TextButton(
                              onPressed: () => setState(() => isLogin = !isLogin),
                              child: Text(
                                isLogin
                                    ? "Don't have an account? Sign Up"
                                    : "Already have an account? Login",
                                style:
                                    const TextStyle(color: AppColors.textSecondary),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
  final bool rememberMe;
  final ValueChanged<bool?> onRememberMeChanged;
  final VoidCallback onForgotPassword;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController nameController;
  final VoidCallback onSubmitted;

  const _AuthForm({
    required this.isLogin,
    required this.rememberMe,
    required this.onRememberMeChanged,
    required this.onForgotPassword,
    required this.emailController,
    required this.passwordController,
    required this.nameController,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        return Column(
          children: [
            if (!isLogin)
              _CustomTextField(
                controller: nameController,
                icon: LucideIcons.user,
                label: 'Full Name',
              ).animate().fadeIn().slideY(begin: 0.1),
            const SizedBox(height: 20),
            _CustomTextField(
              controller: emailController,
              icon: LucideIcons.mail,
              label: 'Email Address',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            _CustomTextField(
              controller: passwordController,
              icon: LucideIcons.lock,
              label: 'Password',
              isPassword: true,
            ),
            if (isLogin) ...[
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: rememberMe,
                          onChanged: onRememberMeChanged,
                          activeColor: AppColors.primary,
                          checkColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Remember me',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: onForgotPassword,
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: state.status == LoginStatus.loading ? null : onSubmitted,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: state.status == LoginStatus.loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        isLogin ? 'Login' : 'Sign Up',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ).animate().fadeIn(delay: 400.ms).scale(),
          ],
        );
      },
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String label;
  final bool isPassword;
  final TextInputType? keyboardType;

  const _CustomTextField({
    required this.controller,
    required this.icon,
    required this.label,
    this.isPassword = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
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

/*
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
*/
