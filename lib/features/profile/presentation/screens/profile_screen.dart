import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/photo_model.dart';
import '../../../../core/models/event_model.dart';
import '../../../../core/widgets/buttons/animated_button.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/router/route_names.dart';
import 'package:provider/provider.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/firestore_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<PhotoModel> _userPhotos = [];
  List<EventModel> _userEvents = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final firestoreService = Provider.of<FirestoreService>(context, listen: false);
      
      if (authService.isLoggedIn && authService.currentUser != null) {
        final userId = authService.currentUser!.id;
        
        // Fetch user's photos
        final photos = await firestoreService.getPhotos(
          userId: userId,
          limit: 20,
        );
        
        // Fetch user's events - either created by or attending
        final events = await firestoreService.getEvents(
          organizerId: userId,
          limit: 20,
        );
        
        if (mounted) {
          setState(() {
            _userPhotos = photos;
            _userEvents = events;
            _isLoading = false;
          });
        }
      } else {
        // Not logged in, show empty state
        setState(() {
          _userPhotos = [];
          _userEvents = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      
      if (mounted) {
        setState(() {
          _userPhotos = [];
          _userEvents = [];
          _isLoading = false;
        });
      }
    }
  }

  // Navigate to profile edit screen
  void _navigateToProfileEdit() {
    context.pushNamed(RouteNames.profileEdit);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;
    
    if (!authService.isLoggedIn || user == null) {
      return _buildNotLoggedInView(theme);
    }
    
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        child: CustomScrollView(
          slivers: [
            // App Bar with profile info
            SliverAppBar(
              expandedHeight: 240,
              pinned: true,
              actions: [
                // Theme toggle button
                IconButton(
                  icon: const Icon(Icons.brightness_6),
                  onPressed: () {
                    themeProvider.toggleTheme();
                  },
                ),
                // Settings button
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: _navigateToProfileEdit,
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primaryContainer,
                      ],
                    ),
                  ),
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                      : SafeArea(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Profile picture
                              CircleAvatar(
                                radius: 50,
                                backgroundImage: CachedNetworkImageProvider(
                                  user.profileImageUrl ?? 'https://picsum.photos/seed/user/200/200',
                                ),
                                backgroundColor: Colors.white,
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // User name
                              Text(
                                user.name,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              
                              const SizedBox(height: 4),
                              
                              // Member since
                              Text(
                                'Member since ${_formatDate(user.createdAt)}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Stats row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildStat('Photos', _userPhotos.length.toString()),
                                  _buildStat('Events', _userEvents.length.toString()),
                                  _buildStat('Communities', user.communities.length.toString()),
                                ],
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
            
            // Tab bar
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Photos'),
                    Tab(text: 'Events'),
                    Tab(text: 'About'),
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
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Photos tab
                    _buildPhotosGrid(),
                    
                    // Events tab
                    _buildEventsList(),
                    
                    // About tab
                    _buildAboutSection(),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNotLoggedInView(ThemeData theme) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_circle,
              size: 100,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Please log in to view your profile',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Log in to access your photos, events, and communities',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.goNamed(RouteNames.login),
              icon: const Icon(Icons.login),
              label: const Text('Log In'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final months = ['January', 'February', 'March', 'April', 'May', 'June', 
                    'July', 'August', 'September', 'October', 'November', 'December'];
    
    return '${months[date.month - 1]} ${date.year}';
  }
  
  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
  
  Widget _buildPhotosGrid() {
    if (_userPhotos.isEmpty) {
      return _buildEmptyState(
        icon: Icons.photo_library_outlined,
        title: 'No photos yet',
        message: 'Your uploaded photos will appear here',
        buttonText: 'Upload Photo',
        onPressed: () => context.pushNamed(RouteNames.photoUpload),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _userPhotos.length,
      itemBuilder: (context, index) {
        final photo = _userPhotos[index];
        
        return GestureDetector(
          onTap: () {
            context.pushNamed(
              RouteNames.photoDetails,
              pathParameters: {'id': photo.id},
            );
          },
          child: Hero(
            tag: 'profile_photo_${photo.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: photo.thumbnailUrl.isNotEmpty ? photo.thumbnailUrl : photo.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildEventsList() {
    if (_userEvents.isEmpty) {
      return _buildEmptyState(
        icon: Icons.event_busy,
        title: 'No events yet',
        message: 'Events you create or attend will appear here',
        buttonText: 'Create Event',
        onPressed: () => context.pushNamed(RouteNames.eventCreate),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _userEvents.length,
      itemBuilder: (context, index) {
        final event = _userEvents[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: InkWell(
            onTap: () {
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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${event.eventDate.day}/${event.eventDate.month}/${event.eventDate.year}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            event.location,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: event.isAttending
                              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                              : Theme.of(context).colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          event.isAttending ? 'Attending' : 'Not Attending',
                          style: TextStyle(
                            color: event.isAttending
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildAboutSection() {
    final theme = Theme.of(context);
    final user = Provider.of<AuthService>(context).currentUser;
    
    if (user == null) {
      return const Center(child: Text('User data not available'));
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bio section
          Text(
            'About Me',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
          
          const SizedBox(height: 16),
          
          Text(
            'Photography enthusiast and community volunteer. I love capturing moments that tell stories and connecting with like-minded individuals through community events.',
            style: theme.textTheme.bodyLarge,
          ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
          
          const SizedBox(height: 24),
          
          // Interests section
          Text(
            'Interests',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 300.ms),
          
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'Photography',
              'Nature',
              'Community',
              'Events',
              'Volunteering',
              'Travel',
              'Art',
              'Technology',
            ].map((interest) {
              return Chip(
                label: Text(interest),
                backgroundColor: theme.colorScheme.surfaceVariant,
                labelStyle: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              );
            }).toList(),
          ).animate().fadeIn(duration: 300.ms, delay: 400.ms),
          
          const SizedBox(height: 24),
          
          // Contact info section
          Text(
            'Contact',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 500.ms),
          
          const SizedBox(height: 16),
          
          _buildContactItem(
            Icons.email_outlined,
            user.email,
          ).animate().fadeIn(duration: 300.ms, delay: 550.ms),
          
          const SizedBox(height: 32),
          
          // Edit profile button
          Center(
            child: AnimatedGradientButton(
              text: 'Edit Profile',
              onPressed: _navigateToProfileEdit,
              gradient: [
                theme.colorScheme.primary,
                theme.colorScheme.primaryContainer,
              ],
              width: 200,
              icon: const Icon(
                Icons.edit,
                color: Colors.white,
              ),
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 600.ms),
        ],
      ),
    );
  }
  
  Widget _buildContactItem(IconData icon, String text) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: theme.textTheme.bodyLarge,
        ),
      ],
    );
  }
  
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.add),
              label: Text(buttonText),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
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