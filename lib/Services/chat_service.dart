import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';
import '../models/user_model.dart';
import '../models/project.dart';
import 'auth_service.dart';

class ChatService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _chatRoomsCollection = 'chatRooms';
  static const String _messagesCollection = 'messages';
  static const String _projectChatsCollection = 'projectChats';
  static const String _projectMessagesCollection = 'projectMessages';
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

  // ============ PROJECT CHAT FUNCTIONALITY ============

  /// Get all project chats for the current user
  static Stream<List<ProjectChatRoom>> getUserProjectChats() {
    String? currentUserId = AuthService.currentUserId;
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection(_projectChatsCollection)
        .where('members', arrayContains: currentUserId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProjectChatRoom.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Create project chat room when project is created
  static Future<String> createProjectChatRoom(Project project) async {
    try {
      String? currentUserId = AuthService.currentUserId;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Get member names
      Map<String, String> memberNames = {};
      for (String memberId in project.teamMembers) {
        UserModel? user = await AuthService.getUserData(memberId);
        if (user != null) {
          memberNames[memberId] = user.fullName;
        }
      }

      // Create project chat data
      Map<String, dynamic> projectChatData = {
        'projectId': project.id,
        'projectName': project.name,
        'members': project.teamMembers,
        'memberNames': memberNames,
        'lastMessage': null,
        'lastMessageTime': null,
        'lastSenderId': null,
        'unreadCounts': {for (String member in project.teamMembers) member: 0},
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      DocumentReference docRef = await _firestore
          .collection(_projectChatsCollection)
          .add(projectChatData);

      // Send welcome message
      await sendProjectMessage(
        projectChatId: docRef.id,
        message: '🎉 Welcome to ${project.name} project chat! All team members can collaborate here.',
        type: 'system',
      );

      return docRef.id;
    } catch (e) {
      throw Exception('Error creating project chat room: $e');
    }
  }

  /// Send a project message
  static Future<void> sendProjectMessage({
    required String projectChatId,
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
      String senderName = type == 'system' ? 'System' : (currentUser?.fullName ?? 'Unknown');

      // Get project chat to determine read by users
      DocumentSnapshot projectChatDoc = await _firestore
          .collection(_projectChatsCollection)
          .doc(projectChatId)
          .get();
      
      if (!projectChatDoc.exists) {
        throw Exception('Project chat not found');
      }

      Map<String, dynamic> projectChatData = projectChatDoc.data() as Map<String, dynamic>;
      List<String> members = List<String>.from(projectChatData['members'] ?? []);
      
      Map<String, bool> readBy = {};
      for (String member in members) {
        readBy[member] = member == currentUserId; // Only sender has read it initially
      }

      // Create message data
      Map<String, dynamic> messageData = {
        'projectChatId': projectChatId,
        'senderId': currentUserId,
        'senderName': senderName,
        'senderPhotoURL': currentUser?.photoURL ?? '',
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'readBy': readBy,
        'type': type,
        'metadata': metadata,
      };

      // Add message to project messages collection
      await _firestore
          .collection(_projectMessagesCollection)
          .add(messageData);

      // Update project chat room with last message
      Map<String, dynamic> updates = {
        'lastMessage': message,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastSenderId': currentUserId,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Increment unread count for all members except sender
      for (String member in members) {
        if (member != currentUserId) {
          updates['unreadCounts.$member'] = FieldValue.increment(1);
        }
      }

      await _firestore
          .collection(_projectChatsCollection)
          .doc(projectChatId)
          .update(updates);
    } catch (e) {
      throw Exception('Error sending project message: $e');
    }
  }

  /// Get messages for a project chat
  static Stream<List<ProjectChatMessage>> getProjectChatMessages(String projectChatId) {
    return _firestore
        .collection(_projectMessagesCollection)
        .where('projectChatId', isEqualTo: projectChatId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProjectChatMessage.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Mark project messages as read
  static Future<void> markProjectMessagesAsRead(String projectChatId) async {
    try {
      String? currentUserId = AuthService.currentUserId;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Reset unread count for current user
      await _firestore
          .collection(_projectChatsCollection)
          .doc(projectChatId)
          .update({
        'unreadCounts.$currentUserId': 0,
      });

      // Mark all messages as read by current user
      QuerySnapshot messages = await _firestore
          .collection(_projectMessagesCollection)
          .where('projectChatId', isEqualTo: projectChatId)
          .where('readBy.$currentUserId', isEqualTo: false)
          .get();

      WriteBatch batch = _firestore.batch();
      for (QueryDocumentSnapshot doc in messages.docs) {
        batch.update(doc.reference, {
          'readBy.$currentUserId': true,
        });
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Error marking project messages as read: $e');
    }
  }

  /// Update project chat when project members change
  static Future<void> updateProjectChatMembers(String projectId, Project updatedProject) async {
    try {
      // Find the project chat
      QuerySnapshot projectChats = await _firestore
          .collection(_projectChatsCollection)
          .where('projectId', isEqualTo: projectId)
          .get();

      if (projectChats.docs.isNotEmpty) {
        DocumentSnapshot projectChatDoc = projectChats.docs.first;
        Map<String, dynamic> projectChatData = projectChatDoc.data() as Map<String, dynamic>;
        List<String> oldMembers = List<String>.from(projectChatData['members'] ?? []);

        // Get member names
        Map<String, String> memberNames = {};
        for (String memberId in updatedProject.teamMembers) {
          UserModel? user = await AuthService.getUserData(memberId);
          if (user != null) {
            memberNames[memberId] = user.fullName;
          }
        }

        // Update project chat
        await _firestore
            .collection(_projectChatsCollection)
            .doc(projectChatDoc.id)
            .update({
          'members': updatedProject.teamMembers,
          'memberNames': memberNames,
          'projectName': updatedProject.name,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Send system message about member changes
        List<String> removedMembers = oldMembers
            .where((member) => !updatedProject.teamMembers.contains(member))
            .toList();
        
        List<String> addedMembers = updatedProject.teamMembers
            .where((member) => !oldMembers.contains(member))
            .toList();

        if (removedMembers.isNotEmpty || addedMembers.isNotEmpty) {
          String message = '';
          if (addedMembers.isNotEmpty) {
            List<String> addedNames = [];
            for (String id in addedMembers) {
              addedNames.add(memberNames[id] ?? 'Unknown');
            }
            message += '➕ ${addedNames.join(', ')} joined the project';
          }
          if (removedMembers.isNotEmpty) {
            if (message.isNotEmpty) message += '\n';
            List<String> removedNames = [];
            Map<String, String> oldMemberNames = Map<String, String>.from(projectChatData['memberNames'] ?? {});
            for (String id in removedMembers) {
              removedNames.add(oldMemberNames[id] ?? 'Unknown');
            }
            message += '➖ ${removedNames.join(', ')} left the project';
          }

          await sendProjectMessage(
            projectChatId: projectChatDoc.id,
            message: message,
            type: 'system',
          );
        }
      }
    } catch (e) {
      throw Exception('Error updating project chat members: $e');
    }
  }

  /// Delete project chat when project is deleted
  static Future<void> deleteProjectChat(String projectId) async {
    try {
      // Find and delete the project chat
      QuerySnapshot projectChats = await _firestore
          .collection(_projectChatsCollection)
          .where('projectId', isEqualTo: projectId)
          .get();

      if (projectChats.docs.isNotEmpty) {
        String projectChatId = projectChats.docs.first.id;

        // Delete all messages in the project chat
        QuerySnapshot messages = await _firestore
            .collection(_projectMessagesCollection)
            .where('projectChatId', isEqualTo: projectChatId)
            .get();

        WriteBatch batch = _firestore.batch();
        for (QueryDocumentSnapshot doc in messages.docs) {
          batch.delete(doc.reference);
        }

        // Delete the project chat room
        batch.delete(projectChats.docs.first.reference);
        
        await batch.commit();
      }
    } catch (e) {
      throw Exception('Error deleting project chat: $e');
    }
  }

  /// Get total unread count for project chats
  static Stream<int> getTotalProjectUnreadCount() {
    String? currentUserId = AuthService.currentUserId;
    if (currentUserId == null) {
      return Stream.value(0);
    }

    return _firestore
        .collection(_projectChatsCollection)
        .where('members', arrayContains: currentUserId)
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
}
