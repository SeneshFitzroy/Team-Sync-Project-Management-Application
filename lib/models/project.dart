import 'package:cloud_firestore/cloud_firestore.dart';

enum ProjectStatus { planning, active, completed, paused, cancelled }

class Project {
  final String? id;
  final String name;
  final String description;
  final ProjectStatus status;
  final double progress;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? dueDate;
  final List<String> teamMembers;
  final List<String> pendingInviteIds; // Users with pending invitations
  final String? ownerId;
  final String? color; // For UI customization
  final int taskCount;
  final int completedTaskCount;

  Project({
    this.id,
    required this.name,
    required this.description,
    this.status = ProjectStatus.planning,
    required this.progress,
    required this.createdAt,
    required this.updatedAt,
    this.dueDate,
    required this.teamMembers,
    this.pendingInviteIds = const [],
    this.ownerId,
    this.color,
    this.taskCount = 0,
    this.completedTaskCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'status': status.name,
      'progress': progress,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'teamMembers': teamMembers,
      'pendingInviteIds': pendingInviteIds,
      'ownerId': ownerId,
      'color': color,
      'taskCount': taskCount,
      'completedTaskCount': completedTaskCount,
    };
  }

  static Project fromMap(Map<String, dynamic> map, String id) {
    return Project(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      status: ProjectStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ProjectStatus.planning,
      ),
      progress: (map['progress'] ?? 0.0).toDouble(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dueDate: map['dueDate'] != null ? (map['dueDate'] as Timestamp).toDate() : null,
      teamMembers: List<String>.from(map['teamMembers'] ?? []),
      pendingInviteIds: List<String>.from(map['pendingInviteIds'] ?? []),
      ownerId: map['ownerId'],
      color: map['color'],
      taskCount: map['taskCount'] ?? 0,
      completedTaskCount: map['completedTaskCount'] ?? 0,
    );
  }

  Project copyWith({
    String? id,
    String? name,
    String? description,
    ProjectStatus? status,
    double? progress,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dueDate,
    List<String>? teamMembers,
    List<String>? pendingInviteIds,
    String? ownerId,
    String? color,
    int? taskCount,
    int? completedTaskCount,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dueDate: dueDate ?? this.dueDate,
      teamMembers: teamMembers ?? this.teamMembers,
      pendingInviteIds: pendingInviteIds ?? this.pendingInviteIds,
      ownerId: ownerId ?? this.ownerId,
      color: color ?? this.color,
      taskCount: taskCount ?? this.taskCount,
      completedTaskCount: completedTaskCount ?? this.completedTaskCount,
    );
  }

  double get completionPercentage {
    if (taskCount == 0) return 0.0;
    return completedTaskCount / taskCount;
  }

  bool get isOverdue {
    if (dueDate == null) return false;
    return DateTime.now().isAfter(dueDate!) && status != ProjectStatus.completed;
  }

  bool isOwner(String userId) => ownerId == userId;
  
  bool isMember(String userId) => teamMembers.contains(userId) || ownerId == userId;
  
  bool hasPendingInvite(String userId) => pendingInviteIds.contains(userId);
}
