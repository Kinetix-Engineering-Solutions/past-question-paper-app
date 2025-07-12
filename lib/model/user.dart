class AppUser {
  final String id;
  final String email;
  final UserProfile? profile;

  AppUser({required this.id, required this.email, this.profile});

  // Check if user has completed profile setup
  bool get hasCompletedProfile => profile != null;

  // Copy with method
  AppUser copyWith({String? id, String? email, UserProfile? profile}) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      profile: profile ?? this.profile,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'profile': profile?.toJson()};
  }

  // Create from JSON
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String,
      profile:
          json['profile'] != null
              ? UserProfile.fromJson(json['profile'] as Map<String, dynamic>)
              : null,
    );
  }
}

class UserProfile {
  final String? firstName;
  final String? lastName;
  final String? schoolName;
  final String gradeId;
  final List<String> subjectIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    this.firstName,
    this.lastName,
    this.schoolName,
    required this.gradeId,
    required this.subjectIds,
    required this.createdAt,
    required this.updatedAt,
  });

  // Get display name
  String get displayName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    }
    return 'Student';
  }

  // Copy with method
  UserProfile copyWith({
    String? firstName,
    String? lastName,
    String? schoolName,
    String? gradeId,
    List<String>? subjectIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      schoolName: schoolName ?? this.schoolName,
      gradeId: gradeId ?? this.gradeId,
      subjectIds: subjectIds ?? this.subjectIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'schoolName': schoolName,
      'gradeId': gradeId,
      'subjectIds': subjectIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      schoolName: json['schoolName'] as String?,
      gradeId: json['gradeId'] as String,
      subjectIds: List<String>.from(json['subjectIds'] ?? []),
      createdAt:
          json['createdAt'] is DateTime
              ? json['createdAt']
              : DateTime.parse(json['createdAt'] as String),
      updatedAt:
          json['updatedAt'] is DateTime
              ? json['updatedAt']
              : DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          firstName == other.firstName &&
          lastName == other.lastName &&
          schoolName == other.schoolName &&
          gradeId == other.gradeId;

  @override
  int get hashCode =>
      firstName.hashCode ^
      lastName.hashCode ^
      schoolName.hashCode ^
      gradeId.hashCode;
}
