// File: lib/features/photos/presentation/widgets/photo_upload_preview.dart

import 'dart:io';
import 'package:flutter/material.dart';

class PhotoUploadPreview extends StatelessWidget {
  final File imageFile;
  final VoidCallback onClear;
  
  const PhotoUploadPreview({
    Key? key,
    required this.imageFile,
    required this.onClear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Stack(
      children: [
        // Image container
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            imageFile,
            width: double.infinity,
            height: 300,
            fit: BoxFit.cover,
          ),
        ),
        
        // Clear button
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.close,
                color: Colors.white,
              ),
              onPressed: onClear,
              tooltip: 'Clear selected image',
              iconSize: 20,
              constraints: const BoxConstraints(
                minWidth: 36,
                minHeight: 36,
              ),
              padding: const EdgeInsets.all(8),
            ),
          ),
        ),
      ],
    );
  }
}