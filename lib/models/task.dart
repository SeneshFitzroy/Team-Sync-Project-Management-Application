import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String? id;
  final String title;
  final String description;
  final String priority;
  final String status;
  final DateTime dueDate;
  final DateTime createdAt;
  final String? assignedTo;
  final String? projectId;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.dueDate,
    required this.createdAt,
    this.assignedTo,
    this.projectId,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'priority': priority,
      'status': status,
      'dueDate': Timestamp.fromDate(dueDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'assignedTo': assignedTo,
      'projectId': projectId,
    };
  }

  static Task fromMap(Map<String, dynamic> map, String id) {
    return Task(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      priority: map['priority'] ?? 'medium',
      status: map['status'] ?? 'pending',
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      assignedTo: map['assignedTo'],
      projectId: map['projectId'],
    );
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? priority,
    String? status,
    DateTime? dueDate,
    DateTime? createdAt,
    String? assignedTo,
    String? projectId,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      assignedTo: assignedTo ?? this.assignedTo,
      projectId: projectId ?? this.projectId,
    );
  }
}
