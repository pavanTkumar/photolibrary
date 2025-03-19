// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../core/models/user_model.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Current user
  UserModel? _currentUser;
  
  // Loading state
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  User? get firebaseUser => _auth.currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _auth.currentUser != null;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Constructor
  AuthService() {
    // Initialize by checking for current user
    _initializeUser();
  }
  
  // Initialize auth service and load user data if already signed in
  Future<void> _initializeUser() async {
    _isLoading = true;
    notifyListeners();
    
    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        await _loadUserData();
      } else {
        _currentUser = null;
        _isLoading = false;
        notifyListeners();
      }
    });
    
    // Also load user data on initialization if user is already signed in
    if (_auth.currentUser != null) {
      await _loadUserData();
    } else {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Load user data from Firestore
  Future<void> _loadUserData() async {
    if (_auth.currentUser == null) return;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();
      
      if (doc.exists) {
        // Convert Firebase data to our UserModel
        final data = doc.data() as Map<String, dynamic>;
        
        // Extract communities as a list of strings
        List<String> communities = [];
        if (data['communities'] != null) {
          if (data['communities'] is List) {
            communities = List<String>.from(data['communities']);
          } else {
            debugPrint('Warning: communities field exists but is not a List');
          }
        }
        
        // Make sure all necessary fields exist and create a proper user model
        final userData = {
          'id': _auth.currentUser!.uid,
          'email': data['email'] ?? _auth.currentUser!.email ?? '',
          'name': data['name'] ?? _auth.currentUser!.displayName ?? 'User',
          'profileImageUrl': data['profileImageUrl'] ?? _auth.currentUser!.photoURL,
          'createdAt': data['createdAt'] ?? DateTime.now().toIso8601String(),
          'isAdmin': data['isAdmin'] ?? false,
          'communities': communities,
        };
        
        _currentUser = UserModel.fromMap(userData);
        _isLoading = false;
        notifyListeners();
      } else {
        // Create a basic user if document doesn't exist
        final user = UserModel(
          id: _auth.currentUser!.uid,
          email: _auth.currentUser!.email ?? '',
          name: _auth.currentUser!.displayName ?? 'User',
          profileImageUrl: _auth.currentUser!.photoURL,
          createdAt: DateTime.now(),
          isAdmin: false,
          communities: [],
        );
        
        await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .set(user.toMap());
        
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error loading user data: $e';
      _isLoading = false;
      debugPrint(_errorMessage);
      notifyListeners();
    }
  }
  
  // Sign up with email and password
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
    String? profileImageUrl,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update the display name in Firebase Auth
      await result.user!.updateDisplayName(name);
      if (profileImageUrl != null) {
        await result.user!.updatePhotoURL(profileImageUrl);
      }
      
      // Create user profile in Firestore
      final user = UserModel(
        id: result.user!.uid,
        email: email,
        name: name,
        profileImageUrl: profileImageUrl,
        createdAt: DateTime.now(),
        isAdmin: false,
        communities: [],
      );
      
      await _firestore
          .collection('users')
          .doc(result.user!.uid)
          .set(user.toMap());
      
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _errorMessage = 'Error signing up: $e';
      _isLoading = false;
      debugPrint(_errorMessage);
      notifyListeners();
      rethrow;
    }
  }
  
  // Sign in with email and password
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      await _loadUserData();
      return result;
    } catch (e) {
      _errorMessage = 'Error signing in: $e';
      _isLoading = false;
      debugPrint(_errorMessage);
      notifyListeners();
      rethrow;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      await _auth.signOut();
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error signing out: $e';
      _isLoading = false;
      debugPrint(_errorMessage);
      notifyListeners();
      rethrow;
    }
  }
  
  // Request password reset
  Future<void> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Send password reset email through Firebase Auth
      await _auth.sendPasswordResetEmail(email: email);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error resetting password: $e';
      _isLoading = false;
      debugPrint(_errorMessage);
      notifyListeners();
      rethrow;
    }
  }
  
  // Update user profile
  Future<void> updateProfile({
    String? name,
    String? profileImageUrl,
  }) async {
    if (_auth.currentUser == null || _currentUser == null) return;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (profileImageUrl != null) updates['profileImageUrl'] = profileImageUrl;
      
      // Update the display name in Firebase Auth
      if (name != null) {
        await _auth.currentUser!.updateDisplayName(name);
      }
      
      // Update profile photo in Firebase Auth
      if (profileImageUrl != null) {
        await _auth.currentUser!.updatePhotoURL(profileImageUrl);
      }
      
      // Update in Firestore
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .update(updates);
      
      // Update local user object
      if (name != null) _currentUser!.name = name;
      if (profileImageUrl != null) _currentUser!.profileImageUrl = profileImageUrl;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error updating profile: $e';
      _isLoading = false;
      debugPrint(_errorMessage);
      notifyListeners();
      rethrow;
    }
  }
  
  // Update user community membership
  Future<void> updateCommunities(List<String> communityIds) async {
    if (_auth.currentUser == null || _currentUser == null) return;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .update({'communities': communityIds});
      
      _currentUser!.communities = List<String>.from(communityIds);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error updating communities: $e';
      _isLoading = false;
      debugPrint(_errorMessage);
      notifyListeners();
      rethrow;
    }
  }
  
  // Request to join a community
  Future<void> requestJoinCommunity(String communityId) async {
    if (_auth.currentUser == null || _currentUser == null) return;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      await _firestore.collection('membershipRequests').add({
        'userId': _auth.currentUser!.uid,
        'communityId': communityId,
        'userName': _currentUser!.name,
        'requestDate': FieldValue.serverTimestamp(),
        'status': 'pending'
      });
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error requesting community membership: $e';
      _isLoading = false;
      debugPrint(_errorMessage);
      notifyListeners();
      rethrow;
    }
  }

  // Check if a user is a member of a community
  Future<bool> isUserInCommunity(String communityId) async {
    if (_auth.currentUser == null || _currentUser == null) return false;
    
    // Check if the community ID is in the user's communities list
    return _currentUser!.communities.contains(communityId);
  }
}