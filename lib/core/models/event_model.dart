// File: lib/core/models/event_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'photo_model.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final DateTime eventDate;
  final String location;
  final String organizerName;
  final String organizerId;
  final int attendeeCount;
  final List<String> attendeeIds;
  final bool isAttending;
  final List<String> tags;
  final List<PhotoModel>? photos;
  final List<CommentModel>? comments;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.eventDate,
    required this.location,
    required this.organizerName,
    required this.organizerId,
    required this.attendeeCount,
    required this.attendeeIds,
    required this.isAttending,
    required this.tags,
    this.photos,
    this.comments,
  });

  // Create a copy of the event with updated values
  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    DateTime? eventDate,
    String? location,
    String? organizerName,
    String? organizerId,
    int? attendeeCount,
    List<String>? attendeeIds,
    bool? isAttending,
    List<String>? tags,
    List<PhotoModel>? photos,
    List<CommentModel>? comments,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      eventDate: eventDate ?? this.eventDate,
      location: location ?? this.location,
      organizerName: organizerName ?? this.organizerName,
      organizerId: organizerId ?? this.organizerId,
      attendeeCount: attendeeCount ?? this.attendeeCount,
      attendeeIds: attendeeIds ?? this.attendeeIds,
      isAttending: isAttending ?? this.isAttending,
      tags: tags ?? this.tags,
      photos: photos ?? this.photos,
      comments: comments ?? this.comments,
    );
  }

  // Toggle the attending status
  EventModel toggleAttending() {
    final String currentUserId = 'current_user_id'; // Placeholder for current user ID
    
    List<String> updatedAttendeeIds = List<String>.from(attendeeIds);
    if (isAttending) {
      updatedAttendeeIds.remove(currentUserId);
    } else {
      updatedAttendeeIds.add(currentUserId);
    }
    
    return copyWith(
      isAttending: !isAttending,
      attendeeCount: isAttending ? attendeeCount - 1 : attendeeCount + 1,
      attendeeIds: updatedAttendeeIds,
    );
  }

  // Create from Firestore data
  factory EventModel.fromMap(Map<String, dynamic> map, String documentId) {
    // Parse attendees
    List<String> attendeeIdsList = [];
    if (map['attendeeIds'] != null) {
      attendeeIdsList = List<String>.from(map['attendeeIds']);
    }
    
    // Check if current user is attending
    const String currentUserId = 'current_user_id'; // Placeholder for current user ID
    final bool isAttendingEvent = attendeeIdsList.contains(currentUserId);
    
    return EventModel(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      eventDate: (map['eventDate'] as Timestamp).toDate(),
      location: map['location'] ?? '',
      organizerName: map['organizerName'] ?? '',
      organizerId: map['organizerId'] ?? '',
      attendeeCount: map['attendeeCount'] ?? 0,
      attendeeIds: attendeeIdsList,
      isAttending: isAttendingEvent,
      tags: List<String>.from(map['tags'] ?? []),
      photos: null, // We'll load photos separately if needed
      comments: null, // We'll load comments separately if needed
    );
  }

  // Convert to Firestore data
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'eventDate': eventDate,
      'location': location,
      'organizerName': organizerName,
      'organizerId': organizerId,
      'attendeeCount': attendeeCount,
      'attendeeIds': attendeeIds,
      'tags': tags,
    };
  }

  // Create a sample event for testing
  static EventModel sample({int index = 0}) {
    // Generate a future date
    final DateTime eventDate = DateTime.now().add(Duration(days: index * 3 + 1));
    
    return EventModel(
      id: 'event_$index',
      title: 'Community Event ${index + 1}',
      description: 'This is a detailed description for the community event number ${index + 1}. Join us for a day of learning, sharing, and community building.',
      imageUrl: 'https://picsum.photos/seed/event$index/800/450',
      eventDate: eventDate,
      location: 'Community Center, Building ${index + 1}, Main Street',
      organizerName: 'Community Leader ${index + 1}',
      organizerId: 'organizer_$index',
      attendeeCount: 20 + (index * 5),
      attendeeIds: List.generate(20 + (index * 5), (i) => 'user_$i'),
      isAttending: index % 3 == 0,
      tags: ['community', 'event', 'tag$index'],
      photos: index % 2 == 0 ? PhotoModel.sampleList(3 + index) : null,
      comments: index % 2 == 0 ? CommentModel.sampleList(5 + index) : null,
    );
  }

  // Generate a list of sample events for testing
  static List<EventModel> sampleList(int count) {
    return List.generate(count, (index) => sample(index: index));
  }
}