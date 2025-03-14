// File: lib/core/models/photo_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String content;
  final DateTime timestamp;

  const CommentModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.content,
    required this.timestamp,
  });

  // Create a CommentModel from a Map
  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userAvatar: map['userAvatar'] ?? 'https://picsum.photos/seed/avatar/100/100',
      content: map['content'] ?? map['text'] ?? '',
      timestamp: map['timestamp'] is Timestamp 
          ? (map['timestamp'] as Timestamp).toDate()
          : (map['createdAt'] is Timestamp
              ? (map['createdAt'] as Timestamp).toDate()
              : DateTime.now()),
    );
  }

  // Convert a CommentModel to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'content': content,
      'timestamp': timestamp,
    };
  }

  // Create a sample comment for testing
  static CommentModel sample({int index = 0}) {
    return CommentModel(
      id: 'comment_$index',
      userId: 'user_$index',
      userName: 'User $index',
      userAvatar: 'https://picsum.photos/seed/avatar$index/100/100',
      content: 'This is a sample comment $index',
      timestamp: DateTime.now().subtract(Duration(hours: index)),
    );
  }

  // Generate a list of sample comments for testing
  static List<CommentModel> sampleList(int count) {
    return List.generate(count, (index) => sample(index: index));
  }
}

class PhotoModel {
  final String id;
  final String imageUrl;
  final String thumbnailUrl;
  final String title;
  final String description;
  final String userId;        // Owner ID
  final String userName;      // Owner name
  final String uploaderId;    // Same as userId in most cases, but kept for compatibility
  final String uploaderName;  // Same as userName in most cases, but kept for compatibility
  final String communityId;
  final String? eventId;
  final DateTime uploadDate;
  final int likeCount;
  final bool isLiked;
  final List<String> tags;
  final List<String> likedBy;
  final List<CommentModel>? comments;
  final Map<String, dynamic>? metadata;

  const PhotoModel({
    required this.id,
    required this.imageUrl,
    required this.thumbnailUrl,
    required this.title,
    required this.description,
    required this.userId,
    required this.userName,
    String? uploaderId,       // Optional parameter with default
    String? uploaderName,     // Optional parameter with default
    required this.communityId,
    this.eventId,
    required this.uploadDate,
    required this.likeCount,
    required this.isLiked,
    required this.tags,
    required this.likedBy,
    this.comments,
    this.metadata,
  }) : 
    this.uploaderId = uploaderId ?? userId,     // Default to userId if not provided
    this.uploaderName = uploaderName ?? userName; // Default to userName if not provided

  // Create a PhotoModel from a Map and document ID
  factory PhotoModel.fromMap(Map<String, dynamic> map, String documentId) {
    // Parse comments if they exist
    List<CommentModel>? commentsList;
    if (map['comments'] != null) {
      commentsList = (map['comments'] as List)
          .map((commentMap) => CommentModel.fromMap(commentMap as Map<String, dynamic>))
          .toList();
    }

    return PhotoModel(
      id: documentId,
      imageUrl: map['imageUrl'] ?? '',
      thumbnailUrl: map['thumbnailUrl'] ?? map['imageUrl'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      uploaderId: map['uploaderId'] ?? map['userId'] ?? '',
      uploaderName: map['uploaderName'] ?? map['userName'] ?? '',
      communityId: map['communityId'] ?? '',
      eventId: map['eventId'],
      uploadDate: map['uploadDate'] is Timestamp 
          ? (map['uploadDate'] as Timestamp).toDate() 
          : (map['createdAt'] is Timestamp 
              ? (map['createdAt'] as Timestamp).toDate() 
              : DateTime.now()),
      likeCount: map['likeCount'] ?? map['likes'] ?? 0,
      isLiked: map['isLiked'] ?? false,
      tags: List<String>.from(map['tags'] ?? []),
      likedBy: List<String>.from(map['likedBy'] ?? []),
      comments: commentsList,
      metadata: map['metadata'],
    );
  }

  // Convert a PhotoModel to a Map
  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'thumbnailUrl': thumbnailUrl,
      'title': title,
      'description': description,
      'userId': userId,
      'userName': userName,
      'uploaderId': uploaderId,
      'uploaderName': uploaderName,
      'communityId': communityId,
      'eventId': eventId,
      'uploadDate': uploadDate,
      'likeCount': likeCount,
      'isLiked': isLiked,
      'tags': tags,
      'likedBy': likedBy,
      'comments': comments?.map((comment) => comment.toMap()).toList(),
      'metadata': metadata,
    };
  }

  // Create a copy of this PhotoModel with updated values
  PhotoModel copyWith({
    String? id,
    String? imageUrl,
    String? thumbnailUrl,
    String? title,
    String? description,
    String? userId,
    String? userName,
    String? uploaderId,
    String? uploaderName,
    String? communityId,
    String? eventId,
    DateTime? uploadDate,
    int? likeCount,
    bool? isLiked,
    List<String>? tags,
    List<String>? likedBy,
    List<CommentModel>? comments,
    Map<String, dynamic>? metadata,
  }) {
    return PhotoModel(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      title: title ?? this.title,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      uploaderId: uploaderId ?? this.uploaderId,
      uploaderName: uploaderName ?? this.uploaderName,
      communityId: communityId ?? this.communityId,
      eventId: eventId ?? this.eventId,
      uploadDate: uploadDate ?? this.uploadDate,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      tags: tags ?? this.tags,
      likedBy: likedBy ?? this.likedBy,
      comments: comments ?? this.comments,
      metadata: metadata ?? this.metadata,
    );
  }

  // Toggle the like status
  PhotoModel toggleLike() {
    return copyWith(
      isLiked: !isLiked,
      likeCount: isLiked ? likeCount - 1 : likeCount + 1,
    );
  }

  // Create a sample photo for testing
  static PhotoModel sample({int index = 0}) {
    return PhotoModel(
      id: 'photo_$index',
      imageUrl: 'https://picsum.photos/seed/$index/500/500',
      thumbnailUrl: 'https://picsum.photos/seed/$index/200/200',
      title: 'Sample Photo $index',
      description: 'This is a sample photo description for photo $index',
      userId: 'user_$index',
      userName: 'User $index',
      uploaderId: 'user_$index',
      uploaderName: 'User $index',
      communityId: 'community_${index % 3}',
      eventId: index % 3 == 0 ? 'event_${index % 5}' : null,
      uploadDate: DateTime.now().subtract(Duration(days: index)),
      likeCount: index * 10,
      isLiked: index % 2 == 0,
      tags: ['sample', 'photo', 'tag$index'],
      likedBy: List.generate(index * 10, (i) => 'user_$i'),
      comments: index % 2 == 0 ? CommentModel.sampleList(3) : null,
      metadata: {
        'width': 500,
        'height': 500,
        'fileSize': 1024 * 1024 * (index + 1),
      },
    );
  }

  // Generate a list of sample photos for testing
  static List<PhotoModel> sampleList(int count) {
    return List.generate(count, (index) => sample(index: index));
  }
}