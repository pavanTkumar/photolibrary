// Complete replacement for lib/features/dashboard/presentation/widgets/floating_upload_button.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';

class FloatingUploadButton extends StatefulWidget {
  const FloatingUploadButton({Key? key}) : super(key: key);

  @override
  State<FloatingUploadButton> createState() => _FloatingUploadButtonState();
}

class _FloatingUploadButtonState extends State<FloatingUploadButton> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
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
    setState(() {
      _isExpanded = false;
      _controller.reverse();
    });
    
    context.pushNamed(RouteNames.photoUpload);
  }

  void _navigateToEventCreate(BuildContext context) {
    setState(() {
      _isExpanded = false;
      _controller.reverse();
    });
    
    context.pushNamed(RouteNames.eventCreate);
  }

  void _navigateToCommunityCreate(BuildContext context) {
    setState(() {
      _isExpanded = false;
      _controller.reverse();
    });
    
    context.pushNamed(RouteNames.communityCreate);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: 320, // Fixed height to contain all buttons
      width: 220, // Width for extended buttons
      alignment: Alignment.bottomRight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Photo upload button
          AnimatedOpacity(
            opacity: _isExpanded ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: _isExpanded ? 48 : 0,
              margin: EdgeInsets.only(bottom: _isExpanded ? 16.0 : 0),
              child: Visibility(
                visible: _isExpanded,
                child: FloatingActionButton.extended(
                  heroTag: 'upload_photo',
                  onPressed: () => _navigateToPhotoUpload(context),
                  backgroundColor: theme.colorScheme.primaryContainer,
                  foregroundColor: theme.colorScheme.onPrimaryContainer,
                  icon: const Icon(Icons.photo_camera),
                  label: const Text('Upload Photo'),
                ),
              ),
            ),
          ),
          
          // Event creation button
          AnimatedOpacity(
            opacity: _isExpanded ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: _isExpanded ? 48 : 0,
              margin: EdgeInsets.only(bottom: _isExpanded ? 16.0 : 0),
              child: Visibility(
                visible: _isExpanded,
                child: FloatingActionButton.extended(
                  heroTag: 'create_event',
                  onPressed: () => _navigateToEventCreate(context),
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  foregroundColor: theme.colorScheme.onSecondaryContainer,
                  icon: const Icon(Icons.event),
                  label: const Text('Create Event'),
                ),
              ),
            ),
          ),
          
          // Community creation button
          AnimatedOpacity(
            opacity: _isExpanded ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: _isExpanded ? 48 : 0,
              margin: EdgeInsets.only(bottom: _isExpanded ? 16.0 : 0),
              child: Visibility(
                visible: _isExpanded,
                child: FloatingActionButton.extended(
                  heroTag: 'create_community',
                  onPressed: () => _navigateToCommunityCreate(context),
                  backgroundColor: theme.colorScheme.tertiaryContainer,
                  foregroundColor: theme.colorScheme.onTertiaryContainer,
                  icon: const Icon(Icons.people),
                  label: const Text('Create Community'),
                ),
              ),
            ),
          ),
          
          // Main FAB
          FloatingActionButton(
            heroTag: 'main_fab',
            onPressed: _toggleExpand,
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _controller.value * 0.75, // 0.75 radians is about 45 degrees
                  child: Icon(_isExpanded ? Icons.close : Icons.add),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}