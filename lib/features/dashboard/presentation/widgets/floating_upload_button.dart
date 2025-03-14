// File: lib/features/dashboard/presentation/widgets/floating_upload_button.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';

class FloatingUploadButton extends StatefulWidget {
  const FloatingUploadButton({Key? key}) : super(key: key);

  @override
  State<FloatingUploadButton> createState() => _FloatingUploadButtonState();
}

class _FloatingUploadButtonState extends State<FloatingUploadButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }
  
  void _navigateToPhotoUpload(BuildContext context) {
    _toggleExpand(); // Close menu
    context.pushNamed(RouteNames.photoUpload);
  }
  
  void _navigateToEventCreate(BuildContext context) {
    _toggleExpand(); // Close menu
    // TODO: Add event creation route when available
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event creation coming soon!'))
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Photo upload mini FAB
        AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          bottom: _isExpanded ? 160 : 0,
          right: 0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _isExpanded ? 1.0 : 0.0,
            child: FloatingActionButton.small(
              heroTag: 'upload_photo',
              onPressed: _isExpanded ? () => _navigateToPhotoUpload(context) : null,
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              child: const Icon(Icons.photo_camera),
            ).animate(autoPlay: false, controller: _controller)
              .slideY(
                begin: 1.0,
                end: 0.0,
                delay: 100.ms,
                duration: 200.ms,
                curve: Curves.easeOutQuad,
              ),
          ),
        ),
        
        // Event upload mini FAB
        AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          bottom: _isExpanded ? 100 : 0,
          right: 0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _isExpanded ? 1.0 : 0.0,
            child: FloatingActionButton.small(
              heroTag: 'upload_event',
              onPressed: _isExpanded ? () => _navigateToEventCreate(context) : null,
              backgroundColor: theme.colorScheme.secondary,
              foregroundColor: theme.colorScheme.onSecondary,
              child: const Icon(Icons.event),
            ).animate(autoPlay: false, controller: _controller)
              .slideY(
                begin: 1.0,
                end: 0.0,
                delay: 50.ms,
                duration: 200.ms,
                curve: Curves.easeOutQuad,
              ),
          ),
        ),
        
        // Main FAB
        FloatingActionButton(
          heroTag: 'main_upload',
          onPressed: _toggleExpand,
          backgroundColor: theme.colorScheme.primaryContainer,
          foregroundColor: theme.colorScheme.onPrimaryContainer,
          child: AnimatedRotation(
            turns: _isExpanded ? 0.125 : 0,
            duration: const Duration(milliseconds: 300),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}