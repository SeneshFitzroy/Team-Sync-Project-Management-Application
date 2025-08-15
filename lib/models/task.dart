class Task {
  final String id;
  final String title;
  final String description;
  final String projectId;
  final String assigneeId;
  final String assigneeName;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime dueDate;
  final DateTime createdAt;
  final String createdBy;
  
  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.projectId,
    required this.assigneeId,
    required this.assigneeName,
    required this.status,
    required this.priority,
    required this.dueDate,
    required this.createdAt,
    required this.createdBy,
  });
  
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      projectId: json['projectId'] ?? '',
      assigneeId: json['assigneeId'] ?? '',
      assigneeName: json['assigneeName'] ?? '',
      status: TaskStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => TaskStatus.toDo,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.toString() == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      dueDate: DateTime.parse(json['dueDate'] ?? DateTime.now().toIso8601String()),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      createdBy: json['createdBy'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'projectId': projectId,
      'assigneeId': assigneeId,
      'assigneeName': assigneeName,
      'status': status.toString(),
      'priority': priority.toString(),
      'dueDate': dueDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }
  
  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? projectId,
    String? assigneeId,
    String? assigneeName,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? dueDate,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      projectId: projectId ?? this.projectId,
      assigneeId: assigneeId ?? this.assigneeId,
      assigneeName: assigneeName ?? this.assigneeName,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}

enum TaskStatus {
  toDo,
  inProgress,
  codeReview,
  done,
}

enum TaskPriority {
  low,
  medium,
  high,
  urgent,
}

extension TaskStatusExtension on TaskStatus {
  String get displayName {
    switch (this) {
      case TaskStatus.toDo:
        return 'To Do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.codeReview:
        return 'Code Review';
      case TaskStatus.done:
        return 'Done';
    }
  }
}

extension TaskPriorityExtension on TaskPriority {
  String get displayName {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.urgent:
        return 'Urgent';
    }
  }
}
