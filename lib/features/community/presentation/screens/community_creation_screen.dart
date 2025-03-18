import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/buttons/animated_button.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/firestore_service.dart';
import '../../../../services/storage_service.dart';
import '../../../../core/models/community_model.dart';

class CommunityCreationScreen extends StatefulWidget {
  const CommunityCreationScreen({Key? key}) : super(key: key);

  @override
  State<CommunityCreationScreen> createState() => _CommunityCreationScreenState();
}

class _CommunityCreationScreenState extends State<CommunityCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();
  
  File? _selectedImage;
  bool _isPrivate = false;
  bool _isCreating = false;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  List<String> _tags = [];
  
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }
  
  void _checkAuthStatus() {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (!authService.isLoggedIn) {
      // Redirect to login if not logged in
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in to create a community'),
            backgroundColor: Colors.red,
          ),
        );
        context.goNamed('login');
      });
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }
  
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _addTag(String tag) {
    tag = tag.trim().toLowerCase();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagsController.clear();
      });
    }
  }
  
  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }
  
  Future<void> _createCommunity() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isCreating = true;
      });
      
      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        final firestoreService = Provider.of<FirestoreService>(context, listen: false);
        final storageService = Provider.of<StorageService>(context, listen: false);
        
        if (!authService.isLoggedIn || authService.currentUser == null) {
          throw Exception('User not logged in');
        }
        
        final userId = authService.currentUser!.id;
        final userName = authService.currentUser!.name;
        
        // Upload image if selected
        String imageUrl = 'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/800/450';
        if (_selectedImage != null) {
          setState(() {
            _isUploading = true;
            _uploadProgress = 0.0;
          });
          
          imageUrl = await storageService.uploadProfileImage(
            file: _selectedImage!,
            userId: userId,
            onProgress: (progress) {
              setState(() {
                _uploadProgress = progress;
              });
            },
          );
          
          setState(() {
            _isUploading = false;
            _uploadProgress = 1.0;
          });
        }
        
        // Create community model
        final community = CommunityModel(
          id: '', // Will be assigned by Firestore
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          imageUrl: imageUrl,
          adminId: userId,
          adminName: userName,
          createdAt: DateTime.now(),
          memberIds: [userId], // Creator is the first member
          moderatorIds: [], // No moderators initially
          isPrivate: _isPrivate,
          settings: {
            'tags': _tags,
            'allowComments': true,
            'allowSharing': true,
            'approvePhotos': _isPrivate, // Auto-approve photos for public communities
          },
        );
        
        // Add to Firestore
        final communityId = await firestoreService.addCommunity(community);
        
        // Add to user's communities list
        await authService.updateCommunities([
          ...authService.currentUser!.communities,
          communityId,
        ]);
        
        if (mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Community created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Navigate back to communities screen
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error creating community: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isCreating = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Community'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isCreating
          ? _buildLoadingIndicator()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Community image
                    InkWell(
                      onTap: _pickImage,
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.5),
                          ),
                          image: _selectedImage != null
                              ? DecorationImage(
                                  image: FileImage(_selectedImage!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _isUploading 
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      value: _uploadProgress > 0 ? _uploadProgress : null,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Uploading Image...\n${(_uploadProgress * 100).toInt()}%',
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              )
                            : _selectedImage == null
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_photo_alternate,
                                        size: 50,
                                        color: theme.colorScheme.primary,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Add Community Cover Image',
                                        style: theme.textTheme.titleMedium,
                                      ),
                                    ],
                                  )
                                : Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: CircleAvatar(
                                          radius: 20,
                                          backgroundColor: Colors.black54,
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _selectedImage = null;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                      ),
                    ).animate().fade(duration: 300.ms).scale(
                      begin: const Offset(0.95, 0.95),
                      end: const Offset(1, 1),
                      duration: 300.ms,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Community name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Community Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.group),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a community name';
                        }
                        if (value.length < 3) {
                          return 'Name must be at least 3 characters';
                        }
                        return null;
                      },
                    ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideY(
                      begin: 0.3,
                      end: 0.0,
                      duration: 300.ms,
                      delay: 100.ms,
                      curve: Curves.easeOutQuad,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Community description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        if (value.length < 10) {
                          return 'Description must be at least 10 characters';
                        }
                        return null;
                      },
                    ).animate().fadeIn(duration: 300.ms, delay: 200.ms).slideY(
                      begin: 0.3,
                      end: 0.0,
                      duration: 300.ms,
                      delay: 200.ms,
                      curve: Curves.easeOutQuad,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Private community toggle
                    SwitchListTile(
                      title: const Text('Private Community'),
                      subtitle: const Text('Only approved members can see and join'),
                      value: _isPrivate,
                      onChanged: (value) {
                        setState(() {
                          _isPrivate = value;
                        });
                      },
                      secondary: Icon(
                        _isPrivate ? Icons.lock : Icons.public,
                        color: theme.colorScheme.primary,
                      ),
                    ).animate().fadeIn(duration: 300.ms, delay: 300.ms).slideY(
                      begin: 0.3,
                      end: 0.0,
                      duration: 300.ms,
                      delay: 300.ms,
                      curve: Curves.easeOutQuad,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Tags section
                    Text(
                      'Community Tags',
                      style: theme.textTheme.titleMedium,
                    ).animate().fadeIn(duration: 300.ms, delay: 400.ms),
                    
                    const SizedBox(height: 8),
                    
                    // Tags display
                    if (_tags.isNotEmpty) 
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _tags.map((tag) {
                          return Chip(
                            label: Text('#$tag'),
                            onDeleted: () => _removeTag(tag),
                            backgroundColor: theme.colorScheme.secondaryContainer,
                            labelStyle: TextStyle(
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                          );
                        }).toList(),
                      ).animate().fadeIn(duration: 300.ms, delay: 450.ms),
                    
                    const SizedBox(height: 8),
                    
                    // Tags input
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _tagsController,
                            decoration: const InputDecoration(
                              labelText: 'Add Tag',
                              hintText: 'Type and press Add',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.tag),
                            ),
                            onFieldSubmitted: _addTag,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => _addTag(_tagsController.text),
                          icon: const Icon(Icons.add_circle),
                          color: theme.colorScheme.primary,
                          tooltip: 'Add Tag',
                        ),
                      ],
                    ).animate().fadeIn(duration: 300.ms, delay: 500.ms).slideY(
                      begin: 0.3,
                      end: 0.0,
                      duration: 300.ms,
                      delay: 500.ms,
                      curve: Curves.easeOutQuad,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Create button
                    SizedBox(
                      width: double.infinity,
                      child: AnimatedGradientButton(
                        text: 'Create Community',
                        onPressed: _createCommunity,
                        gradient: [
                          theme.colorScheme.primary,
                          theme.colorScheme.tertiary,
                        ],
                        icon: const Icon(
                          Icons.group_add,
                          color: Colors.white,
                        ),
                      ),
                    ).animate().fadeIn(duration: 300.ms, delay: 600.ms).slideY(
                      begin: 0.3,
                      end: 0.0,
                      duration: 300.ms,
                      delay: 600.ms,
                      curve: Curves.easeOutQuad,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Guidelines
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Community Guidelines',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              '• Communities should foster positive interactions\n'
                              '• Respect all members and their contributions\n'
                              '• Keep content appropriate and relevant\n'
                              '• Avoid sharing sensitive personal information\n'
                              '• Report inappropriate content to moderators',
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(duration: 300.ms, delay: 700.ms),
                  ],
                ),
              ),
            ),
    );
  }
  
  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Creating your community...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (_isUploading) ...[
            const SizedBox(height: 8),
            Text(
              'Uploading image: ${(_uploadProgress * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}