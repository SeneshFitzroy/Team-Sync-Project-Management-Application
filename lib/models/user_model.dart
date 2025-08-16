import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final String? photoURL;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLoginAt;
  final bool isActive;
  final String role;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    this.photoURL,
    this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
    this.isActive = true,
    this.role = 'user',
  });

  // Convert UserModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'photoURL': photoURL,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : FieldValue.serverTimestamp(),
      'isActive': isActive,
      'role': role,
    };
  }

  // Create UserModel from Firestore Map
  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      uid: documentId,
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      phoneNumber: map['phoneNumber'],
      photoURL: map['photoURL'],
      createdAt: map['createdAt'] != null 
        ? (map['createdAt'] as Timestamp).toDate()
        : null,
      updatedAt: map['updatedAt'] != null 
        ? (map['updatedAt'] as Timestamp).toDate()
        : null,
      lastLoginAt: map['lastLoginAt'] != null 
        ? (map['lastLoginAt'] as Timestamp).toDate()
        : null,
      isActive: map['isActive'] ?? true,
      role: map['role'] ?? 'user',
    );
  }

  // Copy with method for updating user data
  UserModel copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? photoURL,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    bool? isActive,
    String? role,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
      role: role ?? this.role,
    );
  }

  // Get display initials for avatar
  String get initials {
    List<String> names = fullName.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (names.isNotEmpty) {
      return names[0][0].toUpperCase();
    }
    return 'U';
  }

  // Get display name (first name only)
  String get firstName {
    List<String> names = fullName.split(' ');
    return names.isNotEmpty ? names[0] : 'User';
  }

  // Check if user has profile photo
  bool get hasProfilePhoto => photoURL != null && photoURL!.isNotEmpty;

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, fullName: $fullName, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}
