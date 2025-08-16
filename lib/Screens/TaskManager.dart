import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../Services/task_service.dart';
import '../Services/auth_service.dart';
import '../models/task.dart';
import './Profile.dart';

class TaskManager extends StatefulWidget {
  final String? selectedProjectId;
  final String? selectedProjectName;

  const TaskManager({
    super.key,
    this.selectedProjectId,
    this.selectedProjectName,
  });

  @override
  State<TaskManager> createState() => _TaskManagerState();
}

class _TaskManagerState extends State<TaskManager> {
  bool _showProjectTasks = true;
  String _searchQuery = '';
  
  Stream<List<Task>>? _tasksStream;
  String? _currentUserId;
  List<Task> _filteredTasks = [];
  List<Task> _projectTasks = [];
  List<Task> _myTasks = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _initializeStreams();
  }

  void _loadCurrentUser() {
    final user = AuthService.currentUser;
    if (user != null) {
      _currentUserId = user.uid;
    }
  }

  void _initializeStreams() {
    if (widget.selectedProjectId != null) {
      _tasksStream = TaskService.getTasksByProject(widget.selectedProjectId!);
      _showProjectTasks = true;
    } else {
      _tasksStream = TaskService.getAllTasks();
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filteredTasks = _showProjectTasks 
          ? _projectTasks.where((task) =>
              task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              task.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              task.status.toLowerCase().contains(_searchQuery.toLowerCase())).toList()
          : _myTasks.where((task) =>
              task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              task.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              task.status.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    });
  }

  void _toggleTaskView() {
    setState(() {
      _showProjectTasks = !_showProjectTasks;
      _filteredTasks = _showProjectTasks ? _projectTasks : _myTasks;
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppTheme.completedColor;
      case 'in_progress':
        return AppTheme.inProgressColor;
      case 'pending':
      default:
        return AppTheme.todoColor;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppTheme.highPriority;
      case 'medium':
        return AppTheme.mediumPriority;
      case 'low':
        return AppTheme.lowPriority;
      default:
        return AppTheme.mediumPriority;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final titleController = TextEditingController();
        final descriptionController = TextEditingController();
        String selectedPriority = 'medium';
        DateTime selectedDate = DateTime.now().add(const Duration(days: 1));

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New Task'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Task Title',
                        hintText: 'Enter task title',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Enter task description',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedPriority,
                      decoration: const InputDecoration(labelText: 'Priority'),
                      items: ['low', 'medium', 'high'].map((priority) {
                        return DropdownMenuItem(
                          value: priority,
                          child: Text(priority.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedPriority = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: Text('Due Date: ${_formatDate(selectedDate)}'),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.trim().isNotEmpty) {
                      final newTask = Task(
                        title: titleController.text.trim(),
                        description: descriptionController.text.trim(),
                        priority: selectedPriority,
                        status: 'pending',
                        dueDate: selectedDate,
                        createdAt: DateTime.now(),
                        projectId: widget.selectedProjectId,
                        assignedTo: AuthService.currentUserId,
                      );

                      try {
                        await TaskService.createTask(newTask);
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Task created successfully!'),
                            backgroundColor: AppTheme.success,
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error creating task: $e'),
                            backgroundColor: AppTheme.error,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Create Task'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _startNewChat() {
    Navigator.pushNamed(context, '/chat_list');
  }

  void _showChatbot() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.smart_toy, color: AppTheme.info),
              const SizedBox(width: 8),
              const Text('AI Assistant'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Hello! I\'m your AI assistant. How can I help you with your tasks today?'),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showAddTaskDialog();
                  },
                  icon: const Icon(Icons.add_task, size: 16),
                  label: const Text('Create Task'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: AppTheme.textWhite,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _startNewChat();
                  },
                  icon: const Icon(Icons.chat, size: 16),
                  label: const Text('Start Chat'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.success,
                    foregroundColor: AppTheme.textWhite,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.selectedProjectName ?? 'Task Manager',
                            style: AppTheme.headingMedium,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const ProfileScreen()),
                              );
                            },
                            child: CircleAvatar(
                              backgroundColor: AppTheme.primaryBlue,
                              child: Icon(
                                Icons.person,
                                color: AppTheme.textWhite,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Action Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _showAddTaskDialog,
                          icon: const Icon(Icons.add_task, size: 20),
                          label: const Text('Add Task'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: AppTheme.textWhite,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Search Bar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search tasks...',
                      prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppTheme.textLight.withOpacity(0.3)),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Toggle Buttons
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (!_showProjectTasks) _toggleTaskView();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _showProjectTasks ? AppTheme.primaryBlue : AppTheme.backgroundLight,
                            foregroundColor: _showProjectTasks ? AppTheme.textWhite : AppTheme.textSecondary,
                          ),
                          child: const Text('Project Tasks'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_showProjectTasks) _toggleTaskView();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: !_showProjectTasks ? AppTheme.primaryBlue : AppTheme.backgroundLight,
                            foregroundColor: !_showProjectTasks ? AppTheme.textWhite : AppTheme.textSecondary,
                          ),
                          child: const Text('My Tasks'),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Tasks List
                Expanded(
                  child: StreamBuilder<List<Task>>(
                    stream: _tasksStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: AppTheme.primaryBlue),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error, size: 64, color: AppTheme.textLight),
                              const SizedBox(height: 16),
                              Text('Error loading tasks', style: AppTheme.bodyLarge),
                              const SizedBox(height: 8),
                              Text(snapshot.error.toString(), style: AppTheme.bodySmall),
                            ],
                          ),
                        );
                      }

                      final tasks = snapshot.data ?? [];

                      // Filter tasks based on current user and project
                      final currentUser = AuthService.currentUserId;
                      _projectTasks = widget.selectedProjectId != null
                          ? tasks.where((task) => task.projectId == widget.selectedProjectId).toList()
                          : tasks;
                      _myTasks = tasks.where((task) => task.assignedTo == currentUser).toList();

                      // Set filtered tasks based on current view
                      if (_searchQuery.isEmpty) {
                        _filteredTasks = _showProjectTasks ? _projectTasks : _myTasks;
                      }

                      if (_filteredTasks.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.task, size: 64, color: AppTheme.textLight),
                              const SizedBox(height: 16),
                              Text(
                                _showProjectTasks ? 'No project tasks found' : 'No assigned tasks found',
                                style: AppTheme.bodyLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tasks will appear here when created',
                                style: AppTheme.bodySmall,
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredTasks.length,
                        itemBuilder: (context, index) {
                          final task = _filteredTasks[index];
                          return _buildTaskCard(task);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildTaskCard(Task task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status indicator and priority
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getStatusColor(task.status),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    task.title,
                    style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(task.priority).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    task.priority.toUpperCase(),
                    style: AppTheme.bodySmall.copyWith(
                      color: _getPriorityColor(task.priority),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Description
            Text(
              task.description,
              style: AppTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // Footer with due date and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(task.dueDate),
                      style: AppTheme.bodySmall,
                    ),
                  ],
                ),
                if (task.assignedTo != null) ...[
                  Row(
                    children: [
                      Icon(Icons.person, size: 16, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        'Assigned',
                        style: AppTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(task.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    task.status.replaceAll('_', ' ').toUpperCase(),
                    style: AppTheme.bodySmall.copyWith(
                      color: _getStatusColor(task.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
