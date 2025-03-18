// File: lib/services/storage_service.dart

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class StorageService with ChangeNotifier {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = Uuid();
  
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
    try {
      // Create a unique filename with timestamp to avoid collisions
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String filename = '${_uuid.v4()}_$timestamp';
      final String storagePath = 'photos/$communityId/$userId/$filename${path.extension(file.path)}';
      
      // Get file mime type
      final String mimeType = 'image/${path.extension(file.path).replaceAll('.', '')}';
      
      // Create the upload task with metadata
      final UploadTask uploadTask = _storage.ref(storagePath).putFile(
        file,
        SettableMetadata(
          contentType: mimeType,
          customMetadata: {
            'userId': userId,
            'communityId': communityId,
            'uploadedAt': DateTime.now().toIso8601String(),
            'originalFilename': path.basename(file.path),
          },
        ),
      );
      
      // Listen to upload progress if callback provided
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final double progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }
      
      // Wait for upload to complete
      final TaskSnapshot taskSnapshot = await uploadTask;
      
      // Log success
      debugPrint('Upload success: ${taskSnapshot.bytesTransferred} bytes');
      
      // Get the download URL
      final String downloadUrl = await _storage.ref(storagePath).getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading photo: $e');
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
    try {
      // Create a unique filename
      final String filename = _uuid.v4();
      final String storagePath = 'thumbnails/$communityId/$userId/$filename${path.extension(file.path)}';
      
      // Create the upload task
      final UploadTask uploadTask = _storage.ref(storagePath).putFile(
        file,
        SettableMetadata(contentType: 'image/${path.extension(file.path).replaceAll('.', '')}'),
      );
      
      // Listen to upload progress if callback provided
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final double progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }
      
      // Wait for upload to complete
      await uploadTask;
      
      // Get the download URL
      final String downloadUrl = await _storage.ref(storagePath).getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading thumbnail: $e');
      rethrow;
    }
  }
  
  // Upload a profile image
  Future<String> uploadProfileImage({
    required File file,
    required String userId,
    Function(double)? onProgress,
  }) async {
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
      
      // Listen to upload progress if callback provided
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final double progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }
      
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
      
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading profile image: $e');
      rethrow;
    }
  }
  
  // Delete a file from Firebase Storage
  Future<void> deleteFile(String fileUrl) async {
    try {
      final Reference fileRef = _storage.refFromURL(fileUrl);
      await fileRef.delete();
    } catch (e) {
      debugPrint('Error deleting file: $e');
      rethrow;
    }
  }
}