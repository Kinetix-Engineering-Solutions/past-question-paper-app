import 'grade.dart';

class AppUser {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final Grade selectedGrade;

  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isProfileComplete;

  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.selectedGrade,

    required this.createdAt,
    required this.updatedAt,
    required this.isProfileComplete,
  });

  // Copy with method for updating user data
  AppUser copyWith({
    String? email,
    String? displayName,
    String? photoUrl,
    Grade? selectedGrade,

    DateTime? updatedAt,
    bool? isProfileComplete,
  }) {
    return AppUser(
      id: id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      selectedGrade: selectedGrade ?? this.selectedGrade,

      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
    );
  }

  // Convert AppUser instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'selectedGrade': selectedGrade.toJson(),

      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isProfileComplete': isProfileComplete,
    };
  }

  // Create AppUser from JSON
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      email: json['email'],
      displayName: json['displayName'],
      photoUrl: json['photoUrl'],
      selectedGrade: Grade.fromJson(json['selectedGrade']),

      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isProfileComplete: json['isProfileComplete'],
    );
  }
}
