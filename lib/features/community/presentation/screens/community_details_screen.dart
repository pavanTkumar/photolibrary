// File: lib/features/community/presentation/screens/community_details_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/community_model.dart';
import '../../../../core/models/photo_model.dart';
import '../../../../core/models/event_model.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/buttons/animated_button.dart';
import '../../../../features/photos/presentation/widgets/photo_staggered_grid.dart';

class CommunityDetailsScreen extends StatefulWidget {
  final String communityId;

  const CommunityDetailsScreen({
    Key? key,
    required this.communityId,
  }) : super(key: key);

  @override
  State<CommunityDetailsScreen> createState() => _CommunityDetailsScreenState();
}

class _CommunityDetailsScreenState extends State<CommunityDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  bool _isJoined = false;
  bool _isRequesting = false;
  late CommunityModel _community;
  List<PhotoModel> _photos = [];
  List<EventModel> _events = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCommunityDetails();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadCommunityDetails() async {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (mounted) {
      // Create sample data
      final int index = int.tryParse(widget.communityId.split('_').last) ?? 0;
      final community = CommunityModel.sample(index: index);
      final photos = PhotoModel.sampleList(12);
      final events = EventModel.sampleList(5);
      
      setState(() {
        _community = community;
        _photos = photos;
        _events = events;
        _isJoined = community.memberIds.contains('current_user_id'); // Replace with actual user ID
        _isLoading = false;
      });
    }
  }
  
  void _toggleJoinCommunity() {
    if (_community.isPrivate && !_isJoined) {
      _requestJoinCommunity();
      return;
    }
    
    setState(() {
      _isJoined = !_isJoined;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isJoined ? 'Joined community' : 'Left community'),
        backgroundColor: _isJoined ? Colors.green : Colors.orange,
      ),
    );
  }
  
  Future<void> _requestJoinCommunity() async {
    setState(() {
      _isRequesting = true;
    });
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() {
        _isRequesting = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Join request sent. Waiting for admin approval.'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Community Details'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with community image
          SliverAppBar(
            expandedHeight: 200,
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
                onPressed: () => context.pop(),
              ),
            ),
            actions: [
              if (_isJoined)
                Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.more_vert),
                    color: Colors.white,
                    onPressed: () {
                      // Show community options
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => _buildCommunityOptions(),
                      );
                    },
                  ),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Community image
                  CachedNetworkImage(
                    imageUrl: _community.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: theme.colorScheme.secondary.withOpacity(0.1),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: theme.colorScheme.secondary.withOpacity(0.1),
                      child: const Icon(
                        Icons.broken_image,
                        size: 50,
                      ),
                    ),
                  ),
                  
                  // Gradient overlay for better text visibility
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  
                  // Community info at bottom
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _community.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (_community.isPrivate)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black38,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(
                                      Icons.lock,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Private',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_community.memberIds.length} members • Admin: ${_community.adminName}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Join/Request Button and Description
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Join button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isRequesting ? null : _toggleJoinCommunity,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isJoined
                            ? theme.colorScheme.primary
                            : _community.isPrivate
                                ? theme.colorScheme.surfaceVariant
                                : theme.colorScheme.primaryContainer,
                        foregroundColor: _isJoined
                            ? theme.colorScheme.onPrimary
                            : _community.isPrivate
                                ? theme.colorScheme.onSurfaceVariant
                                : theme.colorScheme.onPrimaryContainer,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: _isRequesting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _isJoined
                                  ? 'Joined'
                                  : _community.isPrivate
                                      ? 'Request to Join'
                                      : 'Join Community',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ).animate().fadeIn(duration: 300.ms).scale(
                    begin: const Offset(0.95, 0.95),
                    end: const Offset(1, 1),
                    duration: 300.ms,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Description
                  Text(
                    'About',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    _community.description,
                    style: theme.textTheme.bodyLarge,
                  ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          
          // Tab Bar
          SliverPersistentHeader(
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Photos'),
                  Tab(text: 'Events'),
                  Tab(text: 'Members'),
                ],
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                indicatorColor: theme.colorScheme.primary,
                indicatorWeight: 3,
              ),
            ),
            pinned: true,
          ),
          
          // Tab content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Photos tab
                _buildPhotosTab(),
                
                // Events tab
                _buildEventsTab(),
                
                // Members tab
                _buildMembersTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _isJoined
          ? FloatingActionButton(
              onPressed: () {
                // Navigate to the appropriate creation screen based on the current tab
                if (_tabController.index == 0) {
                  context.pushNamed(RouteNames.photoUpload);
                } else if (_tabController.index == 1) {
                  context.pushNamed(RouteNames.eventCreate);
                }
              },
              tooltip: _tabController.index == 0 ? 'Upload Photo' : 'Create Event',
              child: Icon(
                _tabController.index == 0 ? Icons.add_a_photo : Icons.add_circle,
              ),
            ).animate().scale(
              duration: 300.ms,
              curve: Curves.easeOutBack,
            )
          : null,
    );
  }
  
  Widget _buildCommunityOptions() {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share Community'),
            onTap: () {
              Navigator.pop(context);
              // Implementation for sharing
            },
          ),
          if (_isJoined)
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Leave Community'),
              onTap: () {
                Navigator.pop(context);
                _toggleJoinCommunity();
              },
            ),
          ListTile(
            leading: const Icon(Icons.flag),
            title: const Text('Report Community'),
            onTap: () {
              Navigator.pop(context);
              // Implementation for reporting
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildPhotosTab() {
    if (_photos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'No photos in this community yet',
              style: TextStyle(fontSize: 18),
            ),
            if (_isJoined) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  context.pushNamed(RouteNames.photoUpload);
                },
                icon: const Icon(Icons.add_a_photo),
                label: const Text('Upload Photo'),
              ),
            ],
          ],
        ),
      );
    }
    
    return PhotoStaggeredGrid(
      photos: _photos,
      onLike: (photoId) {
        // Implementation for liking a photo
        setState(() {
          final index = _photos.indexWhere((photo) => photo.id == photoId);
          if (index != -1) {
            _photos[index] = _photos[index].toggleLike();
          }
        });
      },
      onPhotoTap: (photoId) {
        // Navigate to photo details
        context.pushNamed(
          RouteNames.photoDetails,
          pathParameters: {'id': photoId},
        );
      },
      isLoading: false,
    );
  }
  
  Widget _buildEventsTab() {
    if (_events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'No events in this community yet',
              style: TextStyle(fontSize: 18),
            ),
            if (_isJoined) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  context.pushNamed(RouteNames.eventCreate);
                },
                icon: const Icon(Icons.add_circle),
                label: const Text('Create Event'),
              ),
            ],
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _events.length,
      itemBuilder: (context, index) {
        final event = _events[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () {
              // Navigate to event details
              context.pushNamed(
                RouteNames.eventDetails,
                pathParameters: {'id': event.id},
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event image
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: CachedNetworkImage(
                      imageUrl: event.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                
                // Event details
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            '${event.eventDate.day}/${event.eventDate.month}/${event.eventDate.year}',
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              event.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('${event.attendeeCount} attending'),
                          const SizedBox(width: 8),
                          Icon(
                            event.isAttending
                                ? Icons.check_circle
                                : Icons.check_circle_outline,
                            color: event.isAttending ? Colors.green : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ).animate().fade(
          duration: 300.ms,
          delay: (50 * index).ms,
        ).slideY(
          begin: 0.2,
          end: 0,
          duration: 300.ms,
          delay: (50 * index).ms,
          curve: Curves.easeOutQuad,
        );
      },
    );
  }
  
  Widget _buildMembersTab() {
    // Generate some sample members
    final members = List.generate(
      _community.memberIds.length,
      (index) => {
        'id': _community.memberIds[index],
        'name': 'Member ${index + 1}',
        'avatar': 'https://picsum.photos/seed/member$index/100/100',
        'isAdmin': _community.adminId == _community.memberIds[index],
        'isModerator': _community.moderatorIds.contains(_community.memberIds[index]),
      },
    );
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(
                member['avatar'] as String,
              ),
            ),
            title: Text(member['name'] as String),
            subtitle: Text(
              member['isAdmin'] == true
                  ? 'Admin'
                  : member['isModerator'] == true
                      ? 'Moderator'
                      : 'Member',
              style: TextStyle(
                color: member['isAdmin'] == true
                    ? Colors.red
                    : member['isModerator'] == true
                        ? Colors.blue
                        : null,
              ),
            ),
          ),
        ).animate().fade(
          duration: 300.ms,
          delay: (30 * index).ms,
        );
      },
    );
  }
}

// Sliver app bar delegate for the tab bar
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}