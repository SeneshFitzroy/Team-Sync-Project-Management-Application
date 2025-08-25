import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String senderPhotoURL;
  final String receiverId;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String type; // 'text', 'image', 'file'
  final Map<String, dynamic>? metadata; // For attachments, etc.

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderPhotoURL,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.type = 'text',
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'senderPhotoURL': senderPhotoURL,
      'receiverId': receiverId,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'type': type,
      'metadata': metadata,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map, String documentId) {
    return ChatMessage(
      id: documentId,
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      senderPhotoURL: map['senderPhotoURL'] ?? '',
      receiverId: map['receiverId'] ?? '',
      message: map['message'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      isRead: map['isRead'] ?? false,
      type: map['type'] ?? 'text',
      metadata: map['metadata'],
    );
  }

  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? senderPhotoURL,
    String? receiverId,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    String? type,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderPhotoURL: senderPhotoURL ?? this.senderPhotoURL,
      receiverId: receiverId ?? this.receiverId,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
    );
  }
}

class ChatRoom {
  final String id;
  final List<String> participants;
  final Map<String, String> participantNames;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? lastSenderId;
  final Map<String, int> unreadCounts;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatRoom({
    required this.id,
    required this.participants,
    required this.participantNames,
    this.lastMessage,
    this.lastMessageTime,
    this.lastSenderId,
    required this.unreadCounts,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'participantNames': participantNames,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime != null 
        ? Timestamp.fromDate(lastMessageTime!) 
        : null,
      'lastSenderId': lastSenderId,
      'unreadCounts': unreadCounts,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory ChatRoom.fromMap(Map<String, dynamic> map, String documentId) {
    return ChatRoom(
      id: documentId,
      participants: List<String>.from(map['participants'] ?? []),
      participantNames: Map<String, String>.from(map['participantNames'] ?? {}),
      lastMessage: map['lastMessage'],
      lastMessageTime: map['lastMessageTime'] != null 
        ? (map['lastMessageTime'] as Timestamp).toDate()
        : null,
      lastSenderId: map['lastSenderId'],
      unreadCounts: Map<String, int>.from(map['unreadCounts'] ?? {}),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Get the other participant's ID (for 1-on-1 chat)
  String? getOtherParticipantId(String currentUserId) {
    return participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
  }

  // Get the other participant's name (for 1-on-1 chat)
  String getOtherParticipantName(String currentUserId) {
    String? otherId = getOtherParticipantId(currentUserId);
    if (otherId != null && otherId.isNotEmpty) {
      return participantNames[otherId] ?? 'Unknown User';
    }
    return 'Unknown User';
  }

  // Get unread count for a specific user
  int getUnreadCount(String userId) {
    return unreadCounts[userId] ?? 0;
  }
}

class ChatUser {
  final String id;
  final String name;
  final String avatar;
  final String lastMessage;
  final DateTime lastMessageTime;
  final bool isOnline;
  final int unreadCount;

  ChatUser({
    required this.id,
    required this.name,
    required this.avatar,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.isOnline,
    required this.unreadCount,
  });

  factory ChatUser.fromMap(Map<String, dynamic> map) {
    return ChatUser(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      avatar: map['avatar'] ?? '',
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime: DateTime.fromMillisecondsSinceEpoch(map['lastMessageTime'] ?? 0),
      isOnline: map['isOnline'] ?? false,
      unreadCount: map['unreadCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.millisecondsSinceEpoch,
      'isOnline': isOnline,
      'unreadCount': unreadCount,
    };
  }
}

// Project Chat Models
class ProjectChatRoom {
  final String id;
  final String projectId;
  final String projectName;
  final List<String> members;
  final Map<String, String> memberNames;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? lastSenderId;
  final Map<String, int> unreadCounts;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProjectChatRoom({
    required this.id,
    required this.projectId,
    required this.projectName,
    required this.members,
    required this.memberNames,
    this.lastMessage,
    this.lastMessageTime,
    this.lastSenderId,
    required this.unreadCounts,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'projectName': projectName,
      'members': members,
      'memberNames': memberNames,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime != null 
        ? Timestamp.fromDate(lastMessageTime!) 
        : null,
      'lastSenderId': lastSenderId,
      'unreadCounts': unreadCounts,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory ProjectChatRoom.fromMap(Map<String, dynamic> map, String documentId) {
    return ProjectChatRoom(
      id: documentId,
      projectId: map['projectId'] ?? '',
      projectName: map['projectName'] ?? '',
      members: List<String>.from(map['members'] ?? []),
      memberNames: Map<String, String>.from(map['memberNames'] ?? {}),
      lastMessage: map['lastMessage'],
      lastMessageTime: map['lastMessageTime'] != null 
        ? (map['lastMessageTime'] as Timestamp).toDate()
        : null,
      lastSenderId: map['lastSenderId'],
      unreadCounts: Map<String, int>.from(map['unreadCounts'] ?? {}),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Get unread count for a specific user
  int getUnreadCount(String userId) {
    return unreadCounts[userId] ?? 0;
  }
}

class ProjectChatMessage {
  final String id;
  final String projectChatId;
  final String senderId;
  final String senderName;
  final String senderPhotoURL;
  final String message;
  final DateTime timestamp;
  final Map<String, bool> readBy; // userId -> isRead
  final String type; // 'text', 'image', 'file', 'system'
  final Map<String, dynamic>? metadata;

  ProjectChatMessage({
    required this.id,
    required this.projectChatId,
    required this.senderId,
    required this.senderName,
    required this.senderPhotoURL,
    required this.message,
    required this.timestamp,
    required this.readBy,
    this.type = 'text',
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'projectChatId': projectChatId,
      'senderId': senderId,
      'senderName': senderName,
      'senderPhotoURL': senderPhotoURL,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'readBy': readBy,
      'type': type,
      'metadata': metadata,
    };
  }

  factory ProjectChatMessage.fromMap(Map<String, dynamic> map, String documentId) {
    return ProjectChatMessage(
      id: documentId,
      projectChatId: map['projectChatId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      senderPhotoURL: map['senderPhotoURL'] ?? '',
      message: map['message'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      readBy: Map<String, bool>.from(map['readBy'] ?? {}),
      type: map['type'] ?? 'text',
      metadata: map['metadata'],
    );
  }

  bool isReadByUser(String userId) {
    return readBy[userId] ?? false;
  }
}
