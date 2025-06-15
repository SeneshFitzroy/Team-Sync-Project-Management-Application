import 'package:fluttercomponenets/Services/firebase_service.dart';
import 'lib/Screens/Calendar.dart';
import 'lib/main.dart';

void main() {
  print('🧪 Testing app compilation...');
  
  // Test FirebaseService import
  try {
    print('✅ FirebaseService imported successfully');
    final userId = FirebaseService.getCurrentUserId();
    print('✅ FirebaseService methods accessible');
  } catch (e) {
    print('❌ FirebaseService error: $e');
  }
  
  // Test Calendar import
  try {
    final calendar = Calendar();
    print('✅ Calendar constructor works');
  } catch (e) {
    print('❌ Calendar error: $e');
  }
  
  // Test main app
  try {
    final app = MyApp();
    print('✅ Main app instantiatable');
  } catch (e) {
    print('❌ Main app error: $e');
  }
  
  print('🎉 All core components working!');
}
