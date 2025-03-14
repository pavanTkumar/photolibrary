import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/theme_extensions.dart';

class AnimatedEventCard extends StatefulWidget {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final DateTime eventDate;
  final String location;
  final String organizerName;
  final int attendeeCount;
  final bool isAttending;
  final VoidCallback onAttendToggle;
  final int index;

  const AnimatedEventCard({
    Key? key,
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.eventDate,
    required this.location,
    required this.organizerName,
    required this.attendeeCount,
    required this.isAttending,
    required this.onAttendToggle,
    required this.index,
  }) : super(key: key);

  @override
  State<AnimatedEventCard> createState() => _AnimatedEventCardState();
}

class _AnimatedEventCardState extends State<AnimatedEventCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHovering = false;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>()!;
    
    // Format dates
    final dateFormat = DateFormat.yMMMd();
    final timeFormat = DateFormat.jm();
    final formattedDate = dateFormat.format(widget.eventDate);
    final formattedTime = timeFormat.format(widget.eventDate);
    
    // Calculate if event is upcoming, ongoing, or past
    final now = DateTime.now();
    final isUpcoming = widget.eventDate.isAfter(now);
    final isPast = widget.eventDate.isBefore(now.subtract(const Duration(hours: 3)));
    
    String eventStatus = isUpcoming ? 'Upcoming' : (isPast ? 'Past' : 'Live');
    Color statusColor = isUpcoming
        ? theme.colorScheme.primary
        : (isPast ? Colors.grey : Colors.green);
    
    return Animate(
      effects: [
        FadeEffect(delay: (widget.index * 50).ms, duration: 300.ms),
        SlideEffect(
          delay: (widget.index * 50).ms,
          duration: 300.ms,
          begin: const Offset(0, 0.2),
          end: const Offset(0, 0),
        ),
      ],
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: GestureDetector(
          onTap: () {
            context.goNamed(
              RouteNames.eventDetails,
              pathParameters: {'id': widget.id},
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: customTheme.eventCardBackground,
              borderRadius: customTheme.defaultBorderRadius,
              boxShadow: _isHovering
                  ? [
                      BoxShadow(
                        color: Colors.black.withAlpha(26),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Use min size to prevent expansion
              children: [
                // Image with event status indicator
                Stack(
                  children: [
                    // Event image
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(customTheme.defaultBorderRadius.topLeft.x),
                        topRight: Radius.circular(customTheme.defaultBorderRadius.topRight.x),
                      ),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Hero(
                          tag: 'event_${widget.id}',
                          child: CachedNetworkImage(
                            imageUrl: widget.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: theme.colorScheme.secondary.withOpacity(0.1),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: theme.colorScheme.secondary.withOpacity(0.1),
                              child: Icon(
                                Icons.broken_image,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Event status chip
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withAlpha(230),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          eventStatus,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Content padding
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, // Use min size to prevent expansion
                    children: [
                      // Title
                      Text(
                        widget.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1, // Limit to 1 line to prevent overflow
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Date and time
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '$formattedDate at $formattedTime',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Location
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.location,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Description - Limited to 1 line
                      Text(
                        widget.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        maxLines: 1, // Limit to 1 line to prevent overflow
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Organizer and Attendees
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Organizer
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Organized by',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                                Text(
                                  widget.organizerName,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          
                          // Attendee count
                          Row(
                            children: [
                              Icon(
                                Icons.people,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.attendeeCount}',
                                style: theme.textTheme.labelMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Attend button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: widget.onAttendToggle,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.isAttending
                                ? theme.colorScheme.primary
                                : theme.colorScheme.secondary.withOpacity(0.1),
                            foregroundColor: widget.isAttending
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                widget.isAttending
                                    ? Icons.check
                                    : Icons.add,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.isAttending ? 'Attending' : 'Attend',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}