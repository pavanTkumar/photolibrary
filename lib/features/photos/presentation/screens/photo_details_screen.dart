// lib/features/photos/presentation/screens/photo_details_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/photo_model.dart';
import '../../../../core/widgets/buttons/animated_button.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/firestore_service.dart';
import 'package:share_plus/share_plus.dart';

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
  StreamSubscription<PhotoModel?>? _photoSubscription;
  final ScrollController _scrollController = ScrollController();

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
    _photoSubscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadPhotoDetails() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final firestoreService = Provider.of<FirestoreService>(context, listen: false);
      
      // Initial load to show data quickly
      final photo = await firestoreService.getPhoto(widget.photoId);
      
      if (mounted) {
        if (photo == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo not found'),
              backgroundColor: Colors.red,
            ),
          );
          context.pop();
          return;
        }
        
        setState(() {
          _photo = photo;
          _isLiked = photo.isLiked;
          _isLoading = false;
        });
        
        // If the photo was liked, show the heart animation
        if (_isLiked) {
          _likeController.value = 1.0;
        }
        
        // Set up real-time updates
        _photoSubscription = firestoreService.getPhotoStream(widget.photoId).listen((updatedPhoto) {
          if (mounted && updatedPhoto != null) {
            final bool wasLiked = _isLiked;
            final bool isNowLiked = updatedPhoto.isLiked;
            
            setState(() {
              _photo = updatedPhoto;
              _isLiked = isNowLiked;
            });
            
            // Trigger heart animation if like status changed
            if (!wasLiked && isNowLiked) {
              _likeController.forward();
            } else if (wasLiked && !isNowLiked) {
              _likeController.reverse();
            }
          }
        }, onError: (error) {
          debugPrint('Error in photo stream: $error');
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _toggleLike() {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    
    if (authService.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to like photos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final userId = authService.currentUser!.id;
    
    // Update UI immediately for better UX
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        _likeController.forward();
        _photo = _photo.copyWith(
          isLiked: true,
          likeCount: _photo.likeCount + 1,
          likedBy: [..._photo.likedBy, userId],
        );
      } else {
        _likeController.reverse();
        _photo = _photo.copyWith(
          isLiked: false,
          likeCount: _photo.likeCount - 1,
          likedBy: _photo.likedBy.where((id) => id != userId).toList(),
        );
      }
    });
    
    // Update in Firestore
    if (_isLiked) {
      firestoreService.likePhoto(_photo.id, userId).catchError((error) {
        // Revert UI if the operation fails
        if (mounted) {
          setState(() {
            _isLiked = false;
            _likeController.reverse();
            _photo = _photo.copyWith(
              isLiked: false,
              likeCount: _photo.likeCount - 1,
              likedBy: _photo.likedBy.where((id) => id != userId).toList(),
            );
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error liking photo: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    } else {
      firestoreService.unlikePhoto(_photo.id, userId).catchError((error) {
        // Revert UI if the operation fails
        if (mounted) {
          setState(() {
            _isLiked = true;
            _likeController.forward();
            _photo = _photo.copyWith(
              isLiked: true,
              likeCount: _photo.likeCount + 1,
              likedBy: [..._photo.likedBy, userId],
            );
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error unliking photo: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    }
  }
  
  void _sharePhoto() {
    final shareText = 'Check out this photo: "${_photo.title}" by ${_photo.uploaderName} on Fish Pond';
    Share.share(shareText);
  }

  void _submitComment() {
    if (_commentController.text.trim().isEmpty) return;
    
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    
    if (authService.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to comment'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final newComment = CommentModel(
      id: 'new_comment_${DateTime.now().millisecondsSinceEpoch}',
      userId: authService.currentUser!.id,
      userName: authService.currentUser!.name,
      userAvatar: authService.currentUser!.profileImageUrl ?? 'https://picsum.photos/seed/me/100/100',
      content: _commentController.text.trim(),
      timestamp: DateTime.now(),
    );
    
    // Update UI immediately for better UX
    setState(() {
      final List<CommentModel> currentComments = List<CommentModel>.from(_photo.comments ?? []);
      final updatedComments = [newComment, ...currentComments];
      _photo = _photo.copyWith(comments: updatedComments);
      _commentController.clear();
    });
    
    // Add to Firestore
    firestoreService.addComment(
      _photo.id,
      newComment.userId,
      newComment.userName,
      newComment.userAvatar,
      newComment.content,
    ).catchError((error) {
      // If the operation fails, remove the comment from UI
      if (mounted) {
        setState(() {
          final List<CommentModel> currentComments = List<CommentModel>.from(_photo.comments ?? []);
          currentComments.removeWhere((comment) => comment.id == newComment.id);
          _photo = _photo.copyWith(comments: currentComments);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding comment: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  void _scrollToComments() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Photo Details'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              try {
                context.pop();
              } catch (e) {
                context.go('/main');
              }
            },
          ),
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
        controller: _scrollController,
        slivers: [
          // App Bar with photo image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black26,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                color: Colors.white,
                onPressed: () {
                  try {
                    context.pop();
                  } catch (e) {
                    context.go('/main');
                  }
                },
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.share),
                  color: Colors.white,
                  onPressed: _sharePhoto,
                ),
              ),
            ],
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
                            leading: IconButton(
                              icon: const Icon(Icons.arrow_back),
                              color: Colors.white,
                              onPressed: () {
                                try {
                                  Navigator.of(context).pop();
                                } catch (e) {
                                  context.go('/main');
                                }
                              },
                            ),
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
                  // Title
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
                        onPressed: _sharePhoto,
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
                      Consumer<AuthService>(
                        builder: (context, authService, child) {
                          final user = authService.currentUser;
                          return CircleAvatar(
                            radius: 18,
                            backgroundImage: CachedNetworkImageProvider(
                              user?.profileImageUrl ?? 'https://picsum.photos/seed/me/100/100',
                            ),
                          );
                        },
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
                    delay: Duration(milliseconds: 650 + (index * 50)),
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
}