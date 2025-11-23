import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/utils/app_colors.dart';
import 'package:past_question_paper_v1/services/navigation_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:past_question_paper_v1/widgets/custom_snackbar.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  final String email;

  const EmailVerificationScreen({super.key, required this.email});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  bool _isResending = false;
  bool _isChecking = false;

  Future<void> _resendVerificationEmail() async {
    setState(() {
      _isResending = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();

        if (mounted) {
          CustomSnackBar.show(
            context: context,
            message: 'Verification email sent! Check your inbox.',
            isError: false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(
          context: context,
          message: 'Failed to send verification email. Try again later.',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  Future<void> _checkVerificationStatus() async {
    setState(() {
      _isChecking = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      // If user is signed out, redirect to login
      if (user == null) {
        if (mounted) {
          CustomSnackBar.show(
            context: context,
            message: 'Please sign in again to continue.',
            isError: false,
          );
        }
        await _goBackToLogin();
        return;
      }

      // Reload user to get latest email verification status
      await user.reload();
      final updatedUser = FirebaseAuth.instance.currentUser;

      if (updatedUser != null && updatedUser.emailVerified) {
        if (mounted) {
          CustomSnackBar.show(
            context: context,
            message: 'Email verified successfully! Welcome aboard!',
            isError: false,
          );
        }

        // Navigate to onboarding or home
        await NavigationService.navigateToOnboarding();
      } else {
        if (mounted) {
          CustomSnackBar.show(
            context: context,
            message:
                'Email not verified yet. Please check your inbox and spam folder.',
            isError: true,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(
          context: context,
          message: 'Failed to check verification status. Try again.',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  Future<void> _goBackToLogin() async {
    // Sign out the user
    await FirebaseAuth.instance.signOut();

    if (mounted) {
      // Navigate to login screen
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.ink),
          onPressed: _goBackToLogin,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              Text(
                'Verify Your Email',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                'We\'ve sent a verification link to:',
                style: TextStyle(fontSize: 16, color: AppColors.neutralMid),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Email address
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.neutralCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.neutralBorder),
                ),
                child: Text(
                  widget.email,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),

              // Spam folder reminder
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.accent, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Please check your inbox and spam folder for the verification link.',
                        style: TextStyle(fontSize: 14, color: AppColors.ink),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Check verification button
              ElevatedButton(
                onPressed: _isChecking ? null : _checkVerificationStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.neutralCard,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isChecking
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
                        'I\'ve Verified My Email',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.neutralCard,
                        ),
                      ),
              ),
              const SizedBox(height: 16),

              // Resend email button
              OutlinedButton(
                onPressed: _isResending ? null : _resendVerificationEmail,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accent,
                  side: BorderSide(color: AppColors.accent, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isResending
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.accent,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.refresh, color: AppColors.accent),
                          const SizedBox(width: 8),
                          Text(
                            'Resend Verification Email',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 16),

              // Back to login button
              TextButton(
                onPressed: _goBackToLogin,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.neutralMid,
                ),
                child: Text(
                  'Back to Login',
                  style: TextStyle(fontSize: 14, color: AppColors.neutralMid),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
