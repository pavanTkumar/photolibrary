import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/buttons/animated_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Share Your Moments',
      description: 'Capture and share beautiful photos with your community. Showcase your perspective and get inspired by others.',
      icon: Icons.photo_camera,
      color: const Color(0xFF6750A4),
    ),
    OnboardingPage(
      title: 'Discover Community Events',
      description: 'Stay updated with local events, workshops, and gatherings. Attend, participate, and connect with your community.',
      icon: Icons.event,
      color: const Color(0xFF625B71),
    ),
    OnboardingPage(
      title: 'Connect with Others',
      description: 'Build meaningful connections with like-minded individuals. Comment, like, and engage with the community.',
      icon: Icons.people,
      color: const Color(0xFF7E5260),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      context.goNamed(RouteNames.login);
    }
  }

  void _goToLoginPage() {
    context.goNamed(RouteNames.login);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background based on current page
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _pages[_currentPage].color,
                  _pages[_currentPage].color.withOpacity(0.7),
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      final page = _pages[index];
                      
                      return Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Icon
                            Icon(
                              page.icon,
                              size: 120,
                              color: Colors.white,
                            ).animate(
                              key: ValueKey('icon-$index'),
                            ).scale(
                              duration: 600.ms,
                              curve: Curves.easeOut,
                            ),
                            
                            const SizedBox(height: 48),
                            
                            // Title
                            Text(
                              page.title,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ).animate(
                              key: ValueKey('title-$index'),
                            ).fadeIn(duration: 500.ms, delay: 200.ms)
                             .slideY(
                               begin: 0.3,
                               end: 0.0,
                               duration: 500.ms,
                               delay: 200.ms,
                               curve: Curves.easeOut,
                             ),
                            
                            const SizedBox(height: 24),
                            
                            // Description
                            Text(
                              page.description,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ).animate(
                              key: ValueKey('desc-$index'),
                            ).fadeIn(duration: 500.ms, delay: 400.ms)
                             .slideY(
                               begin: 0.3,
                               end: 0.0,
                               duration: 500.ms,
                               delay: 400.ms,
                               curve: Curves.easeOut,
                             ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                
                // Page indicators
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Colors.white
                              : Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                ),
                
                // Button row
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 32.0,
                    left: 24.0,
                    right: 24.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Skip button
                      TextButton(
                        onPressed: _goToLoginPage,
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      
                      // Next button - Fixed contrast issue with custom button
                      ElevatedButton(
                        onPressed: _goToNextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: _pages[_currentPage].color,
                          elevation: 3,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _currentPage == _pages.length - 1
                                  ? Icons.check
                                  : Icons.arrow_forward,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _currentPage == _pages.length - 1
                                  ? 'Get Started'
                                  : 'Next',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
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
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}