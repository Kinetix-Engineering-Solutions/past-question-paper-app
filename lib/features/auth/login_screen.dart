// Login Page
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_textfield.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                const FlutterLogo(size: 100), // Placeholder logo
                const SizedBox(height: 40),
                CustomTextField(
                  controller: emailController,
                  hintText: 'Email Address',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    final emailRegex =
                        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    } else if (!emailRegex.hasMatch(value)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),
                CustomTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                  validator: (value) => value != null && value.length >= 6
                      ? null
                      : 'Minimum 6 characters',
                ),
                const SizedBox(height: 30),
                CustomButton(
                  text: 'Login',
                  width: double.infinity,
                  isLoading: _isLoading,
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _isLoading = true;
                      });

                      // Simulate login delay
                      await Future.delayed(const Duration(seconds: 2));

                      setState(() {
                        _isLoading = false;
                      });

                      // Navigate after "successful" login
                      if (context.mounted) context.go('/dashboard');
                    } else {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Login Failed'),
                          content: const Text(
                              'Invalid email or password. Please try again.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),

                const SizedBox(height: 20),
                CustomButton(
                  text: 'Login with Google',
                  width: double.infinity,
                  icon: Icons.login,
                  isOutlined: true,
                  onPressed: () {},
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => context.go('/forgot-password'),
                  child: const Text('Forgot Password?'),
                ),
                TextButton(
                  onPressed: () => context.go('/register'),
                  child: const Text('Create Account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
