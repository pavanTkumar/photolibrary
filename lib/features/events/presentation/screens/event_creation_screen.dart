// File: lib/features/events/presentation/screens/event_creation_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/buttons/animated_button.dart';

class EventCreationScreen extends StatefulWidget {
  const EventCreationScreen({Key? key}) : super(key: key);

  @override
  State<EventCreationScreen> createState() => _EventCreationScreenState();
}

class _EventCreationScreenState extends State<EventCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _tagsController = TextEditingController();
  
  File? _selectedImage;
  List<String> _tags = [];
  bool _isCreating = false;
  DateTime _eventDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _eventTime = TimeOfDay.now();
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
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
  
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _eventDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null && picked != _eventDate) {
      setState(() {
        _eventDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _eventTime.hour,
          _eventTime.minute,
        );
      });
    }
  }
  
  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _eventTime,
    );
    
    if (picked != null && picked != _eventTime) {
      setState(() {
        _eventTime = picked;
        _eventDate = DateTime(
          _eventDate.year,
          _eventDate.month,
          _eventDate.day,
          picked.hour,
          picked.minute,
        );
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
  
  Future<void> _createEvent() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select an event image'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
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
            content: Text('Event created successfully!'),
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
        title: const Text('Create Event'),
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
                    'Creating your event...',
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
                    // Event image
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
                                    'Add Event Cover Image',
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
                    
                    // Event title
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Event Title',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.event),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an event title';
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
                    
                    // Event description
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
                    
                    // Event date and time
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: _pickDate,
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Date',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(
                                DateFormat('MMM dd, yyyy').format(_eventDate),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: _pickTime,
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Time',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.access_time),
                              ),
                              child: Text(
                                _eventTime.format(context),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 300.ms, delay: 300.ms).slideY(
                      begin: 0.3,
                      end: 0.0,
                      duration: 300.ms,
                      delay: 300.ms,
                      curve: Curves.easeOutQuad,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Event location
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the event location';
                        }
                        return null;
                      },
                    ).animate().fadeIn(duration: 300.ms, delay: 400.ms).slideY(
                      begin: 0.3,
                      end: 0.0,
                      duration: 300.ms,
                      delay: 400.ms,
                      curve: Curves.easeOutQuad,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Tags section
                    Text(
                      'Event Tags',
                      style: theme.textTheme.titleMedium,
                    ).animate().fadeIn(duration: 300.ms, delay: 500.ms),
                    
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
                      ).animate().fadeIn(duration: 300.ms, delay: 550.ms),
                    
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
                    ).animate().fadeIn(duration: 300.ms, delay: 600.ms).slideY(
                      begin: 0.3,
                      end: 0.0,
                      duration: 300.ms,
                      delay: 600.ms,
                      curve: Curves.easeOutQuad,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Create button
                    SizedBox(
                      width: double.infinity,
                      child: AnimatedGradientButton(
                        text: 'Create Event',
                        onPressed: _createEvent,
                        gradient: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                        icon: const Icon(
                          Icons.event_available,
                          color: Colors.white,
                        ),
                      ),
                    ).animate().fadeIn(duration: 300.ms, delay: 700.ms).slideY(
                      begin: 0.3,
                      end: 0.0,
                      duration: 300.ms,
                      delay: 700.ms,
                      curve: Curves.easeOutQuad,
                    ),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}