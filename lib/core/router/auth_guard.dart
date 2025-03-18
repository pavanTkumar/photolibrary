import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';

class AuthGuard {
  final AuthService authService;

  AuthGuard(this.authService);

  String? canNavigate(BuildContext context, GoRouterState state) {
    // Routes that don't require authentication
    final List<String> publicRoutes = [
      '/',
      '/login',
      '/signup',
      '/onboarding',
    ];

    // Routes that require authentication
    final List<String> protectedRoutes = [
      '/profile',
      '/profile/edit',
      '/photo/upload',
      '/event/create',
      '/community/create',
      '/admin',
    ];
    
    // Check if the route requires authentication
    final requiresAuth = protectedRoutes.any((route) => 
      state.matchedLocation.startsWith(route));
      
    // Allow access to public routes regardless of authentication status
    if (publicRoutes.contains(state.matchedLocation)) {
      // If user is already logged in and tries to access auth pages, redirect to main
      if (authService.isLoggedIn && 
          (state.matchedLocation == '/login' || 
           state.matchedLocation == '/signup' || 
           state.matchedLocation == '/')) {
        return '/main';
      }
      return null; // Allow navigation to public routes
    }

    // Check if user is logged in for protected routes
    if (requiresAuth && !authService.isLoggedIn) {
      // Store the attempted route to redirect after login
      return '/login'; // Redirect to login page
    }

    // Admin routes protection
    if (state.matchedLocation.startsWith('/admin')) {
      final isAdmin = authService.currentUser?.isAdmin ?? false;
      if (!isAdmin) {
        // Not an admin, redirect to main page
        return '/main';
      }
    }

    // Allow navigation for authenticated users or public detail pages
    return null;
  }
}