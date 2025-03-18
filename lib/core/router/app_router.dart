// lib/core/router/app_router.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/dashboard/presentation/screens/main_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/profile_edit_screen.dart';
import '../../features/events/presentation/screens/event_details_screen.dart';
import '../../features/events/presentation/screens/event_creation_screen.dart';
import '../../features/photos/presentation/screens/photo_details_screen.dart';
import '../../features/photos/presentation/screens/photo_upload_screen.dart';
import '../../features/community/presentation/screens/community_creation_screen.dart';
import '../../features/community/presentation/screens/community_details_screen.dart';
import '../../features/community/presentation/screens/community_browse_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../services/auth_service.dart';
import 'auth_guard.dart';
import 'route_names.dart';

// Helper class to allow the GoRouter to listen to Firebase Auth changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRouter {
  // Global navigation key for the root navigator
  final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  late final AuthGuard _authGuard;
  final AuthService _authService;
  
  AppRouter(this._authService) {
    _authGuard = AuthGuard(_authService);
  }
  
  late final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true, // Helps with debugging navigation
    redirect: (context, state) {
      // Use the auth guard to check if navigation is allowed
      return _authGuard.canNavigate(context, state);
    },
    refreshListenable: GoRouterRefreshStream(_authService.authStateChanges),
    routes: [
      // Onboarding and authentication routes
      GoRoute(
        path: '/',
        name: RouteNames.onboarding,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/login',
        name: RouteNames.login,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/signup',
        name: RouteNames.signup,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SignupScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
              child: child,
            );
          },
        ),
      ),
      
      // Main app routes
      GoRoute(
        path: '/main',
        name: RouteNames.main,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const MainScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
              child: child,
            );
          },
        ),
      ),
      
      // Community routes
      GoRoute(
        path: '/communities',
        name: RouteNames.communities,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const CommunityBrowseScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/community/create',
        name: RouteNames.communityCreate,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const CommunityCreationScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/community/:id',
        name: RouteNames.communityDetails,
        pageBuilder: (context, state) {
          final communityId = state.pathParameters['id']!;
          return CustomTransitionPage(
            key: state.pageKey,
            child: CommunityDetailsScreen(communityId: communityId),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
                child: child,
              );
            },
          );
        },
      ),
      
      // Profile routes
      GoRoute(
        path: '/profile',
        name: RouteNames.profile,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ProfileScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/profile/edit',
        name: RouteNames.profileEdit,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ProfileEditScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
              child: child,
            );
          },
        ),
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
                opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/photo/upload',
        name: RouteNames.photoUpload,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const PhotoUploadScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
              child: child,
            );
          },
        ),
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
                opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/event/create',
        name: RouteNames.eventCreate,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const EventCreationScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
              child: child,
            );
          },
        ),
      ),
      
      // Admin routes
      GoRoute(
        path: '/admin',
        name: RouteNames.adminDashboard,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AdminDashboardScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
              child: child,
            );
          },
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline, 
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found: ${state.uri}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/main'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}