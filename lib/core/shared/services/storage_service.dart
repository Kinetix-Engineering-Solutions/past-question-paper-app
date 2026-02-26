import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Upload an image to Firebase Storage
  /// Returns the download URL on success
  Future<String> uploadImage({
    required Uint8List imageBytes,
    required String fileName,
    String folder = 'question_images',
  }) async {
    try {
      // Create a unique file path
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '$folder/${timestamp}_$fileName';

      // Detect content type from file extension
      String contentType = 'image/jpeg'; // Default
      final lowerFileName = fileName.toLowerCase();
      if (lowerFileName.endsWith('.png')) {
        contentType = 'image/png';
      } else if (lowerFileName.endsWith('.jpg') ||
          lowerFileName.endsWith('.jpeg')) {
        contentType = 'image/jpeg';
      } else if (lowerFileName.endsWith('.gif')) {
        contentType = 'image/gif';
      } else if (lowerFileName.endsWith('.webp')) {
        contentType = 'image/webp';
      }

      debugPrint('📤 Uploading to: $filePath');
      debugPrint('📤 Content-Type: $contentType');

      // Log current auth state and token claims to help debug permission issues
      final user = _auth.currentUser;
      if (user == null) {
        debugPrint('⚠️ No authenticated user found when attempting upload.');
      } else {
        debugPrint('🔐 Upload initiated by: ${user.email} (uid: ${user.uid})');
        try {
          final idTokenResult = await user.getIdTokenResult(false);
          debugPrint('🔑 Token claims: ${idTokenResult.claims}');
        } catch (claimErr) {
          debugPrint('⚠️ Failed to fetch token claims: $claimErr');
        }
      }

      // Upload the file
      final ref = _storage.ref().child(filePath);
      final uploadTask = ref.putData(
        imageBytes,
        SettableMetadata(
          contentType: contentType,
          customMetadata: {'uploaded': DateTime.now().toIso8601String()},
        ),
      );

      // Wait for upload to complete
      final snapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      debugPrint('✅ Image uploaded: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('❌ Error uploading image: $e');
      rethrow; // Rethrow to preserve the original error message
    }
  }

  /// Upload a PDF to Firebase Storage
  /// Returns the download URL on success
  Future<String> uploadPDF({
    required Uint8List pdfBytes,
    required String fileName,
    String folder = 'papers',
  }) async {
    try {
      // Create a unique file path
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '$folder/${timestamp}_$fileName';

      debugPrint('📤 Uploading PDF to: $filePath');
      debugPrint('📤 Content-Type: application/pdf');

      // Log current auth state and token claims to help debug permission issues
      final user = _auth.currentUser;
      if (user == null) {
        debugPrint('⚠️ No authenticated user found when attempting upload.');
      } else {
        debugPrint('🔐 Upload initiated by: ${user.email} (uid: ${user.uid})');
        try {
          final idTokenResult = await user.getIdTokenResult(false);
          debugPrint('🔑 Token claims: ${idTokenResult.claims}');
        } catch (claimErr) {
          debugPrint('⚠️ Failed to fetch token claims: $claimErr');
        }
      }

      // Upload the file
      final ref = _storage.ref().child(filePath);
      final uploadTask = ref.putData(
        pdfBytes,
        SettableMetadata(
          contentType: 'application/pdf',
          customMetadata: {'uploaded': DateTime.now().toIso8601String()},
        ),
      );

      // Wait for upload to complete
      final snapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      debugPrint('✅ PDF uploaded: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('❌ Error uploading PDF: $e');
      rethrow; // Rethrow to preserve the original error message
    }
  }

  /// Delete an image from Firebase Storage by URL
  Future<void> deleteImage(String imageUrl) async {
    try {
      // Extract file path from URL
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      debugPrint('✅ Image deleted: $imageUrl');
    } catch (e) {
      debugPrint('❌ Error deleting image: $e');
      throw Exception('Failed to delete image: $e');
    }
  }

  // Convert a gs:// URI to an HTTP download URL
  Future<String> getDownloadUrl(String gsUri) async {
    try {
      // Check if the URL is already an HTTP URL
      if (gsUri.startsWith('http://') || gsUri.startsWith('https://')) {
        return gsUri;
      } // Remove 'gs://' prefix from the URI
      if (gsUri.startsWith('gs://')) {
        // Extract the bucket and object path
        final bucketAndPath = gsUri.replaceFirst('gs://', '');
        final slashIndex = bucketAndPath.indexOf('/');
        if (slashIndex != -1) {
          final objectPath = bucketAndPath.substring(slashIndex + 1);

          // Create a reference to the file
          final ref = _storage.ref().child(objectPath);

          // Get the download URL
          final downloadUrl = await ref.getDownloadURL();
          return downloadUrl;
        }
      }

      throw Exception('Invalid gs:// URI format');
    } catch (e) {
      print('Error converting gs:// URI to download URL: $e');
      throw Exception('Failed to get download URL: $e');
    }
  }
}
