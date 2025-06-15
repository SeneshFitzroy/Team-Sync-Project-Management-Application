import 'package:fluttercomponenets/Services/firebase_service.dart';

// Test file to verify FirebaseService import works
void main() {
  print('Testing FirebaseService import...');
  
  // Test static method access
  final userId = FirebaseService.getCurrentUserId();
  print('Current user ID: $userId');
  
  print('FirebaseService import test successful!');
}
