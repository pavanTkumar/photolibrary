// lib/core/firebase/firebase_init.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';

/// A utility class to handle Firebase initialization and configuration
class FirebaseInit {
  /// Private constructor to prevent instantiation
  FirebaseInit._();
  
  /// Flag to track initialization status
  static bool _initialized = false;
  
  /// Analytics instance for app-wide usage
  static late FirebaseAnalytics analytics;
  
  /// Initialize Firebase with the default options
  static Future<void> initializeApp() async {
    if (_initialized) return;
    
    try {
      // Initialize Firebase with project-specific options
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      // Initialize Analytics
      analytics = FirebaseAnalytics.instance;
      
      // Initialize Crashlytics in non-debug mode
      if (!kDebugMode) {
        await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
        
        // Catch Flutter errors and report to Crashlytics
        FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
        
        // Catch Dart errors and report to Crashlytics
        PlatformDispatcher.instance.onError = (error, stack) {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
          return true;
        };
      } else {
        // Disable Crashlytics in debug mode to avoid polluting reports
        await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
      }
      
      // Initialize Performance Monitoring
      await FirebasePerformance.instance.setPerformanceCollectionEnabled(!kDebugMode);
      
      // Initialize Cloud Messaging (FCM)
      await _initializeMessaging();
      
      _initialized = true;
      
      if (kDebugMode) {
        print('Firebase initialized successfully');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Failed to initialize Firebase: $e');
        print(stackTrace);
      } else {
        // Try to record error to Crashlytics even if initialization failed
        try {
          FirebaseCrashlytics.instance.recordError(e, stackTrace, 
            reason: 'Error during Firebase initialization');
        } catch (_) {
          // Ignore errors from Crashlytics itself
        }
      }
      rethrow;
    }
  }
  
  /// Initialize Firebase Cloud Messaging
  static Future<void> _initializeMessaging() async {
    try {
      final messaging = FirebaseMessaging.instance;
      
      // Request permission (iOS and Web only)
      if (!kIsWeb) {
        final settings = await messaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: true,
          sound: true,
        );
        
        if (kDebugMode) {
          print('User granted permission: ${settings.authorizationStatus}');
        }
      }
      
      // Get FCM token for this device
      final token = await messaging.getToken();
      if (kDebugMode) {
        print('FCM Token: $token');
      }
      
      // Handle token refresh
      messaging.onTokenRefresh.listen((newToken) {
        if (kDebugMode) {
          print('FCM Token refreshed: $newToken');
        }
        // Here you would send the new token to your backend if needed
      });
      
      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('Got a message in the foreground!');
          print('Message data: ${message.data}');
          
          if (message.notification != null) {
            print('Message notification: ${message.notification}');
          }
        }
        
        // Here you would handle displaying foreground notifications
      });
      
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing Firebase Messaging: $e');
      }
      // Just log the error but don't throw - messaging is non-critical
    }
  }
  
  /// Log a custom analytics event
  static Future<void> logEvent(String name, [Map<String, dynamic>? parameters]) async {
    if (!_initialized) {
      if (kDebugMode) {
        print('Warning: Attempting to log event before Firebase initialization');
      }
      return;
    }
    
    try {
      await analytics.logEvent(
        name: name,
        parameters: parameters,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error logging analytics event: $e');
      }
    }
  }
  
  /// Set user ID for analytics and crashlytics
  static Future<void> setUserId(String userId) async {
    if (!_initialized) {
      if (kDebugMode) {
        print('Warning: Attempting to set user ID before Firebase initialization');
      }
      return;
    }
    
    try {
      await analytics.setUserId(id: userId);
      await FirebaseCrashlytics.instance.setUserIdentifier(userId);
    } catch (e) {
      if (kDebugMode) {
        print('Error setting user ID: $e');
      }
    }
  }
  
  /// Log custom crash information
  static void logError(dynamic exception, StackTrace? stack, {String? reason}) {
    if (!_initialized) {
      if (kDebugMode) {
        print('Warning: Attempting to log error before Firebase initialization');
      }
      return;
    }
    
    try {
      FirebaseCrashlytics.instance.recordError(
        exception,
        stack,
        reason: reason,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error logging to Crashlytics: $e');
      }
    }
  }
}