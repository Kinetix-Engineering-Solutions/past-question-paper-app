import 'account_type.dart';

final class AccountDeclaration {
  const AccountDeclaration({
    required this.accountType,
    required this.declarationVersion,
    required this.acceptedAt,
  });

  final AccountType accountType;
  final String declarationVersion;
  final DateTime acceptedAt;

  factory AccountDeclaration.fromJson(Map<String, dynamic> json) {
    final accountType = json['account_type'];
    final declarationVersion = json['declaration_version'];
    final acceptedAt = json['accepted_at'];

    if (accountType is! String ||
        declarationVersion is! String ||
        declarationVersion.isEmpty ||
        acceptedAt is! String) {
      throw const FormatException('Invalid account declaration response.');
    }

    return AccountDeclaration(
      accountType: AccountType.fromApiValue(accountType),
      declarationVersion: declarationVersion,
      acceptedAt: DateTime.parse(acceptedAt),
    );
  }
}
