// File: lib/features/community/presentation/screens/community_creation_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/buttons/animated_button.dart';

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
  List<String> _tags = [];
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }
  
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
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
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Community created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate back
        context.pop();
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
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Creating your community...',
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            )
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
                        child: _selectedImage == null
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
                  ],
                ),
              ),
            ),
    );
  }
}