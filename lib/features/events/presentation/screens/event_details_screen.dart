import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/event_model.dart';
import '../../../../core/models/photo_model.dart';
import '../../../../core/widgets/buttons/animated_button.dart';

class EventDetailsScreen extends StatefulWidget {
  final String eventId;

  const EventDetailsScreen({
    Key? key,
    required this.eventId,
  }) : super(key: key);

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> with SingleTickerProviderStateMixin {
  late EventModel _event;
  bool _isLoading = true;
  bool _isAttending = false;
  final TextEditingController _commentController = TextEditingController();
  late AnimationController _attendController;

  @override
  void initState() {
    super.initState();
    _loadEventDetails();
    _attendController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    _attendController.dispose();
    super.dispose();
  }

  Future<void> _loadEventDetails() async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 1000));

    if (mounted) {
      // For demo, create a sample event
      final sampleEvent = EventModel.sample(
        index: int.tryParse(widget.eventId.split('_').last) ?? 0,
      );
      
      setState(() {
        _event = sampleEvent;
        _isAttending = sampleEvent.isAttending;
        _isLoading = false;
      });
    }
  }

  void _toggleAttending() {
    setState(() {
      _isAttending = !_isAttending;
      if (_isAttending) {
        _attendController.forward();
      } else {
        _attendController.reverse();
      }
      
      _event = _event.toggleAttending();
    });
  }

  void _submitComment() {
    if (_commentController.text.trim().isEmpty) return;

    final newComment = CommentModel(
      id: 'new_comment_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'current_user',
      userName: 'Current User',
      userAvatar: 'https://picsum.photos/seed/me/100/100',
      content: _commentController.text.trim(),
      timestamp: DateTime.now(),
    );

    setState(() {
      // Fix: Cast explicitly to List<CommentModel> when creating the updated list
      final List<CommentModel> currentComments = List<CommentModel>.from(_event.comments ?? []);
      final updatedComments = [newComment, ...currentComments];
      _event = _event.copyWith(comments: updatedComments);
      _commentController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Event Details'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Format date and time
    final dateFormat = DateFormat.yMMMMd();
    final timeFormat = DateFormat.jm();
    final formattedDate = dateFormat.format(_event.eventDate);
    final formattedTime = timeFormat.format(_event.eventDate);
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with event image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'event_${_event.id}',
                child: CachedNetworkImage(
                  imageUrl: _event.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: theme.colorScheme.secondary.withOpacity(0.1),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: theme.colorScheme.secondary.withOpacity(0.1),
                    child: const Icon(
                      Icons.broken_image,
                      size: 50,
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Event Details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    _event.title,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fade(duration: 300.ms).slideY(
                    begin: 0.2,
                    end: 0,
                    duration: 300.ms,
                    curve: Curves.easeOut,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Date, time, and location
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          formattedDate,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ).animate().fade(duration: 300.ms, delay: 100.ms).slideY(
                    begin: 0.2,
                    end: 0,
                    duration: 300.ms,
                    delay: 100.ms,
                    curve: Curves.easeOut,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formattedTime,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ).animate().fade(duration: 300.ms, delay: 150.ms).slideY(
                    begin: 0.2,
                    end: 0,
                    duration: 300.ms,
                    delay: 150.ms,
                    curve: Curves.easeOut,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _event.location,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ).animate().fade(duration: 300.ms, delay: 200.ms).slideY(
                    begin: 0.2,
                    end: 0,
                    duration: 300.ms,
                    delay: 200.ms,
                    curve: Curves.easeOut,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Organizer and attendee count
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundImage: CachedNetworkImageProvider(
                          'https://picsum.photos/seed/organizer/100/100',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Organized by',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          Text(
                            _event.organizerName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Attendees',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          Text(
                            _event.attendeeCount.toString(),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ).animate().fade(duration: 300.ms, delay: 250.ms).slideY(
                    begin: 0.2,
                    end: 0,
                    duration: 300.ms,
                    delay: 250.ms,
                    curve: Curves.easeOut,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Attend button
                  SizedBox(
                    width: double.infinity,
                    child: AnimatedGradientButton(
                      text: _isAttending ? 'Attending' : 'Attend Event',
                      onPressed: _toggleAttending,
                      gradient: _isAttending
                          ? [
                              theme.colorScheme.primary,
                              theme.colorScheme.primary,
                            ]
                          : [
                              theme.colorScheme.primary,
                              theme.colorScheme.secondary,
                            ],
                      icon: Icon(
                        _isAttending ? Icons.check : Icons.add,
                        color: Colors.white,
                      ).animate(controller: _attendController)
                        .custom(
                          builder: (context, value, child) {
                            return Transform.rotate(
                              angle: 2 * 3.14 * value,
                              child: child,
                            );
                          },
                          begin: 0.0,
                          end: 1.0,
                          duration: 300.ms,
                        ),
                    ),
                  ).animate().fade(duration: 300.ms, delay: 300.ms).slideY(
                    begin: 0.2,
                    end: 0,
                    duration: 300.ms,
                    delay: 300.ms,
                    curve: Curves.easeOut,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Description section
                  Text(
                    'About this event',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fade(duration: 300.ms, delay: 350.ms).slideY(
                    begin: 0.2,
                    end: 0,
                    duration: 300.ms,
                    delay: 350.ms,
                    curve: Curves.easeOut,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    _event.description,
                    style: theme.textTheme.bodyLarge,
                  ).animate().fade(duration: 300.ms, delay: 400.ms).slideY(
                    begin: 0.2,
                    end: 0,
                    duration: 300.ms,
                    delay: 400.ms,
                    curve: Curves.easeOut,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Tags section
                  if (_event.tags.isNotEmpty) ...[
                    Text(
                      'Tags',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _event.tags.map((tag) {
                        return Chip(
                          label: Text('#$tag'),
                          backgroundColor: theme.colorScheme.secondary.withOpacity(0.1),
                          labelStyle: TextStyle(
                            color: theme.colorScheme.onSurface,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Event photos section
                  if (_event.photos != null && _event.photos!.isNotEmpty) ...[
                    Text(
                      'Event Photos',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fade(duration: 300.ms, delay: 450.ms).slideY(
                      begin: 0.2,
                      end: 0,
                      duration: 300.ms,
                      delay: 450.ms,
                      curve: Curves.easeOut,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _event.photos!.length,
                        itemBuilder: (context, index) {
                          final photo = _event.photos![index];
                          
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: GestureDetector(
                                onTap: () {
                                  // Navigate to photo details
                                },
                                child: CachedNetworkImage(
                                  imageUrl: photo.imageUrl,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ).animate().fade(
                            duration: 300.ms,
                            delay: 500.ms + (index * 50).ms,
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                  ],
                  
                  // Comments section header
                  Row(
                    children: [
                      Text(
                        'Comments',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${_event.comments?.length ?? 0})',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ).animate().fade(duration: 300.ms, delay: 550.ms).slideY(
                    begin: 0.2,
                    end: 0,
                    duration: 300.ms,
                    delay: 550.ms,
                    curve: Curves.easeOut,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Comment input
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        radius: 18,
                        backgroundImage: CachedNetworkImageProvider(
                          'https://picsum.photos/seed/me/100/100',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintText: 'Add a comment...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.secondary.withOpacity(0.1),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          maxLines: 3,
                          minLines: 1,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedIconButton(
                        icon: Icon(
                          Icons.send,
                          color: theme.colorScheme.onPrimary,
                          size: 20,
                        ),
                        onPressed: _submitComment,
                        backgroundColor: theme.colorScheme.primary,
                        size: 40,
                      ),
                    ],
                  ).animate().fade(duration: 300.ms, delay: 600.ms).slideY(
                    begin: 0.2,
                    end: 0,
                    duration: 300.ms,
                    delay: 600.ms,
                    curve: Curves.easeOut,
                  ),
                ],
              ),
            ),
          ),
          
          // Comments list
          if (_event.comments != null && _event.comments!.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final comment = _event.comments![index];
                  final commentDate = DateFormat.yMMMd().add_jm().format(comment.timestamp);
                  
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: CachedNetworkImageProvider(
                            comment.userAvatar,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    comment.userName,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    commentDate,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                comment.content,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fade(
                    duration: 300.ms,
                    delay: 650.ms + (index * 50).ms,
                  );
                },
                childCount: _event.comments!.length,
              ),
            ),
            
          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
      ),
    );
  }
}