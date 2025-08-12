import 'package:flutter/material.dart';

class DragItemImage extends StatelessWidget {
  final String imageUrl;

  const DragItemImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      width: 120,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return _buildErrorPlaceholder();
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildLoadingPlaceholder();
      },
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      width: 120,
      height: 80,
      color: Colors.grey[300],
      child: const Icon(Icons.image_not_supported, size: 40),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      width: 120,
      height: 80,
      color: Colors.grey[300],
      child: const CircularProgressIndicator(strokeWidth: 2),
    );
  }
}
