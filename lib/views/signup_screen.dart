import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/utils/app_colors.dart';
import 'package:past_question_paper_v1/utils/loading_state.dart';
import 'package:past_question_paper_v1/viewmodels/auth_viewmodel.dart';
import 'package:past_question_paper_v1/views/login.dart';
import 'package:past_question_paper_v1/widgets/custom_snackbar.dart';
import 'package:past_question_paper_v1/widgets/message_banner.dart';
import 'package:past_question_paper_v1/utils/form_validators.dart';
import 'package:url_launcher/url_launcher.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _passwordStrength = '';
  Color _passwordStrengthColor = Colors.grey;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _checkPasswordStrength(String password) {
    if (password.isEmpty) {
      setState(() {
        _passwordStrength = '';
        _passwordStrengthColor = Colors.grey;
      });
      return;
    }

    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[a-z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;

    setState(() {
      if (strength <= 2) {
        _passwordStrength = 'Weak';
        _passwordStrengthColor = Colors.red;
      } else if (strength <= 4) {
        _passwordStrength = 'Medium';
        _passwordStrengthColor = Colors.orange;
      } else {
        _passwordStrength = 'Strong';
        _passwordStrengthColor = Colors.green;
      }
    });
  }

  void _navigateToLogin() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _handleSignUp() {
    ref
        .read(authViewModelProvider.notifier)
        .signUpUserInUI(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          context: context,
          formKey: _formKey,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Title
                  Container(
                    margin: const EdgeInsets.only(bottom: 40),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/past question paper.png',
                          height: 120,
                          width: 120,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.ink,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Join us to start your STEM practice journey',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.neutralMid,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  // Error message display
                  ref.watch(authViewModelProvider).whenOrNull(
                    error: (error, stackTrace) => MessageBanner(
                      message: error.toString(),
                      isError: true,
                    ),
                  ) ?? const SizedBox.shrink(),
                  TextFormField(
                    controller: _emailController,
                    style: TextStyle(color: AppColors.ink),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: AppColors.neutralMid),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.neutralBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.neutralBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.accent,
                          width: 2,
                        ),
                      ),
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: AppColors.neutralMid,
                      ),
                      fillColor: AppColors.neutralCard,
                      filled: true,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: FormValidators.validateEmail,
                    enabled: !ref.watch(loadingStateProvider),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    style: TextStyle(color: AppColors.ink),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: AppColors.neutralMid),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.neutralBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.neutralBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.accent,
                          width: 2,
                        ),
                      ),
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: AppColors.neutralMid,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: AppColors.neutralMid,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      fillColor: AppColors.neutralCard,
                      filled: true,
                    ),
                    obscureText: _obscurePassword,
                    validator: (value) {
                      // First run the standard password validation
                      final standardValidation = FormValidators.validatePassword(value);
                      if (standardValidation != null) return standardValidation;

                      // Then check password strength
                      if (_passwordStrength == 'Weak') {
                        return 'Please use a stronger password with uppercase, lowercase, numbers, and special characters';
                      }
                      return null;
                    },
                    enabled: !ref.watch(loadingStateProvider),
                    textInputAction: TextInputAction.next,
                    onChanged: _checkPasswordStrength,
                  ),
                  if (_passwordStrength.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const SizedBox(width: 12),
                        Text(
                          'Password strength: ',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.neutralMid,
                          ),
                        ),
                        Text(
                          _passwordStrength,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _passwordStrengthColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    style: TextStyle(color: AppColors.ink),
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      labelStyle: TextStyle(color: AppColors.neutralMid),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.neutralBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.neutralBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.accent,
                          width: 2,
                        ),
                      ),
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: AppColors.neutralMid,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: AppColors.neutralMid,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      fillColor: AppColors.neutralCard,
                      filled: true,
                    ),
                    obscureText: _obscureConfirmPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    enabled: !ref.watch(loadingStateProvider),
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleSignUp(),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: ref.watch(loadingStateProvider)
                        ? null
                        : _handleSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.neutralCard,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: ref.watch(loadingStateProvider)
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.neutralCard,
                              ),
                            ),
                          )
                        : Text(
                            'Sign Up',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.neutralCard,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  // Privacy Policy Notice
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.neutralMid,
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(
                            text: 'By signing up, you agree to our ',
                          ),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(
                              color: AppColors.accent,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w500,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                try {
                                  final uri = Uri.parse(
                                    'https://pqp.kinetixes.com/privacy-policy/',
                                  );
                                  await launchUrl(
                                    uri,
                                    mode: LaunchMode.externalApplication,
                                  );
                                } catch (e) {
                                  if (mounted) {
                                    CustomSnackBar.show(
                                      context: context,
                                      message: 'Could not open Privacy Policy',
                                      isError: true,
                                    );
                                  }
                                }
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!ref.watch(loadingStateProvider)) ...[
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _navigateToLogin,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.ink,
                      ),
                      child: Text(
                        'Already have an account? Log in',
                        style: TextStyle(color: AppColors.ink),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
