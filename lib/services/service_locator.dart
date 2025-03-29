// In lib/services/service_locator.dart
import 'package:fluttercomponenets/services/storage_service.dart';

import 'auth_service.dart';
import 'firestore_service.dart';

class ServiceLocator {
  static final ServiceLocator instance = ServiceLocator._internal();

  factory ServiceLocator() {
    return instance;
  }

  ServiceLocator._internal();

  late final AuthService authService = AuthService();
  late final FirestoreService firestoreService = FirestoreService();
  late final StorageService storageService = StorageService();
}

// Then in your code
final services = ServiceLocator();
