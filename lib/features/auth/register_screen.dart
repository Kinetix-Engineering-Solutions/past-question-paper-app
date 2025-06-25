// Register Page
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_textfield.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Fallback route if nothing to pop
            context.go('/login');
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                const FlutterLogo(size: 100),
                const SizedBox(height: 40),
                CustomTextField(
                  controller: nameController,
                  hintText: 'Full Name',
                  validator: (value) => value != null && value.isNotEmpty
                      ? null
                      : 'Enter your name',
                ),
                const SizedBox(height: 20),
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
                  text: 'Create Account',
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
                      if (context.mounted) context.go('/subjects');
                    } else {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Account Creation Failed'),
                          content: const Text(
                              'An error occurred while creating your account.'),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
