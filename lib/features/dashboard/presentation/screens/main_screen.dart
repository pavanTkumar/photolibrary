import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/navigation/animated_bottom_nav.dart';
import '../../../../core/router/route_names.dart';
import '../../../../services/auth_service.dart';
import '../../../photos/presentation/screens/photos_screen.dart';
import '../../../events/presentation/screens/events_screen.dart';
import '../../../community/presentation/screens/community_screen.dart';
import '../../../community/presentation/screens/community_browse_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
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
    
    // For demo, set this value based on whether the user is logged in and has communities
    if (authService.currentUser != null && 
        authService.currentUser!.communities.isNotEmpty) {
      setState(() {
        _hasJoinedCommunity = true;
        _isChecking = false;
      });
    } else {
      setState(() {
        _hasJoinedCommunity = false;
        _isChecking = false;
      });
      
      // Redirect to communities browse if not a member of any community
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.pushNamed(RouteNames.communities);
        });
      }
    }
  }

  void _onTabTapped(int index) {
    // If user hasn't joined a community, redirect to community browse
    if (!_hasJoinedCommunity && index != 3) { // Allow profile access always
      context.pushNamed(RouteNames.communities);
      return;
    }
    
    if (_currentIndex == index) {
      // If tapping the same tab, scroll to top
      if (index == 0) {
        // Scroll photos to top
        // Call a scroll controller to scroll to top
      } else if (index == 1) {
        // Scroll events to top
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
              CircularProgressIndicator(),
              SizedBox(height: 16),
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
      floatingActionButton: const FloatingUploadButton(),
    );
  }
}