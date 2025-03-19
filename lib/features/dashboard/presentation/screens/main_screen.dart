// lib/features/dashboard/presentation/screens/main_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/navigation/animated_bottom_nav.dart';
import '../../../../core/router/route_names.dart';
import '../../../../services/auth_service.dart';
import '../../../../features/photos/presentation/screens/photos_screen.dart';
import '../../../../features/events/presentation/screens/events_screen.dart';
import '../../../../features/community/presentation/screens/community_screen.dart';
import '../../../../features/profile/presentation/screens/profile_screen.dart';
import '../widgets/floating_upload_button.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late TabController _tabController;
  bool _hasJoinedCommunity = false;
  bool _isChecking = true;
  
  final List<Widget> _screens = [
    const PhotosScreen(),
    const EventsScreen(),
    const CommunityScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _tabController = TabController(
      length: _screens.length,
      vsync: this,
      initialIndex: _currentIndex,
    );
    _checkCommunityMembership();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }
  
  // Check if user has joined any community
  Future<void> _checkCommunityMembership() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    if (authService.isLoggedIn && authService.currentUser != null) {
      // User is logged in, check if they are a member of any community
      setState(() {
        _hasJoinedCommunity = authService.currentUser!.communities.isNotEmpty;
        _isChecking = false;
      });
      
      // If not a member of any community, prompt them but don't force redirect
      if (!_hasJoinedCommunity && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_currentIndex != 2) { // If not already on the Community tab
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Join a community to enhance your experience!'),
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: 'Browse',
                  onPressed: () {
                    context.pushNamed(RouteNames.communities);
                  },
                ),
              ),
            );
          }
        });
      }
    } else {
      // User is not logged in
      setState(() {
        _hasJoinedCommunity = false;
        _isChecking = false;
      });
    }
  }

  void _onTabTapped(int index) {
    // When switching tabs, scroll to top of the selected tab's content
    if (_currentIndex == index) {
      // Handle scroll to top when tapping the same tab again
      if (index == 0) {
        // Reset PhotosScreen scroll position
      } else if (index == 1) {
        // Reset EventsScreen scroll position
      }
    } else {
      setState(() {
        _currentIndex = index;
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  Widget _buildFloatingActionButton() {
    // Show the appropriate FAB based on the current tab
    switch (_currentIndex) {
      case 0: // Photos tab
        return FloatingActionButton(
          onPressed: () => context.pushNamed(RouteNames.photoUpload),
          tooltip: 'Upload Photo',
          child: const Icon(Icons.add_a_photo),
        ).animate().scale(
          duration: 300.ms,
          curve: Curves.easeOutBack,
        );
      case 1: // Events tab
        return FloatingActionButton(
          onPressed: () => context.pushNamed(RouteNames.eventCreate),
          tooltip: 'Create Event',
          child: const Icon(Icons.event_available),
        ).animate().scale(
          duration: 300.ms,
          curve: Curves.easeOutBack,
        );
      case 2: // Community tab
        return FloatingActionButton(
          onPressed: () => context.pushNamed(RouteNames.communityCreate),
          tooltip: 'Create Community',
          child: const Icon(Icons.group_add),
        ).animate().scale(
          duration: 300.ms,
          curve: Curves.easeOutBack,
        );
      default:
        return const SizedBox.shrink(); // No FAB for profile tab
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Define nav items with gradient colors
    final List<BottomNavItem> navItems = [
      NavItems.explore(color: theme.colorScheme.primary),
      NavItems.events(color: theme.colorScheme.secondary),
      NavItems.community(color: theme.colorScheme.tertiary),
      NavItems.profile(),
    ];
    
    if (_isChecking) {
      // Show loading state while checking community membership
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Loading your communities...',
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      bottomNavigationBar: AnimatedBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: navItems,
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }
}