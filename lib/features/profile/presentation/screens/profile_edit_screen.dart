// lib/features/profile/presentation/screens/profile_edit_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/storage_service.dart';
import '../../../../core/widgets/buttons/animated_button.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({Key? key}) : super(key: key);

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;
  bool _isPasswordResetSent = false;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    // Initialize with current user data
    _loadUserData();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
  
  void _loadUserData() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
    }
  }
  
  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error picking image: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> _updateProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        
        // Update profile name
        if (_nameController.text != authService.currentUser?.name) {
          await authService.updateProfile(
            name: _nameController.text,
          );
        }
        
        // Update profile image if selected
        if (_selectedImage != null) {
          final storageService = Provider.of<StorageService>(context, listen: false);
          final imageUrl = await storageService.uploadProfileImage(
            file: _selectedImage!,
            userId: authService.currentUser!.id,
          );
          
          await authService.updateProfile(
            profileImageUrl: imageUrl,
          );
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate back using the GoRouter
        if (mounted) {
          context.pop();
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Error updating profile: $e';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
  
  Future<void> _sendPasswordReset() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.resetPassword(_emailController.text);
      
      setState(() {
        _isPasswordResetSent = true;
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent. Check your inbox.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Error sending password reset: $e';
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending password reset: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;
    
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('You need to be logged in to edit your profile'),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Error message if any
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // Profile image
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundImage: _selectedImage != null
                                  ? FileImage(_selectedImage!)
                                  : (user.profileImageUrl != null
                                      ? NetworkImage(user.profileImageUrl!) as ImageProvider<Object>
                                      : const NetworkImage('https://picsum.photos/seed/user/200/200')),
                            ),
                            
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: theme.colorScheme.onPrimary,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().scale(
                      duration: 300.ms,
                      curve: Curves.easeOutBack,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Name field
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
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
                    
                    // Email field - readonly
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      readOnly: true,
                      enabled: false,
                    ).animate().fadeIn(duration: 300.ms, delay: 200.ms).slideY(
                      begin: 0.3,
                      end: 0.0,
                      duration: 300.ms,
                      delay: 200.ms,
                      curve: Curves.easeOutQuad,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Password reset section
                    Text(
                      'Password Management',
                      style: theme.textTheme.titleLarge,
                    ).animate().fadeIn(duration: 300.ms, delay: 300.ms).slideY(
                      begin: 0.3,
                      end: 0.0,
                      duration: 300.ms,
                      delay: 300.ms,
                      curve: Curves.easeOutQuad,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    if (!_isPasswordResetSent)
                      OutlinedButton.icon(
                        onPressed: _sendPasswordReset,
                        icon: const Icon(Icons.lock_reset),
                        label: const Text('Send Password Reset Email'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                        ),
                      ).animate().fadeIn(duration: 300.ms, delay: 400.ms).slideY(
                        begin: 0.3,
                        end: 0.0,
                        duration: 300.ms,
                        delay: 400.ms,
                        curve: Curves.easeOutQuad,
                      )
                    else
                      const Text(
                        'A password reset email has been sent to your inbox. Please check your email to reset your password.',
                        style: TextStyle(color: Colors.green),
                      ).animate().fadeIn(duration: 300.ms, delay: 400.ms).slideY(
                        begin: 0.3,
                        end: 0.0,
                        duration: 300.ms,
                        delay: 400.ms,
                        curve: Curves.easeOutQuad,
                      ),
                    
                    const SizedBox(height: 48),
                    
                    // Update profile button
                    SizedBox(
                      width: double.infinity,
                      child: AnimatedGradientButton(
                        text: 'Update Profile',
                        onPressed: _updateProfile,
                        gradient: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primaryContainer,
                        ],
                        isLoading: _isLoading,
                      ),
                    ).animate().fadeIn(duration: 300.ms, delay: 500.ms).slideY(
                      begin: 0.3,
                      end: 0.0,
                      duration: 300.ms,
                      delay: 500.ms,
                      curve: Curves.easeOutQuad,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}