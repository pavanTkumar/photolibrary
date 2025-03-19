// lib/core/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  String name;
  String? profileImageUrl;
  final DateTime createdAt;
  final bool isAdmin;
  List<String> communities;
  
  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.profileImageUrl,
    required this.createdAt,
    required this.isAdmin,
    required this.communities,
  });
  
  // Factory constructor to create a UserModel from a Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    // Handle different datetime formats
    DateTime createdAtDateTime;
    if (map['createdAt'] is Timestamp) {
      createdAtDateTime = (map['createdAt'] as Timestamp).toDate();
    } else if (map['createdAt'] is String) {
      try {
        createdAtDateTime = DateTime.parse(map['createdAt']);
      } catch (e) {
        createdAtDateTime = DateTime.now();
      }
    } else {
      createdAtDateTime = DateTime.now();
    }
    
    // Handle communities with proper type conversion
    List<String> communitiesList = [];
    if (map['communities'] != null) {
      if (map['communities'] is List) {
        communitiesList = List<String>.from(
          (map['communities'] as List).map((item) => item.toString())
        );
      }
    }
    
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      createdAt: createdAtDateTime,
      isAdmin: map['isAdmin'] ?? false,
      communities: communitiesList,
    );
  }
  
  // Convert a UserModel instance to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'isAdmin': isAdmin,
      'communities': communities,
    };
  }
  
  // Create a copy of this UserModel with the given field values updated
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? profileImageUrl,
    DateTime? createdAt,
    bool? isAdmin,
    List<String>? communities,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      isAdmin: isAdmin ?? this.isAdmin,
      communities: communities ?? List<String>.from(this.communities),
    );
  }
}