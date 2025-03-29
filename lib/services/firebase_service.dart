import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();

  factory FirebaseService() {
    return _instance;
  }

  FirebaseService._internal();

  bool _initialized = false;

  /// Initialize Firebase services
  Future<void> initialize() async {
    if (!_initialized) {
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        _initialized = true;
        debugPrint('Firebase initialized successfully');
      } catch (e) {
        debugPrint('Error initializing Firebase: $e');
        rethrow;
      }
    }
  }

  bool get isInitialized => _initialized;
}

class DefaultFirebaseOptions {
  static var currentPlatform;
}