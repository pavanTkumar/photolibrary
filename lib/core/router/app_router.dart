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
  final GoRouter router = GoRouter(
    initialLocation: '/',
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
      
      // Main app routes
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
        builder: (context, state) {
          final photoId = state.pathParameters['id']!;
          return PhotoDetailsScreen(photoId: photoId);
        },
      ),
      GoRoute(
        path: '/photo/upload',
        name: RouteNames.photoUpload,
        builder: (context, state) => const PhotoUploadScreen(),
      ),
      
      // Event routes
      GoRoute(
        path: '/event/:id',
        name: RouteNames.eventDetails,
        builder: (context, state) {
          final eventId = state.pathParameters['id']!;
          return EventDetailsScreen(eventId: eventId);
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
        child: Text('Route not found: ${state.uri}'),
      ),
    ),
  );
}