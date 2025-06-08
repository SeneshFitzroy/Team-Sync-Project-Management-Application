import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default Firebase configuration options for your app.
///
/// You need to replace these placeholders with actual values from your Firebase project.
/// Go to Firebase console -> Project settings -> General -> Your apps -> SDK setup and configuration
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }
  // Firebase configuration values for web (same project)
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDdk_dktdHQ2RnVMxugVdbxk0E6pJlvWBc',
    appId: '1:310750228851:web:YOUR_WEB_APP_ID', // You'll need to create a web app in Firebase console for the actual Web App ID
    messagingSenderId: '310750228851',
    projectId: 'team-sync-project-management',
    authDomain: 'team-sync-project-management.firebaseapp.com',
    storageBucket: 'team-sync-project-management.firebasestorage.app',
  );
  // Firebase configuration values from google-services.json
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDdk_dktdHQ2RnVMxugVdbxk0E6pJlvWBc',
    appId: '1:310750228851:android:0f9170f979cab3d6769506',
    messagingSenderId: '310750228851',
    projectId: 'team-sync-project-management',
    storageBucket: 'team-sync-project-management.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDdk_dktdHQ2RnVMxugVdbxk0E6pJlvWBc',
    appId: '1:310750228851:ios:YOUR_IOS_APP_ID', // You'll need to create an iOS app in Firebase console
    messagingSenderId: '310750228851',
    projectId: 'team-sync-project-management',
    storageBucket: 'team-sync-project-management.firebasestorage.app',
    iosClientId: 'YOUR_IOS_CLIENT_ID',
    iosBundleId: 'com.example.fluttercomponenets',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDdk_dktdHQ2RnVMxugVdbxk0E6pJlvWBc',
    appId: '1:310750228851:ios:YOUR_MACOS_APP_ID', // You'll need to create a macOS app in Firebase console
    messagingSenderId: '310750228851',
    projectId: 'team-sync-project-management',
    storageBucket: 'team-sync-project-management.firebasestorage.app',
    iosClientId: 'YOUR_IOS_CLIENT_ID',
    iosBundleId: 'com.example.fluttercomponenets',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDdk_dktdHQ2RnVMxugVdbxk0E6pJlvWBc',
    appId: '1:310750228851:web:YOUR_WINDOWS_APP_ID', // You'll need to create a web app for Windows
    messagingSenderId: '310750228851',
    projectId: 'team-sync-project-management',
    storageBucket: 'team-sync-project-management.firebasestorage.app',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyDdk_dktdHQ2RnVMxugVdbxk0E6pJlvWBc',
    appId: '1:310750228851:web:YOUR_LINUX_APP_ID', // You'll need to create a web app for Linux
    messagingSenderId: '310750228851',
    projectId: 'team-sync-project-management',
    storageBucket: 'team-sync-project-management.firebasestorage.app',
  );
}
