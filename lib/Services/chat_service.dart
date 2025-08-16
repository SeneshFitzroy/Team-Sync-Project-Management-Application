import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';
import '../models/user_model.dart';
import 'auth_service.dart';

class ChatService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _chatRoomsCollection = 'chatRooms';
  static const String _messagesCollection = 'messages';
  static const String _usersCollection = 'users';

  // Create or get existing chat room between two users
  static Future<String> createOrGetChatRoom(String otherUserId) async {
    try {
      String? currentUserId = AuthService.currentUserId;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Create a consistent room ID by sorting user IDs
      List<String> participants = [currentUserId, otherUserId];
      participants.sort();
      String roomId = participants.join('_');

      // Check if room already exists
      DocumentSnapshot roomDoc = await _firestore
          .collection(_chatRoomsCollection)
          .doc(roomId)
          .get();

      if (!roomDoc.exists) {
        // Get user names
        UserModel? currentUser = await AuthService.getUserData(currentUserId);
        UserModel? otherUser = await AuthService.getUserData(otherUserId);

        // Create new chat room
        await _firestore.collection(_chatRoomsCollection).doc(roomId).set({
          'participants': participants,
          'participantNames': {
            currentUserId: currentUser?.fullName ?? 'Unknown',
            otherUserId: otherUser?.fullName ?? 'Unknown',
          },
          'lastMessage': null,
          'lastMessageTime': null,
          'lastSenderId': null,
          'unreadCounts': {
            currentUserId: 0,
            otherUserId: 0,
          },
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      return roomId;
    } catch (e) {
      throw Exception('Error creating/getting chat room: $e');
    }
  }

  // Send a message
  static Future<void> sendMessage({
    required String chatRoomId,
    required String receiverId,
    required String message,
    String type = 'text',
    Map<String, dynamic>? metadata,
  }) async {
    try {
      String? currentUserId = AuthService.currentUserId;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Get current user data
      UserModel? currentUser = await AuthService.getUserData(currentUserId);
      if (currentUser == null) {
        throw Exception('User data not found');
      }

      // Create message data
      Map<String, dynamic> messageData = {
        'senderId': currentUserId,
        'senderName': currentUser.fullName,
        'senderPhotoURL': currentUser.photoURL ?? '',
        'receiverId': receiverId,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'type': type,
        'metadata': metadata,
      };

      // Add message to subcollection
      await _firestore
          .collection(_chatRoomsCollection)
          .doc(chatRoomId)
          .collection(_messagesCollection)
          .add(messageData);

      // Update chat room with last message info
      await _firestore
          .collection(_chatRoomsCollection)
          .doc(chatRoomId)
          .update({
        'lastMessage': message,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastSenderId': currentUserId,
        'updatedAt': FieldValue.serverTimestamp(),
        'unreadCounts.$receiverId': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }

  // Get messages stream for a chat room
  static Stream<List<ChatMessage>> getMessages(String chatRoomId) {
    return _firestore
        .collection(_chatRoomsCollection)
        .doc(chatRoomId)
        .collection(_messagesCollection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get chat rooms for current user
  static Stream<List<ChatRoom>> getUserChatRooms() {
    String? currentUserId = AuthService.currentUserId;
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection(_chatRoomsCollection)
        .where('participants', arrayContains: currentUserId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatRoom.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Mark messages as read
  static Future<void> markMessagesAsRead(String chatRoomId, String senderId) async {
    try {
      String? currentUserId = AuthService.currentUserId;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Get unread messages from the sender
      QuerySnapshot unreadMessages = await _firestore
          .collection(_chatRoomsCollection)
          .doc(chatRoomId)
          .collection(_messagesCollection)
          .where('senderId', isEqualTo: senderId)
          .where('isRead', isEqualTo: false)
          .get();

      // Mark all unread messages as read
      WriteBatch batch = _firestore.batch();
      for (QueryDocumentSnapshot doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();

      // Reset unread count for current user
      await _firestore
          .collection(_chatRoomsCollection)
          .doc(chatRoomId)
          .update({
        'unreadCounts.$currentUserId': 0,
      });
    } catch (e) {
      throw Exception('Error marking messages as read: $e');
    }
  }

  // Get all users for chat (excluding current user)
  static Future<List<UserModel>> getAllUsers() async {
    try {
      String? currentUserId = AuthService.currentUserId;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      QuerySnapshot snapshot = await _firestore
          .collection(_usersCollection)
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .where((user) => user.uid != currentUserId)
          .toList();
    } catch (e) {
      throw Exception('Error getting users: $e');
    }
  }

  // Search users by name or email
  static Future<List<UserModel>> searchUsers(String query) async {
    try {
      String? currentUserId = AuthService.currentUserId;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      if (query.isEmpty) {
        return await getAllUsers();
      }

      QuerySnapshot snapshot = await _firestore
          .collection(_usersCollection)
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .where((user) => 
              user.uid != currentUserId &&
              (user.fullName.toLowerCase().contains(query.toLowerCase()) ||
               user.email.toLowerCase().contains(query.toLowerCase())))
          .toList();
    } catch (e) {
      throw Exception('Error searching users: $e');
    }
  }

  // Get total unread count for current user
  static Stream<int> getTotalUnreadCount() {
    String? currentUserId = AuthService.currentUserId;
    if (currentUserId == null) {
      return Stream.value(0);
    }

    return _firestore
        .collection(_chatRoomsCollection)
        .where('participants', arrayContains: currentUserId)
        .snapshots()
        .map((snapshot) {
      int totalUnread = 0;
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        Map<String, dynamic> unreadCounts = data['unreadCounts'] ?? {};
        totalUnread += (unreadCounts[currentUserId] as int?) ?? 0;
      }
      return totalUnread;
    });
  }

  // Delete a message (only sender can delete)
  static Future<void> deleteMessage(String chatRoomId, String messageId) async {
    try {
      String? currentUserId = AuthService.currentUserId;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Get message to verify sender
      DocumentSnapshot messageDoc = await _firestore
          .collection(_chatRoomsCollection)
          .doc(chatRoomId)
          .collection(_messagesCollection)
          .doc(messageId)
          .get();

      if (!messageDoc.exists) {
        throw Exception('Message not found');
      }

      Map<String, dynamic> messageData = messageDoc.data() as Map<String, dynamic>;
      if (messageData['senderId'] != currentUserId) {
        throw Exception('You can only delete your own messages');
      }

      // Delete the message
      await messageDoc.reference.delete();
    } catch (e) {
      throw Exception('Error deleting message: $e');
    }
  }

  // Delete entire chat room (only if user is participant)
  static Future<void> deleteChatRoom(String chatRoomId) async {
    try {
      String? currentUserId = AuthService.currentUserId;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Verify user is participant
      DocumentSnapshot roomDoc = await _firestore
          .collection(_chatRoomsCollection)
          .doc(chatRoomId)
          .get();

      if (!roomDoc.exists) {
        throw Exception('Chat room not found');
      }

      Map<String, dynamic> roomData = roomDoc.data() as Map<String, dynamic>;
      List<String> participants = List<String>.from(roomData['participants'] ?? []);
      
      if (!participants.contains(currentUserId)) {
        throw Exception('You are not a participant in this chat');
      }

      // Delete all messages in the chat room
      QuerySnapshot messages = await _firestore
          .collection(_chatRoomsCollection)
          .doc(chatRoomId)
          .collection(_messagesCollection)
          .get();

      WriteBatch batch = _firestore.batch();
      for (QueryDocumentSnapshot doc in messages.docs) {
        batch.delete(doc.reference);
      }

      // Delete the chat room
      batch.delete(roomDoc.reference);
      await batch.commit();
    } catch (e) {
      throw Exception('Error deleting chat room: $e');
    }
  }
}
