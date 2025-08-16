import 'package:cloud_firestore/cloud_firestore.dart';

class Project {
  final String? id;
  final String name;
  final String description;
  final String status;
  final double progress;
  final DateTime createdAt;
  final DateTime? dueDate;
  final List<String> teamMembers;
  final String? ownerId;

  Project({
    this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.progress,
    required this.createdAt,
    this.dueDate,
    required this.teamMembers,
    this.ownerId,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'status': status,
      'progress': progress,
      'createdAt': Timestamp.fromDate(createdAt),
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'teamMembers': teamMembers,
      'ownerId': ownerId,
    };
  }

  static Project fromMap(Map<String, dynamic> map, String id) {
    return Project(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? 'active',
      progress: (map['progress'] ?? 0.0).toDouble(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      dueDate: map['dueDate'] != null ? (map['dueDate'] as Timestamp).toDate() : null,
      teamMembers: List<String>.from(map['teamMembers'] ?? []),
      ownerId: map['ownerId'],
    );
  }

  Project copyWith({
    String? id,
    String? name,
    String? description,
    String? status,
    double? progress,
    DateTime? createdAt,
    DateTime? dueDate,
    List<String>? teamMembers,
    String? ownerId,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      teamMembers: teamMembers ?? this.teamMembers,
      ownerId: ownerId ?? this.ownerId,
    );
  }
}
