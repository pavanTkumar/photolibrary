// File: lib/core/models/community_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String adminId;
  final String adminName;
  final DateTime createdAt;
  final List<String> memberIds;
  final List<String> moderatorIds;
  final bool isPrivate;
  final Map<String, dynamic>? settings;

  CommunityModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.adminId,
    required this.adminName,
    required this.createdAt,
    required this.memberIds,
    required this.moderatorIds,
    required this.isPrivate,
    this.settings,
  });

  // Factory constructor to create a CommunityModel from Firestore data
  factory CommunityModel.fromMap(Map<String, dynamic> map, String documentId) {
    return CommunityModel(
      id: documentId,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      adminId: map['adminId'] ?? '',
      adminName: map['adminName'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      memberIds: List<String>.from(map['memberIds'] ?? []),
      moderatorIds: List<String>.from(map['moderatorIds'] ?? []),
      isPrivate: map['isPrivate'] ?? false,
      settings: map['settings'],
    );
  }

  // Convert a CommunityModel instance to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'adminId': adminId,
      'adminName': adminName,
      'createdAt': createdAt,
      'memberIds': memberIds,
      'moderatorIds': moderatorIds,
      'isPrivate': isPrivate,
      'settings': settings,
    };
  }

  // Create a copy of this CommunityModel with the given field values updated
  CommunityModel copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? adminId,
    String? adminName,
    DateTime? createdAt,
    List<String>? memberIds,
    List<String>? moderatorIds,
    bool? isPrivate,
    Map<String, dynamic>? settings,
  }) {
    return CommunityModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      adminId: adminId ?? this.adminId,
      adminName: adminName ?? this.adminName,
      createdAt: createdAt ?? this.createdAt,
      memberIds: memberIds ?? this.memberIds,
      moderatorIds: moderatorIds ?? this.moderatorIds,
      isPrivate: isPrivate ?? this.isPrivate,
      settings: settings ?? this.settings,
    );
  }

  // Check if a user is a member of this community
  bool isMember(String userId) {
    return memberIds.contains(userId);
  }

  // Check if a user is a moderator of this community
  bool isModerator(String userId) {
    return moderatorIds.contains(userId) || adminId == userId;
  }

  // Check if a user is the admin of this community
  bool isAdmin(String userId) {
    return adminId == userId;
  }

  // Create a sample community for testing
  static CommunityModel sample({int index = 0}) {
    return CommunityModel(
      id: 'community_$index',
      name: 'Sample Community ${index + 1}',
      description: 'This is a sample community for demonstration purposes.',
      imageUrl: 'https://picsum.photos/seed/community$index/800/450',
      adminId: 'admin_$index',
      adminName: 'Admin User ${index + 1}',
      createdAt: DateTime.now().subtract(Duration(days: index * 30)),
      memberIds: List.generate(10 + index, (i) => 'member_$i'),
      moderatorIds: List.generate(2, (i) => 'mod_${index}_$i'),
      isPrivate: index % 2 == 0,
      settings: {
        'allowComments': true,
        'allowSharing': true,
        'approvePhotos': index % 2 == 0,
      },
    );
  }

  // Generate a list of sample communities for testing
  static List<CommunityModel> sampleList(int count) {
    return List.generate(count, (index) => sample(index: index));
  }
}