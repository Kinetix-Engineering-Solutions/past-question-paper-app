import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_theme.dart';
import '../providers/auth_providers.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();

  bool _createAccount = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final action = ref.watch(authActionControllerProvider);

    final errorMessage = action.when(
      data: (_) => null,
      loading: () => null,
      error: (error, _) => _messageFor(error),
    );

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          children: [
            Center(
              child: Image.asset(
                'assets/branding/splash_logo.png',
                width: 88,
                height: 88,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _createAccount ? 'Create your account' : 'Welcome back',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _createAccount
                  ? 'Save questions and track your progress.'
                  : 'Sign in to access your saved learning.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(
                      labelText: 'Email address',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      final email = value?.trim() ?? '';

                      if (!email.contains('@') || !email.contains('.')) {
                        return 'Enter a valid email address.';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: _createAccount
                        ? TextInputAction.next
                        : TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    onFieldSubmitted: (_) {
                      if (!_createAccount) {
                        _submit();
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if ((value ?? '').length < 8) {
                        return 'Use at least 8 characters.';
                      }

                      return null;
                    },
                  ),
                  if (_createAccount) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmationController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'Confirm password',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Passwords do not match.';
                        }

                        return null;
                      },
                      onFieldSubmitted: (_) => _submit(),
                    ),
                  ],
                ],
              ),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: action.isLoading ? null : _submit,
              child: action.isLoading
                  ? const SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(_createAccount ? 'Create account' : 'Sign in'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: action.isLoading
                  ? null
                  : () {
                      setState(() {
                        _createAccount = !_createAccount;
                      });
                    },
              child: Text(
                _createAccount
                    ? 'Already have an account? Sign in'
                    : 'New here? Create an account',
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: action.isLoading
                  ? null
                  : () => Navigator.of(context).pop(),
              child: const Text('Continue as guest'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final controller = ref.read(authActionControllerProvider.notifier);

    if (_createAccount) {
      final result = await controller.signUp(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted || result == null) {
        return;
      }

      if (result.requiresEmailConfirmation) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check your email to confirm your account.'),
          ),
        );
      }

      Navigator.of(context).pop();
      return;
    }

    await controller.signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    final state = ref.read(authActionControllerProvider);

    if (!state.hasError) {
      Navigator.of(context).pop();
    }
  }

  String _messageFor(Object error) {
    if (error is AuthException) {
      final message = error.message.toLowerCase();

      if (message.contains('invalid login')) {
        return 'Incorrect email address or password.';
      }

      if (message.contains('email not confirmed')) {
        return 'Confirm your email before signing in.';
      }

      if (message.contains('already registered')) {
        return 'An account already exists for this email.';
      }

      return error.message;
    }

    return 'Something went wrong. Please try again.';
  }
}
