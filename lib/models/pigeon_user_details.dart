// If this file exists, replace its contents with a simpler implementation:

// This class should be deprecated - use UserData instead
@Deprecated('Use UserData class instead')
class PigeonUserDetails {
  final String? displayName;
  final String? email;
  final String? userId;
  
  PigeonUserDetails({
    this.displayName,
    this.email,
    this.userId,
  });
  
  // Safe conversion to map - prevent any type issues
  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName ?? '',
      'email': email ?? '',
      'userId': userId ?? '',
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
  
  // Safe conversion from map - prevent any casting issues
  static PigeonUserDetails? fromMap(Map<String, dynamic>? map) {
    if (map == null) return null;
    
    try {
      return PigeonUserDetails(
        displayName: map['displayName'] as String?,
        email: map['email'] as String?,
        userId: map['userId'] as String?,
      );
    } catch (e) {
      print("Error converting map to PigeonUserDetails: $e");
      return null;
    }
  }
}
