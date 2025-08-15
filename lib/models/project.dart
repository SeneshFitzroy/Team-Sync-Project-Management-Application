class Project {
  final String id;
  final String name;
  final DateTime startDate;
  final List<String> teamMembers;
  final double progress;
  final DateTime createdAt;
  final String createdBy;
  
  Project({
    required this.id,
    required this.name,
    required this.startDate,
    required this.teamMembers,
    this.progress = 0.0,
    required this.createdAt,
    required this.createdBy,
  });
  
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      startDate: DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
      teamMembers: List<String>.from(json['teamMembers'] ?? []),
      progress: (json['progress'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      createdBy: json['createdBy'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'startDate': startDate.toIso8601String(),
      'teamMembers': teamMembers,
      'progress': progress,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }
  
  Project copyWith({
    String? id,
    String? name,
    DateTime? startDate,
    List<String>? teamMembers,
    double? progress,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      teamMembers: teamMembers ?? this.teamMembers,
      progress: progress ?? this.progress,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
