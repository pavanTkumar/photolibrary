// File: lib/features/photos/presentation/screens/photo_upload_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/animated_app_bar.dart';
import '../../../../core/widgets/buttons/animated_button.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/photo_upload_service.dart';
import '../widgets/photo_upload_preview.dart';
import '../widgets/tag_input_field.dart';
import '../widgets/community_selector_dropdown.dart';

class PhotoUploadScreen extends StatefulWidget {
  const PhotoUploadScreen({Key? key}) : super(key: key);

  @override
  State<PhotoUploadScreen> createState() => _PhotoUploadScreenState();
}

class _PhotoUploadScreenState extends State<PhotoUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  List<String> _selectedTags = [];
  String? _selectedCommunityId;
  bool _isUploading = false;
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  void _pickImageFromCamera() {
    final photoUploadService = Provider.of<PhotoUploadService>(context, listen: false);
    photoUploadService.pickImageFromCamera();
  }
  
  void _pickImageFromGallery() {
    final photoUploadService = Provider.of<PhotoUploadService>(context, listen: false);
    photoUploadService.pickImageFromGallery();
  }
  
  void _handleTagsChanged(List<String> tags) {
    setState(() {
      _selectedTags = tags;
    });
  }
  
  void _handleCommunityChanged(String? communityId) {
    setState(() {
      _selectedCommunityId = communityId;
    });
  }
  
  Future<void> _uploadPhoto() async {
    if (_formKey.currentState?.validate() ?? false) {
      final photoUploadService = Provider.of<PhotoUploadService>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);
      
      if (_selectedCommunityId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a community'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      setState(() {
        _isUploading = true;
      });
      
      final photoId = await photoUploadService.uploadPhoto(
        userId: authService.currentUser!.id,
        userName: authService.currentUser!.name,
        communityId: _selectedCommunityId!,
        title: _titleController.text,
        description: _descriptionController.text,
        tags: _selectedTags,
        onProgress: (progress) {
          // Could update a progress indicator here
        },
      );
      
      setState(() {
        _isUploading = false;
      });
      
      if (photoId != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo uploaded successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Navigate back or to the photo details page
          context.pop();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(photoUploadService.errorMessage ?? 'Error uploading photo'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final photoUploadService = Provider.of<PhotoUploadService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Photo'),
        actions: [
          if (photoUploadService.selectedImage != null)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _isUploading ? null : _uploadPhoto,
              tooltip: 'Upload Photo',
            ),
        ],
      ),
      body: _isUploading
          ? _buildUploadingState(photoUploadService.uploadProgress)
          : _buildUploadForm(theme, photoUploadService),
    );
  }
  
  Widget _buildUploadingState(double progress) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Uploading photo... ${(progress * 100).toInt()}%',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
  
  Widget _buildUploadForm(ThemeData theme, PhotoUploadService photoUploadService) {
    final hasSelectedImage = photoUploadService.selectedImage != null;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image selection area
            hasSelectedImage 
                ? _buildSelectedImagePreview(photoUploadService)
                : _buildImageSelectionButtons(theme),
            
            const SizedBox(height: 24),
            
            // Only show form fields if an image has been selected
            if (hasSelectedImage) ...[
              // Title field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ).animate().fadeIn(duration: 300.ms).slideY(
                begin: 0.3,
                end: 0,
                duration: 300.ms,
                curve: Curves.easeOutQuad,
              ),
              
              const SizedBox(height: 16),
              
              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideY(
                begin: 0.3,
                end: 0,
                duration: 300.ms,
                delay: 100.ms,
                curve: Curves.easeOutQuad,
              ),
              
              const SizedBox(height: 16),
              
              // Community selector
              CommunitySelectorDropdown(
                onCommunityChanged: _handleCommunityChanged,
              ).animate().fadeIn(duration: 300.ms, delay: 200.ms).slideY(
                begin: 0.3,
                end: 0,
                duration: 300.ms,
                delay: 200.ms,
                curve: Curves.easeOutQuad,
              ),
              
              const SizedBox(height: 16),
              
              // Tags input
              TagInputField(
                onTagsChanged: _handleTagsChanged,
              ).animate().fadeIn(duration: 300.ms, delay: 300.ms).slideY(
                begin: 0.3,
                end: 0,
                duration: 300.ms,
                delay: 300.ms,
                curve: Curves.easeOutQuad,
              ),
              
              const SizedBox(height: 24),
              
              // Upload button - full width
              SizedBox(
                width: double.infinity,
                child: AnimatedGradientButton(
                  text: 'Upload Photo',
                  onPressed: _uploadPhoto,
                  gradient: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primaryContainer,
                  ],
                  isLoading: _isUploading,
                  icon: const Icon(
                    Icons.cloud_upload,
                    color: Colors.white,
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms, delay: 400.ms).slideY(
                begin: 0.3,
                end: 0,
                duration: 300.ms,
                delay: 400.ms,
                curve: Curves.easeOutQuad,
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildSelectedImagePreview(PhotoUploadService photoUploadService) {
    return PhotoUploadPreview(
      imageFile: photoUploadService.selectedImage!,
      onClear: () => photoUploadService.clearSelectedImage(),
    ).animate().fadeIn(duration: 300.ms).scale(
      begin: const Offset(0.95, 0.95),
      end: const Offset(1, 1),
      duration: 300.ms,
      curve: Curves.easeOutQuad,
    );
  }
  
  Widget _buildImageSelectionButtons(ThemeData theme) {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate,
            size: 80,
            color: theme.colorScheme.primary,
          ).animate()
            .scale(
              duration: 600.ms,
              curve: Curves.easeOutBack,
            ),
          
          const SizedBox(height: 24),
          
          const Text(
            'Select a photo to upload',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 24),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Camera button
              ElevatedButton.icon(
                onPressed: _pickImageFromCamera,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Camera'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Gallery button
              OutlinedButton.icon(
                onPressed: _pickImageFromGallery,
                icon: const Icon(Icons.photo_library),
                label: const Text('Gallery'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}