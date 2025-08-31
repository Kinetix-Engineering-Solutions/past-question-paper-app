import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

// Widget to handle Firebase Storage images
class FirebaseImage extends StatefulWidget {
  final String imageUrl;
  final double width;
  final double height;
  final Color iconColor;
  final BoxFit fit;

  const FirebaseImage({
    Key? key,
    required this.imageUrl,
    required this.width,
    required this.height,
    required this.iconColor,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  State<FirebaseImage> createState() => _FirebaseImageState();
}

class _FirebaseImageState extends State<FirebaseImage> {
  String? _downloadUrl;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(FirebaseImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      if (widget.imageUrl.startsWith('gs://')) {
        // Convert gs:// URL to download URL
        final ref = FirebaseStorage.instance.refFromURL(widget.imageUrl);
        final downloadUrl = await ref.getDownloadURL();

        if (mounted) {
          setState(() {
            _downloadUrl = downloadUrl;
            _isLoading = false;
          });
        }
      } else {
        // If it's already a regular URL, use it directly
        if (mounted) {
          setState(() {
            _downloadUrl = widget.imageUrl;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading Firebase image: $e');
      if (e.toString().contains('unauthorized')) {
        print(
          'Firebase Storage Error: Check your security rules. The current user is not authorized to access this image.',
        );
        print('URL: ${widget.imageUrl}');
        print(
          'Solution: Update Firebase Storage security rules to allow read access.',
        );
      }

      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingWidget();
    }

    if (_hasError || _downloadUrl == null) {
      return _buildErrorWidget();
    }

    return _buildImageWidget();
  }

  Widget _buildLoadingWidget() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: SizedBox(
          width: widget.width * 0.3,
          height: widget.width * 0.3,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(widget.iconColor),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: widget.iconColor.withOpacity(0.6),
            size: widget.width * 0.4,
          ),
          SizedBox(height: 4),
          Text(
            'Image\nError',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: widget.width * 0.15,
              color: widget.iconColor.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.network(
        _downloadUrl!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingWidget();
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget();
        },
      ),
    );
  }
}
