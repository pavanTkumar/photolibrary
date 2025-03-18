// File: lib/core/router/auth_guard.dart

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

    // Check if current route is public
    if (publicRoutes.contains(state.location)) {
      return null; // Allow navigation
    }

    // Check if user is logged in
    if (!authService.isLoggedIn) {
      // Redirect to login page
      return '/login';
    }

    // Admin routes protection
    if (state.location.startsWith('/admin') && 
        (!authService.currentUser?.isAdmin ?? true)) {
      // Redirect to main page if trying to access admin routes without admin rights
      return '/main';
    }

    return null; // Allow navigation
  }
}