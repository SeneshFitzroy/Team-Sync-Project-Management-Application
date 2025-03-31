import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create document
  Future<DocumentReference> addDocument(String collection, Map<String, dynamic> data) async {
    try {
      return await _firestore.collection(collection).add(data);
    } catch (e) {
      debugPrint('Error adding document: $e');
      rethrow;
    }
  }

  // Create document with specific ID
  Future<void> setDocument(String collection, String docId, Map<String, dynamic> data, {bool merge = false}) async {
    try {
      await _firestore.collection(collection).doc(docId).set(data, SetOptions(merge: merge));
    } catch (e) {
      debugPrint('Error setting document: $e');
      rethrow;
    }
  }

  // Read document
  Future<DocumentSnapshot> getDocument(String collection, String docId) async {
    try {
      return await _firestore.collection(collection).doc(docId).get();
    } catch (e) {
      debugPrint('Error getting document: $e');
      rethrow;
    }
  }

  // Read collection
  Future<QuerySnapshot> getCollection(String collection) async {
    try {
      return await _firestore.collection(collection).get();
    } catch (e) {
      debugPrint('Error getting collection: $e');
      rethrow;
    }
  }

  // Query collection with filters
  Future<QuerySnapshot> queryCollection(
      String collection, {
        List<List<dynamic>> whereConditions = const [],
        String? orderBy,
        bool descending = false,
        int? limit,
      }) async {
    try {
      Query query = _firestore.collection(collection);

      // Apply where conditions
      for (final condition in whereConditions) {
        if (condition.length == 3) {
          query = query.where(condition[0], isEqualTo: condition[1] == '==' ? condition[2] : null);
          query = query.where(condition[0], isGreaterThan: condition[1] == '>' ? condition[2] : null);
          query = query.where(condition[0], isLessThan: condition[1] == '<' ? condition[2] : null);
          // Add other conditions as needed
        }
      }

      // Apply orderBy
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      // Apply limit
      if (limit != null) {
        query = query.limit(limit);
      }

      return await query.get();
    } catch (e) {
      debugPrint('Error querying collection: $e');
      rethrow;
    }
  }

  // Update document
  Future<void> updateDocument(String collection, String docId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collection).doc(docId).update(data);
    } catch (e) {
      debugPrint('Error updating document: $e');
      rethrow;
    }
  }

  // Delete document
  Future<void> deleteDocument(String collection, String docId) async {
    try {
      await _firestore.collection(collection).doc(docId).delete();
    } catch (e) {
      debugPrint('Error deleting document: $e');
      rethrow;
    }
  }

  // Get real-time updates for a document
  Stream<DocumentSnapshot> documentStream(String collection, String docId) {
    return _firestore.collection(collection).doc(docId).snapshots();
  }

  // Get real-time updates for a collection
  Stream<QuerySnapshot> collectionStream(String collection) {
    return _firestore.collection(collection).snapshots();
  }

  // Batch writes
  Future<void> batchWrite(Function(WriteBatch) batchOperations) async {
    try {
      WriteBatch batch = _firestore.batch();
      batchOperations(batch);
      await batch.commit();
    } catch (e) {
      debugPrint('Error performing batch write: $e');
      rethrow;
    }
  }

  // Transaction
  Future<T> transaction<T>(Future<T> Function(Transaction) transactionOperations) async {
    try {
      return await _firestore.runTransaction(transactionOperations);
    } catch (e) {
      debugPrint('Error performing transaction: $e');
      rethrow;
    }
  }

  Stream<QuerySnapshot<Object?>>? getUserProjects(String uid) {}
}