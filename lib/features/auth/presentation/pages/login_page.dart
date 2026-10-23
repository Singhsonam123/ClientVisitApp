import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/app_toast.dart';
import '../bloc/auth_bloc.dart';
import 'signup_page.dart';
import '../../../splash/presentation/pages/welcome_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure    = true;
  bool _isLoading  = false;

  void _guestLogin() {
    // Navigate to welcome screen as guest
    context.read<AuthBloc>().add(const AuthGuestRequested());
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => WelcomePage(
          onComplete: () {
            Navigator.of(context).pushReplacementNamed('/home');
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    // Get email and password from input fields
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    // Validate inputs
    if (email.isEmpty || password.isEmpty) {
      AppToast.showError(context, 'Please enter email and password');
      return;
    }

    // Use clean architecture login via use case
    context.read<AuthBloc>().add(AuthCleanLoginRequested(
          email: email,
          password: password,
        ));
  }

  void _goToSignup() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SignupPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            setState(() => _isLoading = true);
          } else if (state is AuthFailure) {
            setState(() => _isLoading = false);
            // Show error message
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) {
                AppToast.showError(context, state.message);
              }
            });
          } else if (state is AuthAuthenticated) {
            setState(() => _isLoading = false);
            // Navigation is handled by main.dart
          } else if (state is AuthUnauthenticated) {
            setState(() => _isLoading = false);
            // Allow user to retry login
          } else {
            setState(() => _isLoading = false);
          }
        },
        child: Stack(
          children: [
            // Background gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Decorative circles
            Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -80,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.paddingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    // Logo
                    Center(
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.4),
                              width: 2),
                        ),
                        child: const Icon(Icons.celebration_rounded,
                            size: 48, color: AppColors.gold),
                      )
                          .animate()
                          .fadeIn(duration: 600.ms)
                          .scale(begin: const Offset(0.5, 0.5)),
                    ),
                    const SizedBox(height: 24),
                    Text(AppConstants.appName,
                            style: AppTextStyles.onboardingTitle,
                            textAlign: TextAlign.center)
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 600.ms)
                        .slideY(begin: 0.3),
                    const SizedBox(height: 8),
                    Text(AppConstants.eventName,
                            style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.white.withValues(alpha: 0.8)),
                            textAlign: TextAlign.center)
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 600.ms),
                    const SizedBox(height: 32),

                    // Form card — animated once on mount, not on state change
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusXL),
                        boxShadow: const [
                          BoxShadow(
                              color: AppColors.shadowMedium,
                              blurRadius: 24,
                              offset: Offset(0, 8))
                        ],
                      ),
                      padding: const EdgeInsets.all(AppConstants.paddingL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Welcome Back 👋',
                              style: AppTextStyles.headlineSmall,
                              textAlign: TextAlign.center),
                          const SizedBox(height: 4),
                          Text('Sign in with your email',
                              style: AppTextStyles.bodySmall,
                              textAlign: TextAlign.center),
                          
                          const SizedBox(height: 28),

                          // Email field
                          TextField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              hintText: 'you@shutterfly.com',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),

                          // Password field
                          TextField(
                            controller: _passwordCtrl,
                            obscureText: _obscure,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: '••••••••',
                              prefixIcon:
                                  const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(_obscure
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                            ),
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _submit(),
                          ),
                          const SizedBox(height: 28),

                          // Guest Login button
                          SizedBox(
                            height: 20,
                            child: GestureDetector(
                              onTap: _guestLogin,
                              child: const Center(child: Text('Continue as Guest',style: TextStyle(color: Color.fromARGB(255, 230, 108, 8), fontSize: 14, fontWeight: FontWeight.w500))),
                            ),
                          ),
                          const SizedBox(height: 15),

                          // Continue button
                          SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _submit,
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: AppColors.textOnPrimary),
                                    )
                                  : const Text('Continue'),
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 500.ms, duration: 700.ms)
                        .slideY(begin: 0.2),

                    const SizedBox(height: 24),

                    // Sign Up link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account?",
                            style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.white.withValues(alpha: 0.8))),
                        TextButton(
                          onPressed: _isLoading ? null : _goToSignup,
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: AppColors.gold,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 700.ms, duration: 600.ms),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}