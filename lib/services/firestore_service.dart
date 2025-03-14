// File: lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../core/models/user_model.dart';
import '../core/models/photo_model.dart';
import '../core/models/event_model.dart';
import '../core/models/community_model.dart';

class FirestoreService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collections references
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _photosCollection => _firestore.collection('photos');
  CollectionReference get _eventsCollection => _firestore.collection('events');
  CollectionReference get _communitiesCollection => _firestore.collection('communities');
  CollectionReference get _commentsCollection => _firestore.collection('comments');
  CollectionReference get _membershipRequestsCollection => _firestore.collection('membershipRequests');
  
  // User operations
  Future<UserModel?> getUser(String userId) async {
    try {
      DocumentSnapshot doc = await _usersCollection.doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }
  
  Future<void> createUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.id).set(user.toMap());
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
  }
  
  Future<void> updateUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.id).update(user.toMap());
    } catch (e) {
      print('Error updating user: $e');
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
    String sortField = 'createdAt',
    bool descending = true,
  }) async {
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
      
      // Convert documents to PhotoModel objects
      return snapshot.docs.map((doc) {
        return PhotoModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    } catch (e) {
      print('Error fetching photos: $e');
      return [];
    }
  }
  
  Future<PhotoModel?> getPhoto(String photoId) async {
    try {
      DocumentSnapshot doc = await _photosCollection.doc(photoId).get();
      if (doc.exists) {
        return PhotoModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }
      return null;
    } catch (e) {
      print('Error fetching photo: $e');
      return null;
    }
  }
  
  Future<String> addPhoto(PhotoModel photo) async {
    try {
      DocumentReference docRef = await _photosCollection.add(photo.toMap());
      return docRef.id;
    } catch (e) {
      print('Error adding photo: $e');
      rethrow;
    }
  }
  
  Future<void> updatePhoto(PhotoModel photo) async {
    try {
      await _photosCollection.doc(photo.id).update(photo.toMap());
    } catch (e) {
      print('Error updating photo: $e');
      rethrow;
    }
  }
  
  Future<void> deletePhoto(String photoId) async {
    try {
      await _photosCollection.doc(photoId).delete();
    } catch (e) {
      print('Error deleting photo: $e');
      rethrow;
    }
  }
  
  Future<void> likePhoto(String photoId, String userId) async {
    try {
      await _photosCollection.doc(photoId).update({
        'likedBy': FieldValue.arrayUnion([userId]),
        'likes': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error liking photo: $e');
      rethrow;
    }
  }
  
  Future<void> unlikePhoto(String photoId, String userId) async {
    try {
      await _photosCollection.doc(photoId).update({
        'likedBy': FieldValue.arrayRemove([userId]),
        'likes': FieldValue.increment(-1),
      });
    } catch (e) {
      print('Error unliking photo: $e');
      rethrow;
    }
  }
  
  // Comment operations
  Future<void> addComment(
    String photoId,
    String userId,
    String userName,
    String content,
  ) async {
    try {
      final commentData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'userId': userId,
        'userName': userName,
        'text': content,
        'createdAt': FieldValue.serverTimestamp(),
      };
      
      await _photosCollection.doc(photoId).update({
        'comments': FieldValue.arrayUnion([commentData]),
      });
    } catch (e) {
      print('Error adding comment: $e');
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
      
      // Convert documents to EventModel objects
      return snapshot.docs.map((doc) {
        return EventModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    } catch (e) {
      print('Error fetching events: $e');
      return [];
    }
  }
  
  Future<EventModel?> getEvent(String eventId) async {
    try {
      DocumentSnapshot doc = await _eventsCollection.doc(eventId).get();
      if (doc.exists) {
        return EventModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }
      return null;
    } catch (e) {
      print('Error fetching event: $e');
      return null;
    }
  }
  
  Future<String> addEvent(EventModel event) async {
    try {
      DocumentReference docRef = await _eventsCollection.add(event.toMap());
      return docRef.id;
    } catch (e) {
      print('Error adding event: $e');
      rethrow;
    }
  }
  
  Future<void> updateEvent(EventModel event) async {
    try {
      await _eventsCollection.doc(event.id).update(event.toMap());
    } catch (e) {
      print('Error updating event: $e');
      rethrow;
    }
  }
  
  Future<void> deleteEvent(String eventId) async {
    try {
      await _eventsCollection.doc(eventId).delete();
    } catch (e) {
      print('Error deleting event: $e');
      rethrow;
    }
  }
  
  // Event attendance
  Future<void> attendEvent(String eventId, String userId) async {
    try {
      await _eventsCollection.doc(eventId).update({
        'attendeeIds': FieldValue.arrayUnion([userId]),
        'attendeeCount': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error attending event: $e');
      rethrow;
    }
  }
  
  Future<void> unattendEvent(String eventId, String userId) async {
    try {
      await _eventsCollection.doc(eventId).update({
        'attendeeIds': FieldValue.arrayRemove([userId]),
        'attendeeCount': FieldValue.increment(-1),
      });
    } catch (e) {
      print('Error unattending event: $e');
      rethrow;
    }
  }
  
  // Community operations
  Future<List<CommunityModel>> getCommunities({
    String? userId,
    bool memberOnly = false,
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _communitiesCollection;
      
      // If memberOnly is true, we need to filter for communities where the user is a member
      if (memberOnly && userId != null) {
        query = query.where('memberIds', arrayContains: userId);
      }
      
      // Apply sorting
      query = query.orderBy('name');
      
      // Apply pagination
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }
      
      // Apply limit
      query = query.limit(limit);
      
      // Execute query
      QuerySnapshot snapshot = await query.get();
      
      // Convert documents to CommunityModel objects
      return snapshot.docs.map((doc) {
        return CommunityModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    } catch (e) {
      print('Error fetching communities: $e');
      return [];
    }
  }
  
  Future<CommunityModel?> getCommunity(String communityId) async {
    try {
      DocumentSnapshot doc = await _communitiesCollection.doc(communityId).get();
      if (doc.exists) {
        return CommunityModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }
      return null;
    } catch (e) {
      print('Error fetching community: $e');
      return null;
    }
  }
  
  Future<String> createCommunity(CommunityModel community) async {
    try {
      DocumentReference docRef = await _communitiesCollection.add(community.toMap());
      return docRef.id;
    } catch (e) {
      print('Error creating community: $e');
      rethrow;
    }
  }
  
  Future<void> updateCommunity(CommunityModel community) async {
    try {
      await _communitiesCollection.doc(community.id).update(community.toMap());
    } catch (e) {
      print('Error updating community: $e');
      rethrow;
    }
  }
  
  Future<void> deleteCommunity(String communityId) async {
    try {
      await _communitiesCollection.doc(communityId).delete();
    } catch (e) {
      print('Error deleting community: $e');
      rethrow;
    }
  }
  
  // Membership request operations
  Future<String> createMembershipRequest(
    String userId,
    String userName,
    String communityId,
  ) async {
    try {
      final requestData = {
        'userId': userId,
        'userName': userName,
        'communityId': communityId,
        'status': 'pending',
        'requestDate': FieldValue.serverTimestamp(),
      };
      
      DocumentReference docRef = await _membershipRequestsCollection.add(requestData);
      return docRef.id;
    } catch (e) {
      print('Error creating membership request: $e');
      rethrow;
    }
  }
  
  Future<void> updateMembershipRequestStatus(
    String requestId,
    String status,
  ) async {
    try {
      await _membershipRequestsCollection.doc(requestId).update({
        'status': status,
        'responseDate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating membership request: $e');
      rethrow;
    }
  }
  
  // Handle accepting a member into a community
  Future<void> addMemberToCommunity(
    String communityId,
    String userId,
  ) async {
    try {
      await _communitiesCollection.doc(communityId).update({
        'memberIds': FieldValue.arrayUnion([userId]),
      });
      
      // Also update the user's communities list
      await _usersCollection.doc(userId).update({
        'communities': FieldValue.arrayUnion([communityId]),
      });
    } catch (e) {
      print('Error adding member to community: $e');
      rethrow;
    }
  }
  
  // Handle removing a member from a community
  Future<void> removeMemberFromCommunity(
    String communityId,
    String userId,
  ) async {
    try {
      await _communitiesCollection.doc(communityId).update({
        'memberIds': FieldValue.arrayRemove([userId]),
        // Also remove from moderators list if they were a moderator
        'moderatorIds': FieldValue.arrayRemove([userId]),
      });
      
      // Also update the user's communities list
      await _usersCollection.doc(userId).update({
        'communities': FieldValue.arrayRemove([communityId]),
      });
    } catch (e) {
      print('Error removing member from community: $e');
      rethrow;
    }
  }
}