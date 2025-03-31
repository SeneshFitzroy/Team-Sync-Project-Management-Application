import 'package:cloud_firestore/cloud_firestore.dart';

/// Extensions for safer Firestore operations
extension FirestoreDocumentExtension on DocumentSnapshot {
  /// Get data safely without attempting PigeonUserDetails casting
  Map<String, dynamic>? getDataSafely() {
    try {
      final data = this.data();
      if (data == null) return null;
      
      // Make sure it's the correct type
      if (data is Map<String, dynamic>) {
        return data;
      } else {
        print("Warning: Document data is not Map<String, dynamic>: ${data.runtimeType}");
        // Try to convert to Map<String, dynamic>
        return Map<String, dynamic>.from(data as Map);
      }
    } catch (e) {
      print("Error getting data safely: $e");
      return null;
    }
  }
}
