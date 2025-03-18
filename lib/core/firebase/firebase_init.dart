// lib/core/firebase/firebase_init.dart (improved)

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';

/// A utility class to handle Firebase initialization
class FirebaseInit {
  /// Private constructor to prevent instantiation
  FirebaseInit._();
  
  /// Flag to track initialization status
  static bool _initialized = false;
  
  /// Initialize Firebase with the default options
  static Future<void> initializeApp() async {
    if (_initialized) return;
    
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        
        // Initialize Crashlytics in non-debug mode
        if (!kDebugMode) {
          await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
          FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
        }
        
        _initialized = true;
        
        if (kDebugMode) {
          print('Firebase initialized successfully');
        }
      } else {
        _initialized = true;
        if (kDebugMode) {
          print('Firebase was already initialized');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize Firebase: $e');
      }
      rethrow;
    }
  }
}