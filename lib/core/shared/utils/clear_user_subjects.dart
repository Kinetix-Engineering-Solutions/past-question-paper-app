// Utility script to clear hardcoded subjects for current user
// Run this once if you have hardcoded subjects in your Firestore user document
// Usage: Import and call clearCurrentUserSubjects() once from your app

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> clearCurrentUserSubjects() async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  
  if (userId == null) {
    print('❌ No user logged in');
    return;
  }
  
  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'selectedSubjects': []});
    
    print('✅ Successfully cleared subjects for user: $userId');
  } catch (e) {
    print('❌ Error clearing subjects: $e');
  }
}

Future<void> clearAllUsersSubjects() async {
  try {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    
    int count = 0;
    for (var doc in snapshot.docs) {
      await doc.reference.update({'selectedSubjects': []});
      count++;
    }
    
    print('✅ Successfully cleared subjects for $count users');
  } catch (e) {
    print('❌ Error clearing subjects: $e');
  }
}
