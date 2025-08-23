import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskPriority { low, medium, high, urgent }
enum TaskStatus { todo, inProgress, review, completed, cancelled }

class Task {
  final String? id;
  final String title;
  final String description;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? assignedTo;
  final String? projectId;
  final String createdBy; // User who created the task
  final List<String> tags;
  final String? color; // For UI customization
  final DateTime? completedAt;

  Task({
    this.id,
    required this.title,
    required this.description,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.todo,
    required this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    this.assignedTo,
    this.projectId,
    required this.createdBy,
    this.tags = const [],
    this.color,
    this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'priority': priority.name,
      'status': status.name,
      'dueDate': Timestamp.fromDate(dueDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'assignedTo': assignedTo,
      'projectId': projectId,
      'createdBy': createdBy,
      'tags': tags,
      'color': color,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  static Task fromMap(Map<String, dynamic> map, String id) {
    return Task(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == map['priority'],
        orElse: () => TaskPriority.medium,
      ),
      status: TaskStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => TaskStatus.todo,
      ),
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      assignedTo: map['assignedTo'],
      projectId: map['projectId'],
      createdBy: map['createdBy'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      color: map['color'],
      completedAt: (map['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? assignedTo,
    String? projectId,
    String? createdBy,
    List<String>? tags,
    String? color,
    DateTime? completedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      assignedTo: assignedTo ?? this.assignedTo,
      projectId: projectId ?? this.projectId,
      createdBy: createdBy ?? this.createdBy,
      tags: tags ?? this.tags,
      color: color ?? this.color,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  bool get isOverdue {
    return DateTime.now().isAfter(dueDate) && status != TaskStatus.completed;
  }

  bool get isCompleted => status == TaskStatus.completed;

  bool isAssignedTo(String userId) => assignedTo == userId;
  
  bool isCreatedBy(String userId) => createdBy == userId;
}
