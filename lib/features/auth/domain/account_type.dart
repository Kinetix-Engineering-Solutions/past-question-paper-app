enum AccountType {
  adultLearner('adult_learner'),
  guardianManagedLearner('guardian_managed_learner');

  const AccountType(this.apiValue);

  final String apiValue;

  static AccountType fromApiValue(String value) {
    return switch (value) {
      'adult_learner' => AccountType.adultLearner,
      'guardian_managed_learner' => AccountType.guardianManagedLearner,
      _ => throw FormatException('Unknown account type: $value'),
    };
  }
}
