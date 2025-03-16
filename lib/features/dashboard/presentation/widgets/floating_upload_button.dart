// File: lib/features/dashboard/presentation/widgets/floating_upload_button.dart

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
  
  // Navigate to photo upload screen
  void _navigateToPhotoUpload(BuildContext context) {
    setState(() {
      _isExpanded = false;
      _controller.reverse();
    });
    context.pushNamed(RouteNames.photoUpload);
  }
  
  // Navigate to event creation (we need to create this screen)
  void _navigateToEventCreate(BuildContext context) {
    setState(() {
      _isExpanded = false;
      _controller.reverse();
    });
    
    // For now, show a dialog to collect event details
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final titleController = TextEditingController();
        final descController = TextEditingController();
        final locationController = TextEditingController();
        final dateController = TextEditingController();
        DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
        TimeOfDay selectedTime = TimeOfDay.now();

        return AlertDialog(
          title: const Text('Create New Event'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Event Title',
                    hintText: 'Enter event title',
                  ),
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter event description',
                  ),
                  maxLines: 3,
                ),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    hintText: 'Enter event location',
                  ),
                ),
                const SizedBox(height: 16),
                // Date picker
                ListTile(
                  title: Text('Date: ${selectedDate.toString().split(' ')[0]}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      // Update controller
                      dateController.text = picked.toString().split(' ')[0];
                    }
                  },
                ),
                // Time picker
                ListTile(
                  title: Text('Time: ${selectedTime.format(context)}'),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (picked != null) {
                      // We'd update time here if we had a time controller
                      selectedTime = picked;
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Here we would save the event data to Firebase
                // For now, just show a success message
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Event created successfully!')),
                );
              },
              child: const Text('Create Event'),
            ),
          ],
        );
      },
    );
  }

  // Navigate to join community screen
  void _navigateToJoinCommunity(BuildContext context) {
    setState(() {
      _isExpanded = false;
      _controller.reverse();
    });
    
    // Show a dialog to search for communities to join
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final searchController = TextEditingController();
        
        return AlertDialog(
          title: const Text('Join a Community'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  labelText: 'Search Communities',
                  hintText: 'Enter community name',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Communities are private. You need an invitation code to join.'),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Invitation Code',
                  hintText: 'Enter community invitation code',
                ),
              ),
              const SizedBox(height: 16),
              // Sample community list
              const ListTile(
                leading: CircleAvatar(
                  child: Icon(Icons.camera_alt),
                ),
                title: Text('Photography Enthusiasts'),
                subtitle: Text('120 members'),
                trailing: Icon(Icons.lock),
              ),
              const ListTile(
                leading: CircleAvatar(
                  child: Icon(Icons.nature),
                ),
                title: Text('Nature Photographers'),
                subtitle: Text('85 members'),
                trailing: Icon(Icons.lock),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Here we would process the join request
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Join request sent!')),
                );
              },
              child: const Text('Request to Join'),
            ),
          ],
        );
      },
    );
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
          
          // Join community button
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
                  heroTag: 'join_community',
                  onPressed: () => _navigateToJoinCommunity(context),
                  backgroundColor: theme.colorScheme.tertiaryContainer,
                  foregroundColor: theme.colorScheme.onTertiaryContainer,
                  icon: const Icon(Icons.people),
                  label: const Text('Join Community'),
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
            child: AnimatedRotation(
              turns: _controller.value * 0.125,
              duration: const Duration(milliseconds: 250),
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}