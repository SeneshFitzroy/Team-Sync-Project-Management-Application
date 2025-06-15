// Simple test to verify TaskManager constructor
import 'package:flutter/material.dart';
import 'lib/Screens/TaskManager.dart';

void main() {
  print('Testing TaskManager instantiation...');
  
  try {
    // Test basic constructor
    const taskManager = TaskManager();
    print('✅ TaskManager() constructor works');
    
    // Test constructor with parameters
    const taskManagerWithParams = TaskManager(
      selectedProject: "Test Project",
      projectColor: Colors.blue,
      projectProgress: 0.5,
      projectMembers: "5 Members",
      projectStatus: "active",
    );
    print('✅ TaskManager with parameters works');
    print('TaskManager type: ${taskManager.runtimeType}');
    
  } catch (e) {
    print('❌ Error: $e');
  }
}
