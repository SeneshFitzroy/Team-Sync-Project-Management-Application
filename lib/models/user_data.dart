class UserData {
  final String displayName;
  final String email;
  final String userId;
  final DateTime createdAt;
  final bool isActive;
  final DateTime? lastLogin;

  UserData({
    required this.displayName,
    required this.email,
    required this.userId,
    required this.createdAt,
    this.isActive = true,
    this.lastLogin,
  });

  // Convert to a Map for Firestore - keep it simple with basic types
  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'email': email,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(), // String format
      'isActive': isActive,
      'lastLogin': lastLogin?.toIso8601String(), // Nullable String
    };
  }

  // Create a UserData from Firestore Map - handle all possible data formats
  factory UserData.fromMap(Map<String, dynamic> map) {
    try {
      return UserData(
        displayName: map['displayName'] ?? '',
        email: map['email'] ?? '',
        userId: map['userId'] ?? '',
        createdAt: _parseDateTime(map['createdAt']) ?? DateTime.now(),
        isActive: map['isActive'] ?? true,
        lastLogin: _parseDateTime(map['lastLogin']),
      );
    } catch (e) {
      print("Error parsing UserData: $e");
      // Return a default object rather than throwing an exception
      return UserData(
        displayName: 'Error',
        email: '',
        userId: '',
        createdAt: DateTime.now(),
      );
    }
  }
  
  // Helper method to safely parse DateTime values from different formats
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    } else if (value is DateTime) {
      return value;
    } else if (value is int) {
      // Handle timestamp in milliseconds since epoch
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    
    return null;
  }
}
