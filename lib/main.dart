// lib/main.dart (production-ready)

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'core/theme/theme_provider.dart';
import 'services/auth_service.dart';
import 'services/storage_service.dart';
import 'services/firestore_service.dart';
import 'services/photo_upload_service.dart';
import 'core/firebase/firebase_init.dart';
import 'core/router/app_router.dart';
import 'app.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase
    await FirebaseInit.initializeApp();
    
    // Initialize Firebase Performance
    await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
    
    // Initialize Analytics
    FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    
    // Create auth service first to pass to router
    final authService = AuthService();
    final appRouter = AppRouter(authService);
    
    // Initialize other services
    final storageService = StorageService();
    final firestoreService = FirestoreService();
    
    // Run the app with providers
    runApp(
      MultiProvider(
        providers: [
          // Theme provider
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          
          // Services providers
          ChangeNotifierProvider.value(value: authService),
          ChangeNotifierProvider.value(value: storageService),
          ChangeNotifierProvider.value(value: firestoreService),
          
          // Photo upload service with dependencies
          ChangeNotifierProxyProvider2<StorageService, FirestoreService, PhotoUploadService>(
            create: (context) => PhotoUploadService(
              storageService: context.read<StorageService>(),
              firestoreService: context.read<FirestoreService>(),
            ),
            update: (context, storageService, firestoreService, previous) {
              return previous ?? PhotoUploadService(
                storageService: storageService,
                firestoreService: firestoreService,
              );
            },
          ),
          
          // Analytics provider
          Provider<FirebaseAnalytics>.value(value: analytics),
          
          // Provide the router
          Provider.value(value: appRouter),
        ],
        child: FishpondApp(router: appRouter.router),
      ),
    );
  } catch (e, stackTrace) {
    // Log any initialization errors to Crashlytics
    FirebaseCrashlytics.instance.recordError(e, stackTrace);
    
    // Show a simple error screen instead of crashing
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Failed to start app',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Please check your connection and try again',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Restart the app
                  main();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}