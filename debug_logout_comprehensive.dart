// Debug script for comprehensive logout testing
// Run this in your terminal to test logout functionality

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogoutDebugHelper {
  static Future<void> printFullDebugInfo() async {
    print("================================");
    print("COMPREHENSIVE LOGOUT DEBUG INFO");
    print("================================");
    print("Timestamp: ${DateTime.now()}");
    print("");
    
    // 1. Firebase Auth State
    print("1. FIREBASE AUTH STATE:");
    try {
      final auth = FirebaseAuth.instance;
      final currentUser = auth.currentUser;
      
      print("   - Current User: ${currentUser?.uid ?? 'null'}");
      print("   - Email: ${currentUser?.email ?? 'null'}");
      print("   - Display Name: ${currentUser?.displayName ?? 'null'}");
      print("   - Email Verified: ${currentUser?.emailVerified ?? 'null'}");
      print("   - Is Anonymous: ${currentUser?.isAnonymous ?? 'null'}");
      print("   - Provider Data: ${currentUser?.providerData.length ?? 0} providers");
      
      if (currentUser != null) {
        print("   - Creation Time: ${currentUser.metadata.creationTime}");
        print("   - Last Sign In: ${currentUser.metadata.lastSignInTime}");
      }
    } catch (e) {
      print("   ERROR: $e");
    }
    print("");
    
    // 2. SharedPreferences State
    print("2. SHARED PREFERENCES STATE:");
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      print("   - Total Keys: ${keys.length}");
      if (keys.isEmpty) {
        print("   - No stored preferences");
      } else {
        for (String key in keys) {
          final value = prefs.get(key);
          print("   - $key: $value (${value.runtimeType})");
        }
      }
      
      // Specifically check bypass mode
      final bypassMode = prefs.getBool('bypass_mode');
      print("   - Bypass Mode: $bypassMode");
      
    } catch (e) {
      print("   ERROR: $e");
    }
    print("");
    
    // 3. Auth State Stream
    print("3. AUTH STATE STREAM TEST:");
    try {
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        print("   - Auth State Changed: ${user?.uid ?? 'null'}");
      });
      print("   - Auth state listener attached");
    } catch (e) {
      print("   ERROR: $e");
    }
    print("");
    
    print("================================");
  }
  
  static Future<void> performFullLogoutTest() async {
    print("================================");
    print("PERFORMING FULL LOGOUT TEST");
    print("================================");
    
    try {
      // Before logout state
      print("BEFORE LOGOUT:");
      await printFullDebugInfo();
      
      print("PERFORMING LOGOUT STEPS:");
      
      // Step 1: Clear SharedPreferences
      print("Step 1: Clearing SharedPreferences...");
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print("✓ SharedPreferences cleared");
      
      // Step 2: Firebase signout
      print("Step 2: Firebase signout...");
      await FirebaseAuth.instance.signOut();
      print("✓ Firebase signOut() called");
      
      // Step 3: Wait for state change
      print("Step 3: Waiting for state change...");
      await Future.delayed(Duration(seconds: 2));
      
      // After logout state
      print("AFTER LOGOUT:");
      await printFullDebugInfo();
      
      // Verification
      final userAfter = FirebaseAuth.instance.currentUser;
      final prefsAfter = await SharedPreferences.getInstance();
      final keysAfter = prefsAfter.getKeys();
      
      print("LOGOUT VERIFICATION:");
      print("✓ Firebase user null: ${userAfter == null}");
      print("✓ SharedPreferences empty: ${keysAfter.isEmpty}");
      
      if (userAfter == null && keysAfter.isEmpty) {
        print("🎉 LOGOUT TEST PASSED!");
      } else {
        print("❌ LOGOUT TEST FAILED!");
        if (userAfter != null) {
          print("   - Firebase user still exists");
        }
        if (keysAfter.isNotEmpty) {
          print("   - SharedPreferences not cleared");
        }
      }
      
    } catch (e) {
      print("❌ LOGOUT TEST ERROR: $e");
    }
    
    print("================================");
  }
  
  static Future<void> testAuthStateListener() async {
    print("================================");
    print("TESTING AUTH STATE LISTENER");
    print("================================");
    
    print("Setting up auth state listener...");
    
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      print("AUTH STATE CHANGE DETECTED:");
      print("  - User: ${user?.uid ?? 'null'}");
      print("  - Email: ${user?.email ?? 'null'}");
      print("  - Timestamp: ${DateTime.now()}");
    });
    
    print("✓ Auth state listener active");
    print("Now perform logout and watch for state changes...");
    print("================================");
  }
}

void main() async {
  // This would be called from the app to test logout
  print("Logout Debug Helper Loaded");
  print("Call LogoutDebugHelper.printFullDebugInfo() to see current state");
  print("Call LogoutDebugHelper.performFullLogoutTest() to test logout");
  print("Call LogoutDebugHelper.testAuthStateListener() to monitor auth changes");
}
