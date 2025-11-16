import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/utils/app_colors.dart';
import 'package:past_question_paper_v1/utils/loading_state.dart';
import 'package:past_question_paper_v1/viewmodels/auth_viewmodel.dart';
import 'package:past_question_paper_v1/widgets/message_banner.dart';
import 'package:past_question_paper_v1/utils/form_validators.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSendResetEmail() async {
    await ref.read(authViewModelProvider.notifier).sendPasswordResetEmailInUI(
      email: _emailController.text.trim(),
      context: context,
      formKey: _formKey,
    );

    // If no error occurred, mark email as sent
    if (mounted) {
      setState(() {
        _emailSent = true;
      });
    }
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
                  const SizedBox(height: 20),
                  // App Logo
                  Image.asset(
                    'assets/images/past question paper.png',
                    height: 120,
                    width: 120,
                  ),
                  const SizedBox(height: 24),
                  // Title
                  Text(
                    _emailSent ? 'Check Your Email' : 'Forgot Password?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  // Subtitle
                  Text(
                    _emailSent
                        ? 'We\'ve sent password reset instructions to your email address.'
                        : 'Enter your email address and we\'ll send you instructions to reset your password.',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.neutralMid,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Success message display
                  if (_emailSent)
                    MessageBanner(
                      message: 'Password reset email sent successfully!',
                      isError: false,
                    ),

                  // Error message display
                  ref.watch(authViewModelProvider).whenOrNull(
                    error: (error, stackTrace) => MessageBanner(
                      message: error.toString(),
                      isError: true,
                    ),
                  ) ?? const SizedBox.shrink(),

                  // Email field
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
                    enabled: !ref.watch(loadingStateProvider) && !_emailSent,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleSendResetEmail(),
                  ),
                  const SizedBox(height: 24),

                  // Send button
                  ElevatedButton(
                    onPressed: (ref.watch(loadingStateProvider) || _emailSent)
                        ? null
                        : _handleSendResetEmail,
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
                            _emailSent ? 'Email Sent' : 'Send Reset Link',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.neutralCard,
                            ),
                          ),
                  ),

                  if (_emailSent) ...[
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _emailSent = false;
                          _emailController.clear();
                        });
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.ink,
                      ),
                      child: Text(
                        'Try another email',
                        style: TextStyle(color: AppColors.ink),
                      ),
                    ),
                  ],

                  if (!ref.watch(loadingStateProvider) && !_emailSent) ...[
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.neutralMid,
                      ),
                      child: Text(
                        'Back to Login',
                        style: TextStyle(color: AppColors.neutralMid),
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
