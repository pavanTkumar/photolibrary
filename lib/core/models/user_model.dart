// File: lib/core/models/user_model.dart

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
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate() 
          : DateTime.parse(map['createdAt'].toString()),
      isAdmin: map['isAdmin'] ?? false,
      communities: List<String>.from(map['communities'] ?? []),
    );
  }
  
  // Convert a UserModel instance to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt,
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
      communities: communities ?? this.communities,
    );
  }
}