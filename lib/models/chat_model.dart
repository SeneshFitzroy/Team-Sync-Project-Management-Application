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
