import 'app_user.dart';

final class SignUpResult {
  const SignUpResult({
    required this.user,
    required this.requiresEmailConfirmation,
  });

  final AppUser user;
  final bool requiresEmailConfirmation;
}
