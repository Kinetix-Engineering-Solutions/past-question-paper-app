import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_stem/utils/app_theme.dart';
import 'package:past_question_paper_stem/utils/loading_state.dart';
import 'package:past_question_paper_stem/viewmodels/auth_viewmodel.dart';
import 'package:past_question_paper_stem/views/login.dart';
import 'package:past_question_paper_stem/widgets/custom_snackbar.dart';
import 'package:past_question_paper_stem/utils/form_validators.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
    // Listen for auth state changes and errors
    ref.listen(authViewModelProvider, (previous, current) {
      current.whenOrNull(
        error: (error, stackTrace) {
          if (mounted) {
            CustomSnackBar.show(
              context: context,
              message: error.toString(),
              isError: true,
            );
          }
        },
      );
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: ChalkboardGradients.spectrum),
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
                        Icon(
                          Icons.person_add,
                          size: 80,
                          color: AppColors.chalkWhite,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.chalkWhite,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Join us to start your STEM practice journey',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.chalkWhite.withOpacity(0.8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  TextFormField(
                    controller: _emailController,
                    style: TextStyle(color: AppColors.chalkWhite),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(
                        color: AppColors.chalkWhite.withOpacity(0.7),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.chalkWhite.withOpacity(0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.chalkWhite.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.chalkWhite,
                          width: 2,
                        ),
                      ),
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: AppColors.chalkWhite.withOpacity(0.7),
                      ),
                      fillColor: AppColors.chalkboard.withOpacity(0.3),
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
                    style: TextStyle(color: AppColors.chalkWhite),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(
                        color: AppColors.chalkWhite.withOpacity(0.7),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.chalkWhite.withOpacity(0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.chalkWhite.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.chalkWhite,
                          width: 2,
                        ),
                      ),
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: AppColors.chalkWhite.withOpacity(0.7),
                      ),
                      fillColor: AppColors.chalkboard.withOpacity(0.3),
                      filled: true,
                    ),
                    obscureText: true,
                    validator: FormValidators.validatePassword,
                    enabled: !ref.watch(loadingStateProvider),
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleSignUp(),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed:
                        ref.watch(loadingStateProvider) ? null : _handleSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.chalkWhite,
                      foregroundColor: AppColors.chalkboard,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child:
                        ref.watch(loadingStateProvider)
                            ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.chalkboard,
                                ),
                              ),
                            )
                            : Text(
                              'Sign Up',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.chalkboard,
                              ),
                            ),
                  ),
                  if (!ref.watch(loadingStateProvider)) ...[
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.chalkWhite,
                      ),
                      child: Text(
                        'Already have an account? Log in',
                        style: TextStyle(color: AppColors.chalkWhite),
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
