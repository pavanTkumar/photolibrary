// File: lib/features/photos/presentation/screens/photo_details_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/photo_model.dart';
import '../../../../core/widgets/buttons/animated_button.dart';

class PhotoDetailsScreen extends StatefulWidget {
  final String photoId;

  const PhotoDetailsScreen({
    Key? key,
    required this.photoId,
  }) : super(key: key);

  @override
  State<PhotoDetailsScreen> createState() => _PhotoDetailsScreenState();
}

class _PhotoDetailsScreenState extends State<PhotoDetailsScreen> with SingleTickerProviderStateMixin {
  late PhotoModel _photo;
  bool _isLoading = true;
  bool _isLiked = false;
  final TextEditingController _commentController = TextEditingController();
  late AnimationController _likeController;

  @override
  void initState() {
    super.initState();
    _loadPhotoDetails();
    _likeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    _likeController.dispose();
    super.dispose();
  }

  Future<void> _loadPhotoDetails() async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 1000));

    if (mounted) {
      // For demo, create a sample photo
      final samplePhoto = PhotoModel.sample(index: int.tryParse(widget.photoId.split('_').last) ?? 0);
      
      setState(() {
        _photo = samplePhoto;
        _isLiked = samplePhoto.isLiked;
        _isLoading = false;
      });
    }
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        _likeController.forward();
      } else {
        _likeController.reverse();
      }
      
      _photo = _photo.toggleLike();
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
      final List<CommentModel> currentComments = List<CommentModel>.from(_photo.comments ?? []);
      final updatedComments = [newComment, ...currentComments];
      _photo = _photo.copyWith(comments: updatedComments);
      _commentController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Photo Details'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Format date
    final formattedDate = DateFormat.yMMMd().format(_photo.uploadDate);
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'photo_${_photo.id}',
                child: GestureDetector(
                  onTap: () {
                    // Show full-screen photo view
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Scaffold(
                          backgroundColor: Colors.black,
                          body: PhotoView(
                            imageProvider: CachedNetworkImageProvider(
                              _photo.imageUrl,
                            ),
                            minScale: PhotoViewComputedScale.contained,
                            maxScale: PhotoViewComputedScale.covered * 2,
                            backgroundDecoration: const BoxDecoration(
                              color: Colors.black,
                            ),
                            heroAttributes: PhotoViewHeroAttributes(
                              tag: 'fullscreen_photo_${_photo.id}',
                            ),
                          ),
                          appBar: AppBar(
                            backgroundColor: Colors.black38,
                            elevation: 0,
                          ),
                        ),
                      ),
                    );
                  },
                  child: CachedNetworkImage(
                    imageUrl: _photo.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: theme.colorScheme.secondary.withAlpha(25),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: theme.colorScheme.secondary.withAlpha(25),
                      child: const Icon(
                        Icons.broken_image,
                        size: 50,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Photo Details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title with animation
                  Text(
                    _photo.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fade(duration: 300.ms).slideY(
                    begin: 0.2,
                    end: 0,
                    duration: 300.ms,
                    curve: Curves.easeOut,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Uploader info and date
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundImage: CachedNetworkImageProvider(
                          'https://picsum.photos/seed/${_photo.uploaderId}/100/100',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _photo.uploaderName,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        formattedDate,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(180),
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
                  
                  const SizedBox(height: 16),
                  
                  // Description
                  if (_photo.description.isNotEmpty)
                    Text(
                      _photo.description,
                      style: theme.textTheme.bodyMedium,
                    ).animate().fade(duration: 300.ms, delay: 200.ms).slideY(
                      begin: 0.2,
                      end: 0,
                      duration: 300.ms,
                      delay: 200.ms,
                      curve: Curves.easeOut,
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // Action buttons
                  Row(
                    children: [
                      // Like Button
                      AnimatedIconButton(
                        icon: Icon(
                          _isLiked ? Icons.favorite : Icons.favorite_border,
                          color: _isLiked ? Colors.red : theme.colorScheme.onSurface,
                          size: 24,
                        ).animate(controller: _likeController)
                          .scale(
                            begin: const Offset(1, 1),
                            end: const Offset(1.3, 1.3),
                            duration: 150.ms,
                          )
                          .then()
                          .scale(
                            begin: const Offset(1.3, 1.3),
                            end: const Offset(1, 1),
                            duration: 150.ms,
                          ),
                        onPressed: _toggleLike,
                        isCircular: false,
                        backgroundColor: theme.colorScheme.secondary.withAlpha(25),
                        size: 40,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _photo.likeCount.toString(),
                        style: theme.textTheme.bodyMedium,
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Comment Button
                      AnimatedIconButton(
                        icon: Icon(
                          Icons.chat_bubble_outline,
                          color: theme.colorScheme.onSurface,
                          size: 22,
                        ),
                        onPressed: () {
                          // Focus on comment field
                          FocusScope.of(context).requestFocus(FocusNode());
                          _scrollToComments();
                        },
                        isCircular: false,
                        backgroundColor: theme.colorScheme.secondary.withAlpha(25),
                        size: 40,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        (_photo.comments?.length ?? 0).toString(),
                        style: theme.textTheme.bodyMedium,
                      ),
                      
                      const Spacer(),
                      
                      // Share Button
                      AnimatedIconButton(
                        icon: Icon(
                          Icons.share,
                          color: theme.colorScheme.onSurface,
                          size: 22,
                        ),
                        onPressed: () {
                          // Handle share
                        },
                        isCircular: false,
                        backgroundColor: theme.colorScheme.secondary.withAlpha(25),
                        size: 40,
                      ),
                    ],
                  ).animate().fade(duration: 300.ms, delay: 300.ms).slideY(
                    begin: 0.2,
                    end: 0,
                    duration: 300.ms,
                    delay: 300.ms,
                    curve: Curves.easeOut,
                  ),
                  
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  
                  // Tags section
                  if (_photo.tags.isNotEmpty) ...[
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
                      children: _photo.tags.map((tag) {
                        return Chip(
                          label: Text('#$tag'),
                          backgroundColor: theme.colorScheme.secondary.withAlpha(25),
                          labelStyle: TextStyle(
                            color: theme.colorScheme.onSurface,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Comments section header
                  Row(
                    children: [
                      Text(
                        'Comments',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${_photo.comments?.length ?? 0})',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(180),
                        ),
                      ),
                    ],
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
                            fillColor: theme.colorScheme.secondary.withAlpha(25),
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
          if (_photo.comments != null && _photo.comments!.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final comment = _photo.comments![index];
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
                                      color: theme.colorScheme.onSurface.withAlpha(180),
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
                childCount: _photo.comments!.length,
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
  
  void _scrollToComments() {
    // This would scroll to comments section
    // Requires implementation with a ScrollController
  }
}