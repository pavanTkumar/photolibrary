// File: lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../core/models/user_model.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Current user
  UserModel? _currentUser;
  
  // Getters
  User? get firebaseUser => _auth.currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _auth.currentUser != null;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Constructor
  AuthService() {
    // Initialize by checking for current user
    _initializeUser();
  }
  
  // Initialize auth service and load user data if already signed in
  Future<void> _initializeUser() async {
    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        await _loadUserData();
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
    
    // Also load user data on initialization if user is already signed in
    if (_auth.currentUser != null) {
      await _loadUserData();
    }
  }
  
  // Load user data from Firestore
  Future<void> _loadUserData() async {
    if (_auth.currentUser == null) return;
    
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();
      
      if (doc.exists) {
        _currentUser = UserModel.fromMap(doc.data() as Map<String, dynamic>);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }
  
  // Sign up with email and password
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
    String? profileImageUrl,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
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
      notifyListeners();
      return result;
    } catch (e) {
      debugPrint('Error signing up: $e');
      rethrow;
    }
  }
  
  // Sign in with email and password
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      await _loadUserData();
      return result;
    } catch (e) {
      debugPrint('Error signing in: $e');
      rethrow;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }
  
  // Request password reset
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      debugPrint('Error resetting password: $e');
      rethrow;
    }
  }
  
  // Update user profile
  Future<void> updateProfile({
    String? name,
    String? profileImageUrl,
  }) async {
    if (_auth.currentUser == null || _currentUser == null) return;
    
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (profileImageUrl != null) updates['profileImageUrl'] = profileImageUrl;
      
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .update(updates);
      
      // Update local user object
      if (name != null) _currentUser!.name = name;
      if (profileImageUrl != null) _currentUser!.profileImageUrl = profileImageUrl;
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating profile: $e');
      rethrow;
    }
  }
  
  // Update user community membership
  Future<void> updateCommunities(List<String> communityIds) async {
    if (_auth.currentUser == null || _currentUser == null) return;
    
    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .update({'communities': communityIds});
      
      _currentUser!.communities = communityIds;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating communities: $e');
      rethrow;
    }
  }
  
  // Request to join a community
  Future<void> requestJoinCommunity(String communityId) async {
    if (_auth.currentUser == null || _currentUser == null) return;
    
    try {
      await _firestore.collection('membershipRequests').add({
        'userId': _auth.currentUser!.uid,
        'communityId': communityId,
        'userName': _currentUser!.name,
        'requestDate': DateTime.now(),
        'status': 'pending'
      });
    } catch (e) {
      debugPrint('Error requesting community membership: $e');
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