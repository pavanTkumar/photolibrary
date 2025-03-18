// lib/services/firestore_service.dart (improved)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../core/models/user_model.dart';
import '../core/models/photo_model.dart';
import '../core/models/event_model.dart';
import '../core/models/community_model.dart';

class FirestoreService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Collections references
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _photosCollection => _firestore.collection('photos');
  CollectionReference get _eventsCollection => _firestore.collection('events');
  CollectionReference get _communitiesCollection => _firestore.collection('communities');
  CollectionReference get _commentsCollection => _firestore.collection('comments');
  CollectionReference get _membershipRequestsCollection => _firestore.collection('membershipRequests');
  
  // User operations
  Future<UserModel?> getUser(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      DocumentSnapshot doc = await _usersCollection.doc(userId).get();
      _isLoading = false;
      notifyListeners();
      
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      _errorMessage = 'Error fetching user: $e';
      _isLoading = false;
      debugPrint(_errorMessage);
      notifyListeners();
      return null;
    }
  }
  
  // Stream for real-time user data
  Stream<UserModel?> getUserStream(String userId) {
    return _usersCollection.doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }
  
  Future<void> createUser(UserModel user) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      await _usersCollection.doc(user.id).set(user.toMap());
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error creating user: $e';
      _isLoading = false;
      debugPrint(_errorMessage);
      notifyListeners();
      rethrow;
    }
  }
  
  Future<void> updateUser(UserModel user) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      await _usersCollection.doc(user.id).update(user.toMap());
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error updating user: $e';
      _isLoading = false;
      debugPrint(_errorMessage);
      notifyListeners();
      rethrow;
    }
  }
  
  // Photo operations
  Future<List<PhotoModel>> getPhotos({
    String? communityId,
    String? userId,
    String? eventId,
    int limit = 20,
    DocumentSnapshot? lastDocument,
    String sortField = 'uploadDate',
    bool descending = true,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      Query query = _photosCollection;
      
      // Apply filters if provided
      if (communityId != null) {
        query = query.where('communityId', isEqualTo: communityId);
      }
      
      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
      }
      
      if (eventId != null) {
        query = query.where('eventId', isEqualTo: eventId);
      }
      
      // Apply sorting
      query = query.orderBy(sortField, descending: descending);
      
      // Apply pagination
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }
      
      // Apply limit
      query = query.limit(limit);
      
      // Execute query
      QuerySnapshot snapshot = await query.get();
      
      // Get current user ID for liked status
      final currentUserId = _auth.currentUser?.uid;
      
      // Convert documents to PhotoModel objects
      final photos = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final photoModel = PhotoModel.fromMap(data, doc.id);
        
        // Check if the current user has liked this photo
        if (currentUserId != null) {
          final isLiked = photoModel.likedBy.contains(currentUserId);
          return photoModel.copyWith(isLiked: isLiked);
        }
        
        return photoModel;
      }).toList();
      
      _isLoading = false;
      notifyListeners();
      
      return photos;
    } catch (e) {
      _errorMessage = 'Error fetching photos: $e';
      _isLoading = false;
      debugPrint(_errorMessage);
      notifyListeners();
      return [];
    }
  }
  
  // Stream for real-time photos
  Stream<List<PhotoModel>> getPhotosStream({
    String? communityId,
    String? userId,
    String? eventId,
    int limit = 20,
    String sortField = 'uploadDate',
    bool descending = true,
  }) {
    Query query = _photosCollection;
    
    // Apply filters if provided
    if (communityId != null) {
      query = query.where('communityId', isEqualTo: communityId);
    }
    
    if (userId != null) {
      query = query.where('userId', isEqualTo: userId);
    }
    
    if (eventId != null) {
      query = query.where('eventId', isEqualTo: eventId);
    }
    
    // Apply sorting
    query = query.orderBy(sortField, descending: descending);
    
    // Apply limit
    query = query.limit(limit);
    
    // Get current user ID for liked status
    final currentUserId = _auth.currentUser?.uid;
    
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final photoModel = PhotoModel.fromMap(data, doc.id);
        
        // Check if the current user has liked this photo
        if (currentUserId != null) {
          final isLiked = photoModel.likedBy.contains(currentUserId);
          return photoModel.copyWith(isLiked: isLiked);
        }
        
        return photoModel;
      }).toList();
    });
  }
  
  Future<PhotoModel?> getPhoto(String photoId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      DocumentSnapshot doc = await _photosCollection.doc(photoId).get();
      
      // Get current user ID for liked status
      final currentUserId = _auth.currentUser?.uid;
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final photoModel = PhotoModel.fromMap(data, doc.id);
        
        // Check if the current user has liked this photo
        if (currentUserId != null) {
          final isLiked = photoModel.likedBy.contains(currentUserId);
          _isLoading = false;
          notifyListeners();
          return photoModel.copyWith(isLiked: isLiked);
        }
        
        _isLoading = false;
        notifyListeners();
        return photoModel;
      }
      
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _errorMessage = 'Error fetching photo: $e';
      _isLoading = false;
      debugPrint(_errorMessage);
      notifyListeners();
      return null;
    }
  }
  
  // Stream for real-time photo details
  Stream<PhotoModel?> getPhotoStream(String photoId) {
    // Get current user ID for liked status
    final currentUserId = _auth.currentUser?.uid;
    
    return _photosCollection.doc(photoId).snapshots().map((doc) {
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final photoModel = PhotoModel.fromMap(data, doc.id);
        
        // Check if the current user has liked this photo
        if (currentUserId != null) {
          final isLiked = photoModel.likedBy.contains(currentUserId);
          return photoModel.copyWith(isLiked: isLiked);
        }
        
        return photoModel;
      }
      return null;
    });
  }
  
  Future<String> addPhoto(PhotoModel photo) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final photoMap = photo.toMap();
      
      // Add timestamp for sorting
      photoMap['createdAt'] = FieldValue.serverTimestamp();
      
      DocumentReference docRef = await _photosCollection.add(photoMap);
      
      _isLoading = false;
      notifyListeners();
      
      return docRef.id;
    } catch (e) {
      _errorMessage = 'Error adding photo: $e';
      _isLoading = false;
      debugPrint(_errorMessage);
      notifyListeners();
      rethrow;
    }
  }
  
  Future<void> updatePhoto(PhotoModel photo) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      await _photosCollection.doc(photo.id).update(photo.toMap());
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error updating photo: $e';
      _isLoading = false;
      debugPrint(_errorMessage);
      notifyListeners();
      rethrow;
    }
  }
  
  Future<void> deletePhoto(String photoId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // First get the photo to access its details
      final photoDoc = await _photosCollection.doc(photoId).get();
      
      if (photoDoc.exists) {
        final photoData = photoDoc.data() as Map<String, dynamic>;
        final communityId = photoData['communityId'] as String?;
        final userId = photoData['userId'] as String?;
        final eventId = photoData['eventId'] as String?;
        
        // Delete the photo document
        await _photosCollection.doc(photoId).delete();
        
        // Update counters
        if (communityId != null) {
          await updateCommunityPhotoCount(communityId, -1);
        }
        
        if (userId != null) {
          await updateUserPhotoCount(userId, -1);
        }
        
        if (eventId != null) {
          await updateEventPhotoCount(eventId, -1);
        }
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error deleting photo: $e';
      _isLoading = false;
      debugPrint(_errorMessage);
      notifyListeners();
      rethrow;
    }
  }
  
  Future<void> likePhoto(String photoId, String userId) async {
    _errorMessage = null;
    
    try {
      await _photosCollection.doc(photoId).update({
        'likedBy': FieldValue.arrayUnion([userId]),
        'likeCount': FieldValue.increment(1),
      });
    } catch (e) {
      _errorMessage = 'Error liking photo: $e';
      debugPrint(_errorMessage);
      notifyListeners();
      rethrow;
    }
  }
  
  Future<void> unlikePhoto(String photoId, String userId) async {
    _errorMessage = null;
    
    try {
      await _photosCollection.doc(photoId).update({
        'likedBy': FieldValue.arrayRemove([userId]),
        'likeCount': FieldValue.increment(-1),
      });
    } catch (e) {
      _errorMessage = 'Error unliking photo: $e';
      debugPrint(_errorMessage);
      notifyListeners();
      rethrow;
    }
  }
  
  // Comment operations
  Future<void> addComment(
    String photoId,
    String userId,
    String userName,
    String userAvatar,
    String content,
  ) async {
    _errorMessage = null;
    
    try {
      final commentData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'userId': userId,
        'userName': userName,
        'userAvatar': userAvatar,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
      };
      
      // Add to the comments array of the photo
      await _photosCollection.doc(photoId).update({
        'comments': FieldValue.arrayUnion([commentData]),
      });
    } catch (e) {
      _errorMessage = 'Error adding comment: $e';
      debugPrint(_errorMessage);
      notifyListeners();
      rethrow;
    }
  }
  
  // Update community photo count
  Future<void> updateCommunityPhotoCount(String communityId, int increment) async {
    _errorMessage = null;
    
    try {
      await _communitiesCollection.doc(communityId).update({
        'photoCount': FieldValue.increment(increment),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _errorMessage = 'Error updating community photo count: $e';
      debugPrint(_errorMessage);
      notifyListeners();
      rethrow;
    }
  }
  
  // Update user photo count
  Future<void> updateUserPhotoCount(String userId, int increment) async {
    _errorMessage = null;
    
    try {
      await _usersCollection.doc(userId).update({
        'photoCount': FieldValue.increment(increment),
        'lastActive': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _errorMessage = 'Error updating user photo count: $e';
      debugPrint(_errorMessage);
      notifyListeners();
      rethrow;
    }
  }
  
  // Update event photo count
  Future<void> updateEventPhotoCount(String eventId, int increment) async {
    _errorMessage = null;
    
    try {
      await _eventsCollection.doc(eventId).update({
        'photoCount': FieldValue.increment(increment),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _errorMessage = 'Error updating event photo count: $e';
      debugPrint(_errorMessage);
      notifyListeners();
      rethrow;
    }
  }
  
  // Event operations
  Future<List<EventModel>> getEvents({
    String? communityId,
    String? organizerId,
    bool upcomingOnly = false,
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      Query query = _eventsCollection;
      
      // Apply filters if provided
      if (communityId != null) {
        query = query.where('communityId', isEqualTo: communityId);
      }
      
      if (organizerId != null) {
        query = query.where('organizerId', isEqualTo: organizerId);
      }
      
      if (upcomingOnly) {
        query = query.where('eventDate', isGreaterThanOrEqualTo: DateTime.now());
      }
      
      // Apply sorting by date
      query = query.orderBy('eventDate');
      
      // Apply pagination
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }
      
      // Apply limit
      query = query.limit(limit);
      
      // Execute query
      QuerySnapshot snapshot = await query.get();
      
      // Get current user ID for attendance status
      final currentUserId = _auth.currentUser?.uid;
      
      // Convert documents to EventModel objects
      final events = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final eventModel = EventModel.fromMap(data, doc.id);
        
        // Check if the current user is attending this event
        if (currentUserId != null) {
          final isAttending = eventModel.attendeeIds.contains(currentUserId);
          return eventModel.copyWith(isAttending: isAttending);
        }
        
        return eventModel;
      }).toList();
      
      _isLoading = false;
      notifyListeners();
      
      return events;
    } catch (e) {
      _errorMessage = 'Error fetching events: $e';
      _isLoading = false;
      debugPrint(_errorMessage);
      notifyListeners();
      return [];
    }
  }
  
  // Stream for real-time events
  Stream<List<EventModel>> getEventsStream({
    String? communityId,
    String? organizerId,
    bool upcomingOnly = false,
    int limit = 20,
  }) {
    Query query = _eventsCollection;
    
    // Apply filters if provided
    if (communityId != null) {
      query = query.where('communityId', isEqualTo: communityId);
    }
    
    if (organizerId != null) {
      query = query.where('organizerId', isEqualTo: organizerId);
    }
    
    if (upcomingOnly) {
      query = query.where('eventDate', isGreaterThanOrEqualTo: DateTime.now());
    }
    
    // Apply sorting by date
    query = query.orderBy('eventDate');
    
    // Apply limit
    query = query.limit(limit);
    
    // Get current user ID for attendance status
    final currentUserId = _auth.currentUser?.uid;
    
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final eventModel = EventModel.fromMap(data, doc.id);
        
        // Check if the current user is attending this event
        if (currentUserId != null) {
          final isAttending = eventModel.attendeeIds.contains(currentUserId);
          return eventModel.copyWith(isAttending: isAttending);
        }
        
        return eventModel;
      }).toList();
    });
  }
  
  Future<EventModel?> getEvent(String eventId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      DocumentSnapshot doc = await _eventsCollection.doc(eventId).get();
      
      // Get current user ID for attendance status
      final currentUserId = _auth.currentUser?.uid;
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final eventModel = EventModel.fromMap(data, doc.id);
        
        // Check if the current user is attending this event
        if (currentUserId != null) {
          final isAttending = eventModel.attendeeIds.contains(currentUserId);
          _isLoading = false;
          notifyListeners();
          return eventModel.copyWith(isAttending: isAttending);
        }
        
        _isLoading = false;
        notifyListeners();
        return eventModel;
      }
      
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _errorMessage = 'Error fetching event: $e';
      _isLoading = false;
      debugPrint(_errorMessage);
      notifyListeners();
      return null;
    }
  }
  
  // Stream for real-time event details
  Stream<EventModel?> getEventStream(String eventId) {
    // Get current user ID for attendance status
    final currentUserId = _auth.currentUser?.uid;
    
    return _eventsCollection.doc(eventId).snapshots().map((doc) {
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final eventModel = EventModel.fromMap(data, doc.id);
        
        // Check if the current user is attending this event
        if (currentUserId != null) {
          final isAttending = eventModel.attendeeIds.contains(currentUserId);
          return eventModel.copyWith(isAttending: isAttending);
        }
        
        return eventModel;
      }
      return null;
    });
  }
  
  Future<String> addEvent(EventModel event) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final eventMap = event.toMap();
      
      // Add timestamp for sorting
      eventMap['createdAt'] = FieldValue.serverTimestamp();
      
      DocumentReference docRef = await _eventsCollection.add(eventMap);
      
      _isLoading = false;
      notifyListeners();
      
      return docRef.id;
    } catch (e) {
      _errorMessage = 'Error adding event: $e';
      _isLoading = false;
      debugPrint(_errorMessage);
      notifyListeners();
      rethrow;
    }
  }
  
  Future<void> updateEvent(EventModel event) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      await _eventsCollection.doc(event.id).update(event.toMap());
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error updating event: $e';
      _isLoading = false;
      debugPrint(_errorMessage);
      notifyListeners();
      rethrow;
    }
  }
  
  Future<void> deleteEvent(String eventId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      await _eventsCollection.doc(eventId).delete();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error deleting event: $e';
      _isLoading = false;
      debugPrint(_errorMessage);
      notifyListeners();
      rethrow;
    }
  }
  
  // Event attendance
  Future<void> attendEvent(String eventId, String userId) async {
    _errorMessage = null;
    
    try {
      await _eventsCollection.doc(eventId).update({
        'attendeeIds': FieldValue.arrayUnion([userId]),
        'attendeeCount': FieldValue.increment(1),
      });
    } catch (e) {
      _errorMessage = 'Error attending event: $e';
      debugPrint(_errorMessage);
      notifyListeners();
      rethrow;
    }
  }
  
  Future<void> unattendEvent(String eventId, String userId) async {
    _errorMessage = null;
    
    try {
      await _eventsCollection.doc(eventId).update({
        'attendeeIds': FieldValue.arrayRemove([userId]),
        'attendeeCount': FieldValue.increment(-1),
      });
    } catch (e) {
      _errorMessage = 'Error unattending event: $e';
      debugPrint(_errorMessage);
      notifyListeners();
      rethrow;
    }
  }
  
  /// Add to lib/services/firestore_service.dart - Community operations

  // Community operations
  Future<List<CommunityModel>> getCommunities({
    int limit = 20,
    DocumentSnapshot? lastDocument,
    String? userId,
    bool joinedOnly = false,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      Query query = _communitiesCollection;
      
      // If userId is provided and joinedOnly is true, filter for communities
      // the user is a member of
      if (userId != null && joinedOnly) {
        query = query.where('memberIds', arrayContains: userId);
      }
      
      // Apply sorting by newest first
      query = query.orderBy('createdAt', descending: true);
      
      // Apply pagination
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }
      
      // Apply limit
      query = query.limit(limit);
      
      // Execute query
      QuerySnapshot snapshot = await query.get();
      
      // Convert documents to CommunityModel objects
      List<CommunityModel> communities = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return CommunityModel.fromMap(data, doc.id);
      }).toList();
      
      _isLoading = false;
      notifyListeners();
      
      return communities;
    } catch (e) {
      _errorMessage = 'Error fetching communities: $e';
      _isLoading = false;
      debugPrint(_errorMessage);
      notifyListeners();
      return [];
    }
  }
  
  // Stream for real-time community updates
  Stream<List<CommunityModel>> getCommunitiesStream({
    int limit = 20,
    String? userId,
    bool joinedOnly = false,
  }) {
    Query query = _communitiesCollection;
    
    // Filter for communities the user is a member of
    if (userId != null && joinedOnly) {
      query = query.where('memberIds', arrayContains: userId);
    }
    
    // Apply sorting
    query = query.orderBy('createdAt', descending: true);
    
    // Apply limit
    query = query.limit(limit);
    
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return CommunityModel.fromMap(data, doc.id);
      }).toList();
    });
  }
  
  Future<CommunityModel?> getCommunity(String communityId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      DocumentSnapshot doc = await _communitiesCollection.doc(communityId).get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _isLoading = false;
        notifyListeners();
        return CommunityModel.fromMap(data, doc.id);
      }
      
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _errorMessage = 'Error fetching community: $e';
      _isLoading = false;
      debugPrint(_errorMessage);
      notifyListeners();
      return null;
    }
  }
  
  // Stream for real-time community details
  Stream<CommunityModel?> getCommunityStream(String communityId) {
    return _communitiesCollection.doc(communityId).snapshots().map((doc) {
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return CommunityModel.fromMap(data, doc.id);
      }
      return null;
    });
  }
  
  Future<String> addCommunity(CommunityModel community) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final communityMap = community.toMap();
      
      // Add timestamp for sorting
      communityMap['createdAt'] = FieldValue.serverTimestamp();
      
      DocumentReference docRef = await _communitiesCollection.add(communityMap);
      
      // Update user communities list
      if (_auth.currentUser != null) {
        await _usersCollection.doc(_auth.currentUser!.uid).update({
          'communities': FieldValue.arrayUnion([docRef.id])
        });
      }
      
      _isLoading = false;
      notifyListeners();
      
      return docRef.id;
    } catch (e) {
      _errorMessage = 'Error creating community: $e';
      _isLoading = false;
      debugPrint(_errorMessage);
      notifyListeners();
      rethrow;
    }
  }
  
  Future<void> updateCommunity(CommunityModel community) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      await _communitiesCollection.doc(community.id).update(community.toMap());
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error updating community: $e';
      _isLoading = false;
      debugPrint(_errorMessage);
      notifyListeners();
      rethrow;
    }
  }
  
  Future<void> deleteCommunity(String communityId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Get all users who are members of this community
      final community = await getCommunity(communityId);
      if (community != null) {
        // Update memberIds users to remove this community from their list
        for (String userId in community.memberIds) {
          await _usersCollection.doc(userId).update({
            'communities': FieldValue.arrayRemove([communityId])
          });
        }
      }
      
      // Delete the community document
      await _communitiesCollection.doc(communityId).delete();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error deleting community: $e';
      _isLoading = false;
      debugPrint(_errorMessage);
      notifyListeners();
      rethrow;
    }
  }
  
  Future<void> joinCommunity(String communityId, String userId) async {
    _errorMessage = null;
    
    try {
      // Update the community document to add the user
      await _communitiesCollection.doc(communityId).update({
        'memberIds': FieldValue.arrayUnion([userId])
      });
      
      // Update the user document to add the community
      await _usersCollection.doc(userId).update({
        'communities': FieldValue.arrayUnion([communityId])
      });
    } catch (e) {
      _errorMessage = 'Error joining community: $e';
      debugPrint(_errorMessage);
      notifyListeners();
      rethrow;
    }
  }
  
  Future<void> leaveCommunity(String communityId, String userId) async {
    _errorMessage = null;
    
    try {
      // Update the community document to remove the user
      await _communitiesCollection.doc(communityId).update({
        'memberIds': FieldValue.arrayRemove([userId])
      });
      
      // Remove user from moderators if they are a moderator
      await _communitiesCollection.doc(communityId).update({
        'moderatorIds': FieldValue.arrayRemove([userId])
      });
      
      // Update the user document to remove the community
      await _usersCollection.doc(userId).update({
        'communities': FieldValue.arrayRemove([communityId])
      });
    } catch (e) {
      _errorMessage = 'Error leaving community: $e';
      debugPrint(_errorMessage);
      notifyListeners();
      rethrow;
    }
  }
  
  // Membership requests
  Future<void> requestJoinCommunity(String communityId, String userId, String userName) async {
    _errorMessage = null;
    
    try {
      await _membershipRequestsCollection.add({
        'communityId': communityId,
        'userId': userId,
        'userName': userName,
        'requestDate': FieldValue.serverTimestamp(),
        'status': 'pending'
      });
    } catch (e) {
      _errorMessage = 'Error requesting to join community: $e';
      debugPrint(_errorMessage);
      notifyListeners();
      rethrow;
    }
  }
  
  Future<List<Map<String, dynamic>>> getMembershipRequests(String communityId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      QuerySnapshot snapshot = await _membershipRequestsCollection
          .where('communityId', isEqualTo: communityId)
          .where('status', isEqualTo: 'pending')
          .get();
      
      List<Map<String, dynamic>> requests = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
      
      _isLoading = false;
      notifyListeners();
      
      return requests;
    } catch (e) {
      _errorMessage = 'Error getting membership requests: $e';
      _isLoading = false;
      debugPrint(_errorMessage);
      notifyListeners();
      return [];
    }
  }
  
  Future<void> approveMembershipRequest(String requestId, String communityId, String userId) async {
    _errorMessage = null;
    
    try {
      // Update request status
      await _membershipRequestsCollection.doc(requestId).update({
        'status': 'approved'
      });
      
      // Add user to community
      await joinCommunity(communityId, userId);
    } catch (e) {
      _errorMessage = 'Error approving membership request: $e';
      debugPrint(_errorMessage);
      notifyListeners();
      rethrow;
    }
  }
  
  Future<void> rejectMembershipRequest(String requestId) async {
    _errorMessage = null;
    
    try {
      await _membershipRequestsCollection.doc(requestId).update({
        'status': 'rejected'
      });
    } catch (e) {
      _errorMessage = 'Error rejecting membership request: $e';
      debugPrint(_errorMessage);
      notifyListeners();
      rethrow;
    }
  }
  
  // Add moderator
  Future<void> addModerator(String communityId, String userId) async {
    _errorMessage = null;
    
    try {
      await _communitiesCollection.doc(communityId).update({
        'moderatorIds': FieldValue.arrayUnion([userId])
      });
    } catch (e) {
      _errorMessage = 'Error adding moderator: $e';
      debugPrint(_errorMessage);
      notifyListeners();
      rethrow;
    }
  }
  
  // Remove moderator
  Future<void> removeModerator(String communityId, String userId) async {
    _errorMessage = null;
    
    try {
      await _communitiesCollection.doc(communityId).update({
        'moderatorIds': FieldValue.arrayRemove([userId])
      });
    } catch (e) {
      _errorMessage = 'Error removing moderator: $e';
      debugPrint(_errorMessage);
      notifyListeners();
      rethrow;
    }
  }
}