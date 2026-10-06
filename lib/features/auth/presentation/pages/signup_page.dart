import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../bloc/auth_bloc.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey        = GlobalKey<FormState>();
  final _firstNameCtrl  = TextEditingController();
  final _lastNameCtrl   = TextEditingController();
  final _emailCtrl      = TextEditingController();
  final _passwordCtrl   = TextEditingController();
  bool _obscure    = true;
  bool _isLoading  = false;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(AuthSignupRequested(
            firstName: _firstNameCtrl.text.trim(),
            lastName:  _lastNameCtrl.text.trim(),
            email:     _emailCtrl.text.trim(),
            password:  _passwordCtrl.text,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            setState(() => _isLoading = true);
          } else {
            setState(() => _isLoading = false);
          }

          if (state is AuthFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ));
          }

          // Signup succeeded — navigate back to login so the user signs in.
          if (state is AuthSignupSuccess) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(const SnackBar(
                content: Text('Account created! Please sign in.'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ));
            Navigator.of(context).pop();
          }
        },
        child: Stack(
          children: [
            // Background gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.secondary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Decorative circles
            Positioned(
              top: -60,
              left: -60,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.07),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              right: -80,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  // App bar row
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.white),
                          onPressed: _isLoading
                              ? null
                              : () => Navigator.of(context).pop(),
                        ),
                        Expanded(
                          child: Text('Create Account',
                              style: AppTextStyles.headlineSmall
                                  .copyWith(color: Colors.white),
                              textAlign: TextAlign.center),
                        ),
                        const SizedBox(width: 48), // balance back button
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                          AppConstants.paddingL,
                          AppConstants.paddingM,
                          AppConstants.paddingL,
                          AppConstants.paddingL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Icon
                          Center(
                            child: Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color:
                                        Colors.white.withValues(alpha: 0.4),
                                    width: 2),
                              ),
                              child: const Icon(Icons.person_add_rounded,
                                  size: 36, color: AppColors.gold),
                            )
                                .animate()
                                .fadeIn(duration: 500.ms)
                                .scale(begin: const Offset(0.6, 0.6)),
                          ),
                          const SizedBox(height: 16),
                          Text('Join the Celebration! 🎉',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.center)
                              .animate()
                              .fadeIn(delay: 200.ms),
                          const SizedBox(height: 28),

                          // Form card
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(
                                  AppConstants.radiusXL),
                              boxShadow: const [
                                BoxShadow(
                                    color: AppColors.shadowMedium,
                                    blurRadius: 24,
                                    offset: Offset(0, 8))
                              ],
                            ),
                            padding:
                                const EdgeInsets.all(AppConstants.paddingL),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                children: [
                                  // First Name
                                  TextFormField(
                                    controller: _firstNameCtrl,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    decoration: const InputDecoration(
                                      labelText: 'First Name *',
                                      hintText: 'e.g. Priya',
                                      prefixIcon:
                                          Icon(Icons.person_outline_rounded),
                                    ),
                                    textInputAction: TextInputAction.next,
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty)
                                            ? 'First name is required'
                                            : null,
                                  ),
                                  const SizedBox(height: 16),

                                  // Last Name
                                  TextFormField(
                                    controller: _lastNameCtrl,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    decoration: const InputDecoration(
                                      labelText: 'Last Name *',
                                      hintText: 'e.g. Sharma',
                                      prefixIcon: Icon(Icons.person_outline_rounded),
                                    ),
                                    textInputAction: TextInputAction.next,
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty)
                                            ? 'Last name is required'
                                            : null,
                                  ),
                                  const SizedBox(height: 16),

                                  // Email
                                  TextFormField(
                                    controller: _emailCtrl,
                                    keyboardType:
                                        TextInputType.emailAddress,
                                    decoration: const InputDecoration(
                                      labelText: 'Email *',
                                      hintText: 'you@shutterfly.com',
                                      prefixIcon:
                                          Icon(Icons.email_outlined),
                                    ),
                                    textInputAction: TextInputAction.next,
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return 'Email is required';
                                      }
                                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                          .hasMatch(v.trim())) {
                                        return 'Enter a valid email';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Password — minimum 8 characters
                                  TextFormField(
                                    controller: _passwordCtrl,
                                    obscureText: _obscure,
                                    decoration: InputDecoration(
                                      labelText: 'Password *',
                                      hintText: 'Min. 8 characters',
                                      prefixIcon: const Icon(
                                          Icons.lock_outline_rounded),
                                      suffixIcon: IconButton(
                                        icon: Icon(_obscure
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined),
                                        onPressed: () => setState(
                                            () => _obscure = !_obscure),
                                      ),
                                    ),
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => _submit(),
                                    validator: (v) {
                                      if (v == null || v.isEmpty) {
                                        return 'Password is required';
                                      }
                                      if (v.length < 8) {
                                        return 'Password must be at least 8 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 28),

                                  // Submit button
                                  SizedBox(
                                    height: 52,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _submit,
                                      child: _isLoading
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child:
                                                  CircularProgressIndicator(
                                                      strokeWidth: 2.5,
                                                      color: AppColors
                                                          .textOnPrimary),
                                            )
                                          : const Text('Create Account'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 300.ms, duration: 600.ms)
                              .slideY(begin: 0.15),

                          const SizedBox(height: 24),

                          // Login link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Already have an account?',
                                  style: AppTextStyles.bodySmall.copyWith(
                                      color:
                                          Colors.white.withValues(alpha: 0.8))),
                              TextButton(
                                onPressed: _isLoading
                                    ? null
                                    : () => Navigator.of(context).pop(),
                                child: const Text(
                                  'Sign In',
                                  style: TextStyle(
                                    color: AppColors.gold,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ).animate().fadeIn(delay: 500.ms),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}