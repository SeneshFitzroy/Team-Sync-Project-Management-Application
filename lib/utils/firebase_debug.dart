import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseDebugger {
  // Check if a user exists in Firebase Auth
  static Future<bool> checkUserAuthExists(String email) async {
    try {
      final methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      print("Error checking user auth: $e");
      return false;
    }
  }
  
  // Check if a user document exists in Firestore
  static Future<bool> checkUserDocumentExists(String userId) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      return docSnapshot.exists;
    } catch (e) {
      print("Error checking user document: $e");
      return false;
    }
  }
  
  // Debug Firestore data retrieval
  static Future<void> debugFirestoreDocData(String collection, String docId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(collection).doc(docId);
      final snapshot = await docRef.get();
      
      if (snapshot.exists) {
        final data = snapshot.data();
        print("DOCUMENT DATA: $data");
        print("DATA TYPE: ${data.runtimeType}");
        
        // Check if data contains lists that might be causing the casting issue
        if (data != null) {
          for (var entry in data.entries) {
            print("FIELD: ${entry.key}, TYPE: ${entry.value.runtimeType}");
            
            if (entry.value is List) {
              print("LIST FIELD FOUND: ${entry.key}");
              final list = entry.value as List;
              if (list.isNotEmpty) {
                print("FIRST ELEMENT TYPE: ${list.first.runtimeType}");
              }
            }
          }
        }
      } else {
        print("NO DOCUMENT FOUND: $collection/$docId");
      }
    } catch (e) {
      print("ERROR DEBUGGING DOCUMENT: $e");
    }
  }

  // Add this method to specifically debug and fix PigeonUserDetails issues
  static Future<void> fixPigeonUserDetailsIssue(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      
      if (!userDoc.exists) {
        print("User document doesn't exist - creating a simple document");
        
        // Create a simple document with basic fields to ensure proper structure
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'displayName': 'User',
          'email': FirebaseAuth.instance.currentUser?.email ?? '',
          'userId': userId,
          'createdAt': DateTime.now().toIso8601String(),
          'isActive': true,
          'lastLogin': DateTime.now().toIso8601String(),
        });
        
        print("Created simple document for user $userId");
      } else {
        // Check for problematic list structures and fix them
        final data = userDoc.data();
        if (data != null) {
          bool needsFix = false;
          final fixedData = Map<String, dynamic>.from(data);
          
          // Check for and fix any List values that might be causing issues
          data.forEach((key, value) {
            if (value is List) {
              print("Found List value for key $key - converting to string");
              fixedData[key] = value.toString(); // Convert list to string
              needsFix = true;
            }
          });
          
          if (needsFix) {
            print("Fixing document structure for user $userId");
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .update(fixedData);
            print("Fixed document structure");
          }
        }
      }
    } catch (e) {
      print("Error fixing PigeonUserDetails issue: $e");
    }
  }
}
