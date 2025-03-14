import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/models/photo_model.dart';
import '../../../../core/models/event_model.dart';
import '../../../../core/widgets/buttons/animated_button.dart';
import '../../../../core/theme/theme_provider.dart';
import 'package:provider/provider.dart';

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
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (mounted) {
      setState(() {
        _userPhotos = PhotoModel.sampleList(6);
        _userEvents = EventModel.sampleList(4);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with profile info
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  // Navigate to settings
                },
              ),
              // Fixed theme toggle button
              IconButton(
                icon: Icon(
                  themeProvider.themeMode == ThemeMode.dark
                      ? Icons.light_mode
                      : Icons.dark_mode,
                ),
                onPressed: () {
                  // Toggle theme without navigation
                  themeProvider.toggleTheme();
                },
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
                              backgroundImage: const CachedNetworkImageProvider(
                                'https://picsum.photos/seed/user/200/200',
                              ),
                              backgroundColor: Colors.white,
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // User name
                            Text(
                              'John Doe',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            
                            const SizedBox(height: 4),
                            
                            // Member since
                            Text(
                              'Member since January 2023',
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
                                _buildStat('Following', '124'),
                                _buildStat('Followers', '56'),
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
    );
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
            // Navigate to photo details
          },
          child: Hero(
            tag: 'profile_photo_${photo.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: photo.imageUrl,
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
    final theme = Theme.of(context);
    
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
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${event.eventDate.day}/${event.eventDate.month}/${event.eventDate.year}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          event.location,
                          style: theme.textTheme.bodyMedium,
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
                            ? theme.colorScheme.primary.withOpacity(0.1)
                            : theme.colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        event.isAttending ? 'Attending' : 'Not Attending',
                        style: TextStyle(
                          color: event.isAttending
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
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
        );
      },
    );
  }
  
  Widget _buildAboutSection() {
    final theme = Theme.of(context);
    
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
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Photography enthusiast and community volunteer. I love capturing moments that tell stories and connecting with like-minded individuals through community events.',
            style: theme.textTheme.bodyLarge,
          ),
          
          const SizedBox(height: 24),
          
          // Interests section
          Text(
            'Interests',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
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
          ),
          
          const SizedBox(height: 24),
          
          // Contact info section
          Text(
            'Contact',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildContactItem(
            Icons.email_outlined,
            'john.doe@example.com',
          ),
          
          const SizedBox(height: 8),
          
          _buildContactItem(
            Icons.phone_outlined,
            '+1 (555) 123-4567',
          ),
          
          const SizedBox(height: 8),
          
          _buildContactItem(
            Icons.location_on_outlined,
            'New York, USA',
          ),
          
          const SizedBox(height: 32),
          
          // Edit profile button
          Center(
            child: AnimatedGradientButton(
              text: 'Edit Profile',
              onPressed: () {
                // Navigate to edit profile
              },
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
          ),
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