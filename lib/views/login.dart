import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_stem/utils/loading_state.dart';
import 'package:past_question_paper_stem/viewmodels/auth_viewmodel.dart';
import 'package:past_question_paper_stem/views/signup_screen.dart';
import 'package:past_question_paper_stem/widgets/email_link_sign_in.dart';
import 'package:past_question_paper_stem/widgets/custom_snackbar.dart';
import 'package:past_question_paper_stem/utils/form_validators.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
    ref
        .read(authViewModelProvider.notifier)
        .sendPasswordResetEmailInUI(
          email: _emailController.text.trim(),
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
      backgroundColor: const Color(0xFF121212), // Dark background
      appBar: AppBar(
        title: const Text('Login', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  prefixIcon: Icon(Icons.email_outlined, color: Colors.grey),
                  fillColor: Color(0xFF1E1E1E),
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
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  prefixIcon: Icon(Icons.lock_outline, color: Colors.grey),
                  fillColor: Color(0xFF1E1E1E),
                  filled: true,
                ),
                obscureText: true,
                validator: FormValidators.validatePassword,
                enabled: !ref.watch(loadingStateProvider),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _handleLogin(),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed:
                    ref.watch(loadingStateProvider) ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child:
                    ref.watch(loadingStateProvider)
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text('Login'),
              ),
              if (!ref.watch(loadingStateProvider)) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SignUpScreen(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.blue),
                  child: const Text('Don\'t have an account? Sign Up'),
                ),
                TextButton(
                  onPressed: _handleForgotPassword,
                  style: TextButton.styleFrom(foregroundColor: Colors.grey),
                  child: const Text('Forgot Password?'),
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
    );
  }
}
