import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

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


