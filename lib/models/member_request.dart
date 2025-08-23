import 'package:cloud_firestore/cloud_firestore.dart';

enum RequestStatus { pending, accepted, declined, cancelled }
enum RequestType { projectInvite, teamInvite }

class MemberRequest {
  final String? id;
  final String fromUserId; // User who sent the request
  final String toUserId; // User who receives the request
  final String? projectId; // Project ID if it's a project invite
  final RequestType type;
  final RequestStatus status;
  final String message; // Optional message from sender
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? respondedAt;

  MemberRequest({
    this.id,
    required this.fromUserId,
    required this.toUserId,
    this.projectId,
    required this.type,
    this.status = RequestStatus.pending,
    this.message = '',
    required this.createdAt,
    required this.updatedAt,
    this.respondedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'projectId': projectId,
      'type': type.name,
      'status': status.name,
      'message': message,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'respondedAt': respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
    };
  }

  static MemberRequest fromMap(Map<String, dynamic> map, String id) {
    return MemberRequest(
      id: id,
      fromUserId: map['fromUserId'] ?? '',
      toUserId: map['toUserId'] ?? '',
      projectId: map['projectId'],
      type: RequestType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => RequestType.projectInvite,
      ),
      status: RequestStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => RequestStatus.pending,
      ),
      message: map['message'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      respondedAt: (map['respondedAt'] as Timestamp?)?.toDate(),
    );
  }

  MemberRequest copyWith({
    String? id,
    String? fromUserId,
    String? toUserId,
    String? projectId,
    RequestType? type,
    RequestStatus? status,
    String? message,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? respondedAt,
  }) {
    return MemberRequest(
      id: id ?? this.id,
      fromUserId: fromUserId ?? this.fromUserId,
      toUserId: toUserId ?? this.toUserId,
      projectId: projectId ?? this.projectId,
      type: type ?? this.type,
      status: status ?? this.status,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }

  bool get isPending => status == RequestStatus.pending;
  bool get isAccepted => status == RequestStatus.accepted;
  bool get isDeclined => status == RequestStatus.declined;
  bool get isCancelled => status == RequestStatus.cancelled;
}
