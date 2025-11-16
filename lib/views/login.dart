import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/utils/app_colors.dart';
import 'package:past_question_paper_v1/utils/loading_state.dart';
import 'package:past_question_paper_v1/viewmodels/auth_viewmodel.dart';
import 'package:past_question_paper_v1/views/signup_screen.dart';
import 'package:past_question_paper_v1/views/forgot_password_screen.dart';
import 'package:past_question_paper_v1/widgets/message_banner.dart';
import 'package:past_question_paper_v1/utils/form_validators.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _navigateToSignUp() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SignUpScreen()),
      );
    }
  }

  void _handleLogin() {
    ref
        .read(authViewModelProvider.notifier)
        .signInUserInUI(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          context: context,
          formKey: _formKey,
        );
  }

  void _handleForgotPassword() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ForgotPasswordScreen(),
      ),
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
                          'Past Question Papers',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.ink,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sign in to continue your practice',
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
                    validator: FormValidators.validatePassword,
                    enabled: !ref.watch(loadingStateProvider),
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleLogin(),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: ref.watch(loadingStateProvider)
                        ? null
                        : _handleLogin,
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
                            'Login',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.neutralCard,
                            ),
                          ),
                  ),
                  if (!ref.watch(loadingStateProvider)) ...[
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _navigateToSignUp,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.ink,
                      ),
                      child: Text(
                        'Don\'t have an account? Sign Up',
                        style: TextStyle(color: AppColors.ink),
                      ),
                    ),
                    TextButton(
                      onPressed: _handleForgotPassword,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.neutralMid,
                      ),
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(color: AppColors.neutralMid),
                      ),
                    ),
                    /* const Text('Or sign in with', textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: EmailLinkSignIn(
                    authService:
                        ref.read(authViewModelProvider.notifier).authService,
                  ),
                ), */
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
