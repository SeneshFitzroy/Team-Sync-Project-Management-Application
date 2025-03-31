import 'package:get_it/get_it.dart';
import 'package:fluttercomponenets/services/storage_service.dart';
import 'auth_service.dart';
import 'firebase_service.dart';
import 'firestore_service.dart';
import 'storage_service.dart' show StorageService;

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

final GetIt locator = GetIt.instance;

void setupServiceLocator() {
  locator.registerSingleton<AuthService>(AuthService());
  locator.registerSingleton<FirebaseService>(FirebaseService());
  locator.registerSingleton<FirestoreService>(FirestoreService());
  locator.registerSingleton<StorageService>(StorageService());
}