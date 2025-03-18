import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
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
  
  // Run the app with error handling
  runZonedApp();
}

Future<void> runZonedApp() async {
  // Error widget to show when Flutter fails to build a widget
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Colors.red.withOpacity(0.1),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 40,
              ),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  details.exception.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  };
  
  try {
    // Initialize Firebase
    await FirebaseInit.initializeApp();
    
    // Create services
    final authService = AuthService();
    final storageService = StorageService();
    final firestoreService = FirestoreService();
    
    // Create router with auth service
    final appRouter = AppRouter(authService);
    
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
              storageService: storageService,
              firestoreService: firestoreService,
            ),
            update: (context, storageService, firestoreService, previous) {
              return previous ?? PhotoUploadService(
                storageService: storageService,
                firestoreService: firestoreService,
              );
            },
          ),
          
          // Provide the router
          Provider.value(value: appRouter),
        ],
        child: FishpondApp(router: appRouter.router),
      ),
    );
  } catch (e, stackTrace) {
    // Log initialization errors to Crashlytics if possible
    try {
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
    } catch (_) {
      // Ignore errors from Crashlytics itself
    }
    
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Please check your connection and try again\n\n$e',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Restart the app
                  runZonedApp();
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

// Custom error handling function to avoid printing errors in production
void logError(dynamic error, StackTrace stack) {
  // In debug mode, print the error
  if (const bool.fromEnvironment('dart.vm.product') == false) {
    debugPrint('Error: $error');
    debugPrint('Stack trace: $stack');
  }
  
  // Log to Crashlytics if initialized
  try {
    FirebaseCrashlytics.instance.recordError(error, stack);
  } catch (_) {
    // Ignore if Crashlytics isn't initialized
  }
}