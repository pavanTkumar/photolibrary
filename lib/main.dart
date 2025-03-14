import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'core/theme/theme_provider.dart';
import 'services/auth_service.dart';
import 'services/storage_service.dart';
import 'services/firestore_service.dart';
import 'services/photo_upload_service.dart';
import 'core/firebase/firebase_init.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await FirebaseInit.initializeApp();
  
  // Run the app with providers
  runApp(
    MultiProvider(
      providers: [
        // Theme provider
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        
        // Services providers
        ChangeNotifierProvider(create: (_) => AuthService()),
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
      ],
      child: const FishpondApp(),
    ),
  );
}