import 'package:firebase_core/firebase_core.dart';
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