import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:past_question_paper_v1/services/storage_service.dart';
import 'package:past_question_paper_v1/utils/app_colors.dart';

/// Widget for picking and uploading images
class ImageUploadWidget extends StatefulWidget {
  final String? initialImageUrl;
  final Function(String imageUrl) onImageUploaded;
  final Function()? onImageRemoved;
  final String folder;

  const ImageUploadWidget({
    super.key,
    this.initialImageUrl,
    required this.onImageUploaded,
    this.onImageRemoved,
    this.folder = 'question_images',
  });

  @override
  State<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  final ImagePicker _picker = ImagePicker();
  final StorageService _storageService = StorageService();

  String? _imageUrl;
  bool _isUploading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _imageUrl = widget.initialImageUrl;
  }

  Future<void> _pickAndUploadImage() async {
    try {
      setState(() {
        _errorMessage = null;
        _isUploading = true;
      });

      // Pick image
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        if (mounted) {
          setState(() => _isUploading = false);
        }
        return;
      }

      // Get image bytes
      final Uint8List imageBytes = await pickedFile.readAsBytes();

      // Upload to Firebase Storage
      final downloadUrl = await _storageService.uploadImage(
        imageBytes: imageBytes,
        fileName: pickedFile.name,
        folder: widget.folder,
      );

      debugPrint('✅ Upload successful: $downloadUrl');
      debugPrint('✅ URL starts with https: ${downloadUrl.startsWith('https')}');

      if (mounted) {
        setState(() {
          _imageUrl = downloadUrl;
          _isUploading = false;
        });
      }

      // Notify parent
      widget.onImageUploaded(downloadUrl);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Image uploaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to upload image: $e';
          _isUploading = false;
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _removeImage() async {
    if (_imageUrl == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Image'),
        content: const Text('Are you sure you want to remove this image?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (mounted) {
        setState(() {
          _imageUrl = null;
        });
      }

      if (widget.onImageRemoved != null) {
        widget.onImageRemoved!();
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Image removed')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Upload Button or Image Preview
        if (_imageUrl == null || _imageUrl!.isEmpty)
          _buildUploadButton()
        else
          _buildImagePreview(),

        // Error Message
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildUploadButton() {
    return InkWell(
      onTap: _isUploading ? null : _pickAndUploadImage,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade300,
            width: 2,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade50,
        ),
        child: _isUploading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Uploading...'),
                  ],
                ),
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_upload, size: 48, color: AppColors.accent),
                    const SizedBox(height: 16),
                    Text(
                      'Click to upload image',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.ink,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Supports JPG, PNG (max 5MB)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            child: Container(
              height: 220,
              width: double.infinity,
              color: Colors.grey.shade100,
              alignment: Alignment.center,
              child: Image.network(
                _imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.contain,
                alignment: Alignment.center,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return SizedBox(
                    height: 200,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('❌ Image load error: $error');
                  debugPrint('❌ Image URL: $_imageUrl');
                  debugPrint('❌ Stack trace: $stackTrace');
                  return SizedBox(
                    height: 200,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red.shade300,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Failed to load image',
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              error.toString(),
                              style: TextStyle(
                                color: Colors.red.shade600,
                                fontSize: 11,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Actions
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                // Image URL (truncated)
                Expanded(
                  child: Text(
                    _imageUrl!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ),
                const SizedBox(width: 12),

                // Change Image Button
                TextButton.icon(
                  onPressed: _isUploading ? null : _pickAndUploadImage,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Change'),
                ),

                // Remove Button
                TextButton.icon(
                  onPressed: _removeImage,
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('Remove'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
