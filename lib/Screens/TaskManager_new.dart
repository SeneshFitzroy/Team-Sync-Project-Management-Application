import 'package:flutter/material.dart';

class TaskManager extends StatefulWidget {
  final String? selectedProject;
  final Color? projectColor;
  final double? projectProgress;
  final String? projectMembers;
  final String? projectStatus;

  const TaskManager({
    super.key,
    this.selectedProject,
    this.projectColor,
    this.projectProgress,
    this.projectMembers,
    this.projectStatus,
  });

  @override
  State<TaskManager> createState() => _TaskManagerState();
}

class _TaskManagerState extends State<TaskManager> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

  // Sample tasks data
  final Map<TaskStatus, List<Task>> _tasks = {
    TaskStatus.todo: [
      Task(
        id: '1',
        title: 'Design System Update',
        description: 'Update the design system with new color palette and typography',
        priority: TaskPriority.high,
        assignee: 'Alice Johnson',
        dueDate: DateTime.now().add(const Duration(days: 3)),
        tags: ['Design', 'UI/UX'],
      ),
      Task(
        id: '2',
        title: 'Database Optimization',
        description: 'Optimize database queries for better performance',
        priority: TaskPriority.medium,
        assignee: 'Bob Smith',
        dueDate: DateTime.now().add(const Duration(days: 5)),
        tags: ['Backend', 'Performance'],
      ),
    ],
    TaskStatus.inProgress: [
      Task(
        id: '3',
        title: 'User Authentication Module',
        description: 'Implement user login and registration functionality',
        priority: TaskPriority.high,
        assignee: 'Charlie Brown',
        dueDate: DateTime.now().add(const Duration(days: 2)),
        tags: ['Frontend', 'Security'],
      ),
      Task(
        id: '4',
        title: 'API Documentation',
        description: 'Create comprehensive API documentation',
        priority: TaskPriority.low,
        assignee: 'Diana Prince',
        dueDate: DateTime.now().add(const Duration(days: 7)),
        tags: ['Documentation', 'API'],
      ),
    ],
    TaskStatus.review: [
      Task(
        id: '5',
        title: 'Mobile Responsive Design',
        description: 'Ensure all pages are mobile responsive',
        priority: TaskPriority.medium,
        assignee: 'Eve Adams',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        tags: ['Frontend', 'Mobile'],
      ),
    ],
    TaskStatus.done: [
      Task(
        id: '6',
        title: 'Project Setup',
        description: 'Initialize project structure and dependencies',
        priority: TaskPriority.high,
        assignee: 'Frank Miller',
        dueDate: DateTime.now().subtract(const Duration(days: 3)),
        tags: ['Setup', 'Configuration'],
      ),
      Task(
        id: '7',
        title: 'User Research',
        description: 'Conduct user interviews and surveys',
        priority: TaskPriority.medium,
        assignee: 'Grace Kelly',
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
        tags: ['Research', 'UX'],
      ),
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2D62ED), Color(0xFF1A365D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Header row
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          widget.selectedProject ?? 'Task Management',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.white, size: 28),
                        onPressed: () {
                          _showAddTaskDialog();
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Project stats
                  if (widget.selectedProject != null) ...[
                    Row(
                      children: [
                        Expanded(
                          child: _buildProjectStatCard(
                            'Progress',
                            '${((widget.projectProgress ?? 0) * 100).toInt()}%',
                            Icons.trending_up,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildProjectStatCard(
                            'Total Tasks',
                            _getTotalTaskCount().toString(),
                            Icons.assignment,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildProjectStatCard(
                            'Completed',
                            (_tasks[TaskStatus.done]?.length ?? 0).toString(),
                            Icons.check_circle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            
            // Tab bar
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Project Tasks'),
                  Tab(text: 'My Tasks'),
                ],
                labelColor: const Color(0xFF2D62ED),
                unselectedLabelColor: const Color(0xFF555555),
                indicatorColor: const Color(0xFF2D62ED),
                indicatorWeight: 3,
              ),
            ),
            
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildKanbanBoard(),
                  _buildMyTasks(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildKanbanBoard() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: TaskStatus.values.map((status) {
            return Container(
              width: 280,
              margin: const EdgeInsets.only(right: 16),
              child: _buildKanbanColumn(status),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildKanbanColumn(TaskStatus status) {
    final tasks = _tasks[status] ?? [];
    final statusInfo = _getStatusInfo(status);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Column header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusInfo.color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(statusInfo.icon, color: statusInfo.color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    statusInfo.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: statusInfo.color,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusInfo.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tasks.length.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Tasks list
          Expanded(
            child: tasks.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No tasks',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      return _buildTaskCard(tasks[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Draggable<Task>(
        data: task,
        feedback: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 250,
            child: _buildTaskCardContent(task),
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.5,
          child: _buildTaskCardContent(task),
        ),
        child: _buildTaskCardContent(task),
      ),
    );
  }

  Widget _buildTaskCardContent(Task task) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Priority indicator and title
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: _getPriorityColor(task.priority),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF000000),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Description
          Text(
            task.description,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF555555),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 12),
          
          // Tags
          if (task.tags.isNotEmpty) ...[
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: task.tags.take(2).map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D62ED).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF2D62ED),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],
          
          // Assignee and due date
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: const Color(0xFF2D62ED),
                child: Text(
                  task.assignee.split(' ').map((e) => e[0]).join(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  task.assignee,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF555555),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${task.dueDate.day}/${task.dueDate.month}',
                style: TextStyle(
                  fontSize: 11,
                  color: task.dueDate.isBefore(DateTime.now()) 
                      ? Colors.red 
                      : const Color(0xFF555555),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMyTasks() {
    final allTasks = _tasks.values.expand((taskList) => taskList).toList();
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Filter buttons
          Row(
            children: [
              _buildFilterChip('All', true),
              const SizedBox(width: 8),
              _buildFilterChip('Assigned to me', false),
              const SizedBox(width: 8),
              _buildFilterChip('Due today', false),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Tasks list
          Expanded(
            child: ListView.builder(
              itemCount: allTasks.length,
              itemBuilder: (context, index) {
                final task = allTasks[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _getTaskStatus(task) == TaskStatus.done,
                        onChanged: (value) {
                          // Handle task completion
                          setState(() {
                            _moveTask(task, TaskStatus.done);
                          });
                        },
                        activeColor: const Color(0xFF2D62ED),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF000000),
                                decoration: _getTaskStatus(task) == TaskStatus.done
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              task.description,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF555555),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getPriorityColor(task.priority).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _getPriorityText(task.priority),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _getPriorityColor(task.priority),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Due: ${task.dueDate.day}/${task.dueDate.month}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: task.dueDate.isBefore(DateTime.now()) 
                                        ? Colors.red 
                                        : const Color(0xFF555555),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF2D62ED) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? const Color(0xFF2D62ED) : Colors.grey[300]!,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF555555),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Task'),
        content: const Text('Task creation feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  int _getTotalTaskCount() {
    return _tasks.values.fold(0, (sum, tasks) => sum + tasks.length);
  }

  TaskStatus _getTaskStatus(Task task) {
    for (final entry in _tasks.entries) {
      if (entry.value.contains(task)) {
        return entry.key;
      }
    }
    return TaskStatus.todo;
  }

  void _moveTask(Task task, TaskStatus newStatus) {
    final currentStatus = _getTaskStatus(task);
    if (currentStatus != newStatus) {
      _tasks[currentStatus]?.remove(task);
      _tasks[newStatus]?.add(task);
    }
  }

  StatusInfo _getStatusInfo(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return StatusInfo(
          title: 'To Do',
          icon: Icons.inbox,
          color: const Color(0xFF555555),
        );
      case TaskStatus.inProgress:
        return StatusInfo(
          title: 'In Progress',
          icon: Icons.play_circle,
          color: const Color(0xFF1ED760),
        );
      case TaskStatus.review:
        return StatusInfo(
          title: 'Review',
          icon: Icons.rate_review,
          color: const Color(0xFFFF7A00),
        );
      case TaskStatus.done:
        return StatusInfo(
          title: 'Done',
          icon: Icons.check_circle,
          color: const Color(0xFF2D62ED),
        );
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return const Color(0xFF1ED760);
      case TaskPriority.medium:
        return const Color(0xFFFF7A00);
      case TaskPriority.high:
        return const Color(0xFFFF4757);
    }
  }

  String _getPriorityText(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }
}

enum TaskStatus { todo, inProgress, review, done }
enum TaskPriority { low, medium, high }

class Task {
  final String id;
  final String title;
  final String description;
  final TaskPriority priority;
  final String assignee;
  final DateTime dueDate;
  final List<String> tags;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.assignee,
    required this.dueDate,
    required this.tags,
  });
}

class StatusInfo {
  final String title;
  final IconData icon;
  final Color color;

  StatusInfo({
    required this.title,
    required this.icon,
    required this.color,
  });
}
