// lib/services/storage_service.dart (improved)

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class StorageService with ChangeNotifier {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = Uuid();
  bool _isUploading = false;
  double _uploadProgress = 0;
  String? _errorMessage;
  
  // Getters
  bool get isUploading => _isUploading;
  double get uploadProgress => _uploadProgress;
  String? get errorMessage => _errorMessage;
  
  // Upload a photo to Firebase Storage
  Future<String> uploadPhoto({
    required File file,
    required String userId,
    required String communityId,
    bool compress = true,
    int quality = 85,
    int maxWidth = 1920,
    int maxHeight = 1920,
    Function(double)? onProgress,
  }) async {
    _isUploading = true;
    _uploadProgress = 0;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Compress image if requested
      File imageToUpload = file;
      if (compress) {
        try {
          final bytes = await file.readAsBytes();
          final image = img.decodeImage(bytes);
          
          if (image != null) {
            // Calculate new dimensions
            int width = image.width;
            int height = image.height;
            
            if (width > maxWidth || height > maxHeight) {
              double aspectRatio = width / height;
              
              if (width > height) {
                width = maxWidth;
                height = (width / aspectRatio).round();
              } else {
                height = maxHeight;
                width = (height * aspectRatio).round();
              }
            }
            
            // Resize image
            final resized = img.copyResize(
              image,
              width: width,
              height: height,
            );
            
            // Save to temporary file
            final tempDir = await getTemporaryDirectory();
            final tempPath = path.join(tempDir.path, '${_uuid.v4()}.jpg');
            final tempFile = File(tempPath);
            
            await tempFile.writeAsBytes(img.encodeJpg(resized, quality: quality));
            
            imageToUpload = tempFile;
          }
        } catch (e) {
          // If compression fails, use original
          debugPrint('Image compression failed: $e - using original image');
        }
      }
      
      // Create a unique filename with timestamp to avoid collisions
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String filename = '${_uuid.v4()}_$timestamp';
      final String storagePath = 'photos/$communityId/$userId/$filename${path.extension(file.path)}';
      
      // Get file mime type
      final String mimeType = 'image/${path.extension(file.path).replaceAll('.', '')}';
      
      // Create the upload task with metadata
      final UploadTask uploadTask = _storage.ref(storagePath).putFile(
        imageToUpload,
        SettableMetadata(
          contentType: mimeType,
          customMetadata: {
            'userId': userId,
            'communityId': communityId,
            'uploadedAt': DateTime.now().toIso8601String(),
            'originalFilename': path.basename(file.path),
            'compressed': compress.toString(),
          },
        ),
      );
      
      // Listen to upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
        if (onProgress != null) {
          onProgress(_uploadProgress);
        }
        notifyListeners();
      });
      
      // Wait for upload to complete
      final TaskSnapshot taskSnapshot = await uploadTask;
      
      // Log success
      debugPrint('Upload success: ${taskSnapshot.bytesTransferred} bytes');
      
      // Get the download URL
      final String downloadUrl = await _storage.ref(storagePath).getDownloadURL();
      
      _isUploading = false;
      _uploadProgress = 1.0;
      notifyListeners();
      
      return downloadUrl;
    } catch (e) {
      _errorMessage = 'Error uploading photo: $e';
      _isUploading = false;
      debugPrint(_errorMessage);
      notifyListeners();
      rethrow;
    }
  }
  
  // Upload a thumbnail image
  Future<String> uploadThumbnail({
    required File file,
    required String userId,
    required String communityId,
    Function(double)? onProgress,
  }) async {
    _isUploading = true;
    _uploadProgress = 0;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Create a unique filename
      final String filename = _uuid.v4();
      final String storagePath = 'thumbnails/$communityId/$userId/$filename${path.extension(file.path)}';
      
      // Create the upload task
      final UploadTask uploadTask = _storage.ref(storagePath).putFile(
        file,
        SettableMetadata(contentType: 'image/${path.extension(file.path).replaceAll('.', '')}'),
      );
      
      // Listen to upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
        if (onProgress != null) {
          onProgress(_uploadProgress);
        }
        notifyListeners();
      });
      
      // Wait for upload to complete
      await uploadTask;
      
      // Get the download URL
      final String downloadUrl = await _storage.ref(storagePath).getDownloadURL();
      
      _isUploading = false;
      _uploadProgress = 1.0;
      notifyListeners();
      
      return downloadUrl;
    } catch (e) {
      _errorMessage = 'Error uploading thumbnail: $e';
      _isUploading = false;
      debugPrint(_errorMessage);
      notifyListeners();
      rethrow;
    }
  }
  
  // Upload a profile image
  Future<String> uploadProfileImage({
    required File file,
    required String userId,
    Function(double)? onProgress,
  }) async {
    _isUploading = true;
    _uploadProgress = 0;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Add a timestamp to ensure we don't have caching issues with same filename
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String storagePath = 'profiles/$userId/profile_$timestamp${path.extension(file.path)}';
      
      // Get file mime type
      final String mimeType = 'image/${path.extension(file.path).replaceAll('.', '')}';
      
      // Create the upload task with metadata
      final UploadTask uploadTask = _storage.ref(storagePath).putFile(
        file,
        SettableMetadata(
          contentType: mimeType,
          customMetadata: {
            'userId': userId,
            'uploadedAt': DateTime.now().toIso8601String(),
            'type': 'profile',
          },
        ),
      );
      
      // Listen to upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
        if (onProgress != null) {
          onProgress(_uploadProgress);
        }
        notifyListeners();
      });
      
      // Wait for upload to complete
      final TaskSnapshot taskSnapshot = await uploadTask;
      
      // Log success
      debugPrint('Profile image upload success: ${taskSnapshot.bytesTransferred} bytes');
      
      // Delete previous profile image (optional, can be improved with more specific targeting)
      try {
        final ListResult result = await _storage.ref('profiles/$userId').listAll();
        for (var item in result.items) {
          if (item.name != path.basename(storagePath) && item.name.startsWith('profile_')) {
            await item.delete();
            debugPrint('Deleted previous profile image: ${item.name}');
          }
        }
      } catch (e) {
        // Ignore errors when cleaning up old images
        debugPrint('Error cleaning up old profile images: $e');
      }
      
      // Get the download URL
      final String downloadUrl = await _storage.ref(storagePath).getDownloadURL();
      
      _isUploading = false;
      _uploadProgress = 1.0;
      notifyListeners();
      
      return downloadUrl;
    } catch (e) {
      _errorMessage = 'Error uploading profile image: $e';
      _isUploading = false;
      debugPrint(_errorMessage);
      notifyListeners();
      rethrow;
    }
  }
  
  // Delete a file from Firebase Storage
  Future<void> deleteFile(String fileUrl) async {
    _errorMessage = null;
    notifyListeners();
    
    try {
      final Reference fileRef = _storage.refFromURL(fileUrl);
      await fileRef.delete();
    } catch (e) {
      _errorMessage = 'Error deleting file: $e';
      debugPrint(_errorMessage);
      notifyListeners();
      rethrow;
    }
  }
}