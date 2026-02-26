import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:past_question_paper_v1/services/auth_service_firebase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:past_question_paper_v1/views/home_screen.dart';

class DeepLinkHandler {
  static const String _emailForSignInKey = 'email_for_link_sign_in';
  final AuthServiceFirebase _authService;
  final BuildContext? context;
  static const MethodChannel _channel = MethodChannel(
    'app.channel.shared.data',
  );

  DeepLinkHandler(this._authService, {this.context});

  Future<void> handleIncomingLinks() async {
    try {
      // Set up method channel to receive links from platform
      _channel.setMethodCallHandler((MethodCall call) async {
        switch (call.method) {
          case 'initialLink':
          case 'onLink':
            final String? link = call.arguments as String?;
            if (link != null) {
              await _handleLink(link);
            }
            break;
        }
      });

      // Check for initial link when app starts
      try {
        final String? initialLink = await _channel.invokeMethod(
          'getInitialLink',
        );
        if (initialLink != null) {
          await _handleLink(initialLink);
        }
      } on PlatformException catch (e) {
        print('Error getting initial link: ${e.message}');
      }
    } on PlatformException catch (e) {
      print('Error setting up link handling: ${e.message}');
    }
  }

  Future<void> _handleLink(String link) async {
    print('DeepLinkHandler: Processing link: $link');

    if (_authService.isSignInWithEmailLink(link)) {
      print('DeepLinkHandler: Valid email sign-in link detected');
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString(_emailForSignInKey);

      print('DeepLinkHandler: Retrieved email from storage: $email');

      if (email != null) {
        try {
          print('DeepLinkHandler: Attempting sign-in with email: $email');
          await _authService.signInWithEmailLink(email, link);
          // Clear stored email after successful sign-in
          await prefs.remove(_emailForSignInKey);
          print('DeepLinkHandler: Sign-in successful, navigating to home');

          // Navigate to home screen after successful sign-in
          if (context != null && context!.mounted) {
            Navigator.of(context!).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
            );
          }
        } catch (e) {
          print('Error signing in with email link: $e');
          // Show error message to user if context is available
          if (context != null && context!.mounted) {
            ScaffoldMessenger.of(context!).showSnackBar(
              SnackBar(
                content: Text('Sign-in failed: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        // Handle case where email is not found
        print('No email found for sign-in link');
        if (context != null && context!.mounted) {
          ScaffoldMessenger.of(context!).showSnackBar(
            const SnackBar(
              content: Text('Email not found. Please try signing in again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      print('DeepLinkHandler: Link is not a valid email sign-in link');
    }
  }
}
