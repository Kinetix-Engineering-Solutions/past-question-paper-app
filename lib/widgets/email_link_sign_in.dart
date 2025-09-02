import 'package:flutter/material.dart';
import 'package:past_question_paper_v1/services/auth_service_firebase.dart';

class EmailLinkSignIn extends StatefulWidget {
  final AuthServiceFirebase authService;

  const EmailLinkSignIn({super.key, required this.authService});

  @override
  State<EmailLinkSignIn> createState() => _EmailLinkSignInState();
}

class _EmailLinkSignInState extends State<EmailLinkSignIn> {
  final _emailController = TextEditingController();
  bool _isSending = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendSignInLink() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter an email address';
      });
      return;
    }

    setState(() {
      _isSending = true;
      _errorMessage = null;
    });

    try {
      await widget.authService.sendSignInLinkToEmail(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sign-in link has been sent to your email'),
            backgroundColor: Colors.green,
          ),
        );
        _emailController.clear();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to send sign-in link: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Sign in with Email Link',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'Enter your email address',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            errorText: _errorMessage,
          ),
          keyboardType: TextInputType.emailAddress,
          enabled: !_isSending,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSending ? null : _sendSignInLink,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isSending
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Send Sign-in Link'),
          ),
        ),
        if (!_isSending) ...[
          const SizedBox(height: 8),
          const Text(
            'A sign-in link will be sent to your email',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ],
    );
  }
}
