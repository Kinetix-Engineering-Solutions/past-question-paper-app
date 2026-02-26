import 'package:cloud_firestore/cloud_firestore.dart';

/// A simplified, flat user model for the application.
class AppUser {
  final String id;
  final String? email;
  final String? name;

  // --- Personalization fields are now directly on the AppUser model ---
  final int? grade;
  final List<String>? selectedSubjects;

  AppUser({
    required this.id,
    this.email,
    this.name,
    this.grade,
    this.selectedSubjects,
  });

  // Check if user has completed profile setup
  bool get hasCompletedProfile =>
      grade != null && (selectedSubjects?.isNotEmpty ?? false);

  /// Creates an AppUser from a Firestore document snapshot.
  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AppUser(
      id: doc.id,
      email: data['email'],
      name: data['name'],
      grade: data['grade'],
      // Ensure selectedSubjects is always a List<String>
      selectedSubjects: data['selectedSubjects'] != null
          ? List<String>.from(data['selectedSubjects'])
          : [],
    );
  }

  /// Creates a basic AppUser from a Firebase Auth user.
  factory AppUser.fromFirebaseAuth(dynamic firebaseUser) {
    return AppUser(
      id: firebaseUser.uid,
      email: firebaseUser.email,
      name: firebaseUser.displayName,
      // Preferences will be null for a new user until they are set
      grade: null,
      selectedSubjects: [],
    );
  }

  /// Converts an AppUser instance to a map for Firestore.
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'grade': grade,
      'selectedSubjects': selectedSubjects,
    };
  }

  /// Creates a copy of the user with updated values.
  AppUser copyWith({
    String? id,
    String? email,
    String? name,
    int? grade,
    List<String>? selectedSubjects,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      grade: grade ?? this.grade,
      selectedSubjects: selectedSubjects ?? this.selectedSubjects,
    );
  }
}
