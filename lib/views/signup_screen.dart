import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      appBar: AppBar(title: const Text('Sign Up')),
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
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: FormValidators.validateEmail,
                enabled: !ref.watch(loadingStateProvider),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
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
                child:
                    ref.watch(loadingStateProvider)
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text('Sign Up'),
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
                  child: const Text('Already have an account? Log in'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
