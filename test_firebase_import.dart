import 'lib/Services/firebase_service.dart';

void main() {
  print('Testing FirebaseService import...');
  print('Current user ID: ${FirebaseService.getCurrentUserId()}');
  print('FirebaseService import works!');
}
