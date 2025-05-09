import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload an image file to Firebase Storage
  Future<String> uploadImage(File imageFile, String folder) async {
    try {
      // Generate a unique filename with timestamp
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';

      // Create a reference to the file location in Firebase Storage
      final ref = _storage.ref().child('$folder/$fileName');

      // Upload the file
      final uploadTask = ref.putFile(imageFile);

      // Wait for upload to complete and get the download URL
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  // Upload multiple images to Firebase Storage
  Future<List<String>> uploadMultipleImages(
    List<File> imageFiles,
    String folder,
  ) async {
    List<String> downloadUrls = [];

    for (File imageFile in imageFiles) {
      final url = await uploadImage(imageFile, folder);
      downloadUrls.add(url);
    }

    return downloadUrls;
  }

  // Delete an image from Firebase Storage using its URL
  Future<void> deleteImage(String imageUrl) async {
    try {
      // Create a reference from the URL
      final ref = _storage.refFromURL(imageUrl);

      // Delete the file
      await ref.delete();
    } catch (e) {
      print('Error deleting image: $e');
      throw Exception('Failed to delete image: $e');
    }
  }

  // Convert a gs:// URI to an HTTP download URL
  Future<String> getDownloadUrl(String gsUri) async {
    try {
      // Check if the URL is already an HTTP URL
      if (gsUri.startsWith('http://') || gsUri.startsWith('https://')) {
        return gsUri;
      }

      // Remove 'gs://' prefix from the URI
      if (gsUri.startsWith('gs://')) {
        // Extract the bucket and object path
        final uri = Uri.parse(gsUri);
        final bucketAndPath = gsUri.replaceFirst('gs://', '');
        final slashIndex = bucketAndPath.indexOf('/');

        if (slashIndex != -1) {
          final bucket = bucketAndPath.substring(0, slashIndex);
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
