// File: lib/core/router/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/dashboard/presentation/screens/main_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/events/presentation/screens/event_details_screen.dart';
import '../../features/photos/presentation/screens/photo_details_screen.dart';
import '../../features/photos/presentation/screens/photo_upload_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'route_names.dart';

class AppRouter {
  // Global navigation key for the root navigator
  final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  
  late final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true, // Helps with debugging navigation
    routes: [
      // Onboarding and authentication routes
      GoRoute(
        path: '/',
        name: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: RouteNames.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      
      // Main app routes - using ShellRoute to maintain bottom navigation state
      GoRoute(
        path: '/main',
        name: RouteNames.main,
        builder: (context, state) => const MainScreen(),
      ),
      
      // Profile routes
      GoRoute(
        path: '/profile',
        name: RouteNames.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      
      // Photo routes
      GoRoute(
        path: '/photo/:id',
        name: RouteNames.photoDetails,
        pageBuilder: (context, state) {
          final photoId = state.pathParameters['id']!;
          return CustomTransitionPage(
            key: state.pageKey,
            child: PhotoDetailsScreen(photoId: photoId),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/photo/upload',
        name: RouteNames.photoUpload,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const PhotoUploadScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          );
        },
      ),
      
      // Event routes
      GoRoute(
        path: '/event/:id',
        name: RouteNames.eventDetails,
        pageBuilder: (context, state) {
          final eventId = state.pathParameters['id']!;
          return CustomTransitionPage(
            key: state.pageKey,
            child: EventDetailsScreen(eventId: eventId),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          );
        },
      ),
      
      // Admin routes
      GoRoute(
        path: '/admin',
        name: RouteNames.adminDashboard,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Page not found: ${state.uri}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/main'),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    ),
    // Redirects to handle errors
    redirect: (context, state) {
      // If we have an error, redirect to main
      if (state.error != null) {
        return '/main';
      }
      return null; // No redirect needed
    },
  );
}