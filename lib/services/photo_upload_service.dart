// File: lib/services/photo_upload_service.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'storage_service.dart';
import 'firestore_service.dart';
import '../core/models/photo_model.dart';

class PhotoUploadService with ChangeNotifier {
  final ImagePicker _picker = ImagePicker();
  final StorageService _storageService;
  final FirestoreService _firestoreService;
  final Uuid _uuid = const Uuid();
  
  File? _selectedImage;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _errorMessage;
  
  // Getters
  File? get selectedImage => _selectedImage;
  bool get isUploading => _isUploading;
  double get uploadProgress => _uploadProgress;
  String? get errorMessage => _errorMessage;
  
  // Constructor
  PhotoUploadService({
    required StorageService storageService,
    required FirestoreService firestoreService,
  })  : _storageService = storageService,
        _firestoreService = firestoreService;
  
  // Methods for selecting images
  Future<void> pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        _selectedImage = File(pickedFile.path);
        _errorMessage = null;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error picking image: $e';
      notifyListeners();
    }
  }
  
  Future<void> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        _selectedImage = File(pickedFile.path);
        _errorMessage = null;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error picking image: $e';
      notifyListeners();
    }
  }
  
  // Method to clear selected image
  void clearSelectedImage() {
    _selectedImage = null;
    _errorMessage = null;
    notifyListeners();
  }
  
  // Method to extract metadata from image
  Future<Map<String, dynamic>?> extractImageMetadata(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) return null;
      
      return {
        'width': image.width,
        'height': image.height,
        'originalFileName': path.basename(imageFile.path),
        'fileSize': bytes.length,
        'fileType': path.extension(imageFile.path).toLowerCase(),
        'extractedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('Error extracting metadata: $e');
      return null;
    }
  }
  
  // Generate thumbnail from image
  Future<File?> generateThumbnail(File imageFile, {int size = 300}) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) return null;
      
      // Resize the image to create a thumbnail
      final thumbnail = img.copyResize(
        image,
        width: size,
        height: (size * image.height / image.width).round(),
      );
      
      // Save the thumbnail to a temporary file
      final directory = await getTemporaryDirectory();
      final thumbnailPath = path.join(directory.path, '${_uuid.v4()}_thumb.jpg');
      final thumbnailFile = File(thumbnailPath);
      
      await thumbnailFile.writeAsBytes(img.encodeJpg(thumbnail, quality: 85));
      
      return thumbnailFile;
    } catch (e) {
      debugPrint('Error generating thumbnail: $e');
      return null;
    }
  }
  
  // Upload photo method
  Future<String?> uploadPhoto({
    required String userId,
    required String userName,
    required String communityId,
    required String title,
    required String description,
    List<String> tags = const [],
    String? eventId,
    Function(double)? onProgress,
  }) async {
    if (_selectedImage == null) {
      _errorMessage = 'No image selected';
      notifyListeners();
      return null;
    }
    
    try {
      _isUploading = true;
      _uploadProgress = 0.0;
      _errorMessage = null;
      notifyListeners();
      
      // Generate thumbnail
      final thumbnailFile = await generateThumbnail(_selectedImage!);
      
      // Extract metadata
      final metadata = await extractImageMetadata(_selectedImage!);
      
      // Upload the full image
      final imageUrl = await _storageService.uploadPhoto(
        file: _selectedImage!,
        userId: userId,
        communityId: communityId,
        onProgress: (progress) {
          _uploadProgress = progress * 0.7; // 70% of the process is for the main image
          if (onProgress != null) onProgress(_uploadProgress);
          notifyListeners();
        },
      );
      
      // Upload the thumbnail if it was created
      String thumbnailUrl = imageUrl; // Default to main image URL
      if (thumbnailFile != null) {
        thumbnailUrl = await _storageService.uploadThumbnail(
          file: thumbnailFile,
          userId: userId,
          communityId: communityId,
          onProgress: (progress) {
            _uploadProgress = 0.7 + (progress * 0.2); // 20% of the process is for thumbnail
            if (onProgress != null) onProgress(_uploadProgress);
            notifyListeners();
          },
        );
        
        // Clean up the temporary thumbnail file
        await thumbnailFile.delete();
      }
      
      // Create a PhotoModel
      final photo = PhotoModel(
        id: '', // Firebase will assign an ID
        imageUrl: imageUrl,
        thumbnailUrl: thumbnailUrl,
        title: title,
        description: description,
        userId: userId,
        userName: userName,
        communityId: communityId,
        eventId: eventId,
        uploadDate: DateTime.now(),
        likeCount: 0,
        isLiked: false,
        tags: tags,
        likedBy: [],
        comments: [],
        metadata: metadata,
      );
      
      // Save to Firestore
      _uploadProgress = 0.9; // 90% done after storage uploads
      if (onProgress != null) onProgress(_uploadProgress);
      notifyListeners();
      
      final photoId = await _firestoreService.addPhoto(photo);
      
      _uploadProgress = 1.0; // 100% complete
      if (onProgress != null) onProgress(_uploadProgress);
      _isUploading = false;
      notifyListeners();
      
      // Clear the selected image after successful upload
      _selectedImage = null;
      
      return photoId;
    } catch (e) {
      _errorMessage = 'Error uploading photo: $e';
      _isUploading = false;
      notifyListeners();
      return null;
    }
  }
}