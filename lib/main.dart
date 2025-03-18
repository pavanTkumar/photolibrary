import 'package:flutter/material.dart';
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
    
    // Create auth service first to pass to router
    final authService = AuthService();
    final appRouter = AppRouter(authService);
    
    // Run the app with providers
    runApp(
      MultiProvider(
        providers: [
          // Theme provider
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          
          // Services providers
          ChangeNotifierProvider.value(value: authService),
          ChangeNotifierProvider(create: (_) => StorageService()),
          ChangeNotifierProvider(create: (_) => FirestoreService()),
          
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
          
          // Provide the router
          Provider.value(value: appRouter),
        ],
        child: FishpondApp(router: appRouter.router),
      ),
    );
  } catch (e) {
    print('Error starting app: $e');
    // Show a simple error screen instead of crashing
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'Failed to start app. Please restart.',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    ));
  }
}