// File: lib/features/photos/presentation/widgets/animated_photo_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/theme_extensions.dart';

class AnimatedPhotoCard extends StatefulWidget {
  final String id;
  final String imageUrl;
  final String title;
  final String uploaderName;
  final DateTime uploadDate;
  final int likeCount;
  final bool isLiked;
  final VoidCallback onLike;
  final VoidCallback? onTap;
  final int index;

  const AnimatedPhotoCard({
    Key? key,
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.uploaderName,
    required this.uploadDate,
    required this.likeCount,
    required this.isLiked,
    required this.onLike,
    this.onTap,
    required this.index,
  }) : super(key: key);

  @override
  State<AnimatedPhotoCard> createState() => _AnimatedPhotoCardState();
}

class _AnimatedPhotoCardState extends State<AnimatedPhotoCard> with SingleTickerProviderStateMixin {
  late AnimationController _heartController;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    // Initialize the heart animation state
    if (widget.isLiked) {
      _heartController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }
  
  @override
  void didUpdateWidget(AnimatedPhotoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update heart animation state if liked status changes
    if (widget.isLiked != oldWidget.isLiked) {
      if (widget.isLiked) {
        _heartController.forward();
      } else {
        _heartController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>() ?? CustomThemeExtension.light;
    
    // Format date
    final formattedDate = DateFormat.yMMMd().format(widget.uploadDate);
    
    return Animate(
      effects: [
        FadeEffect(delay: (widget.index * 100).ms, duration: 300.ms),
        SlideEffect(
          delay: (widget.index * 100).ms, 
          duration: 300.ms,
          begin: const Offset(0, 0.2),
          end: const Offset(0, 0),
        ),
      ],
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            decoration: BoxDecoration(
              color: customTheme.cardBackground,
              borderRadius: customTheme.defaultBorderRadius,
              border: Border.all(
                color: customTheme.photoCardBorder,
                width: 1,
              ),
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
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image container with curved top
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(customTheme.defaultBorderRadius.topLeft.x),
                    topRight: Radius.circular(customTheme.defaultBorderRadius.topRight.x),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Hero(
                      tag: 'photo_${widget.id}',
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
                
                // Content padding
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        widget.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Uploader and date
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'By ${widget.uploaderName}',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            formattedDate,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Like button and count
                      GestureDetector(
                        // Important: Add this behavior to prevent the tap from bubbling up
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          widget.onLike();
                          if (widget.isLiked) {
                            _heartController.reverse();
                          } else {
                            _heartController.forward();
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(4.0), // Increase the tap target
                              child: Icon(
                                widget.isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: widget.isLiked
                                    ? Colors.red
                                    : theme.colorScheme.onSurface,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.likeCount}',
                              style: theme.textTheme.labelMedium,
                            ),
                          ],
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