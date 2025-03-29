import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload file
  Future<String> uploadFile(File file, String folderPath) async {
    try {
      final fileName = path.basename(file.path);
      final destination = '$folderPath/$fileName';

      final ref = _storage.ref().child(destination);
      final uploadTask = ref.putFile(file);

      // Track upload progress if needed
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        debugPrint('Upload progress: ${(progress * 100).toStringAsFixed(2)}%');
      });

      // Wait for upload to complete
      await uploadTask;

      // Get download URL
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading file: $e');
      rethrow;
    }
  }

  // Upload data (Uint8List)
  Future<String> uploadData(Uint8List data, String folderPath, String fileName) async {
    try {
      final destination = '$folderPath/$fileName';

      final ref = _storage.ref().child(destination);
      final uploadTask = ref.putData(data);

      // Wait for upload to complete
      await uploadTask;

      // Get download URL
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading data: $e');
      rethrow;
    }
  }

  // Download file URL
  Future<String> getDownloadURL(String filePath) async {
    try {
      return await _storage.ref().child(filePath).getDownloadURL();
    } catch (e) {
      debugPrint('Error getting download URL: $e');
      rethrow;
    }
  }

  // Delete file
  Future<void> deleteFile(String filePath) async {
    try {
      await _storage.ref().child(filePath).delete();
    } catch (e) {
      debugPrint('Error deleting file: $e');
      rethrow;
    }
  }

  // List files in a folder
  Future<List<Reference>> listFiles(String folderPath) async {
    try {
      final ListResult result = await _storage.ref().child(folderPath).listAll();
      return result.items;
    } catch (e) {
      debugPrint('Error listing files: $e');
      rethrow;
    }
  }

  // Get file metadata
  Future<FullMetadata> getMetadata(String filePath) async {
    try {
      return await _storage.ref().child(filePath).getMetadata();
    } catch (e) {
      debugPrint('Error getting metadata: $e');
      rethrow;
    }
  }

  // Update metadata
  Future<FullMetadata> updateMetadata(String filePath, SettableMetadata metadata) async {
    try {
      return await _storage.ref().child(filePath).updateMetadata(metadata);
    } catch (e) {
      debugPrint('Error updating metadata: $e');
      rethrow;
    }
  }
}