import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../Services/task_service.dart';
import '../Services/project_service.dart';
import '../Services/auth_service.dart';
import '../models/task.dart';
import '../models/project.dart';
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
  Stream<List<Project>>? _projectsStream;
  String? _currentUserId;

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
    
    _projectsStream = ProjectService.getAllProjects();
  }

  void _switchToProjectTasks() {
    setState(() {
      _showProjectTasks = true;
      if (widget.selectedProjectId != null) {
        _tasksStream = TaskService.getTasksByProject(widget.selectedProjectId!);
      } else {
        _tasksStream = TaskService.getAllTasks();
      }
    });
  }

  void _switchToMyTasks() {
    setState(() {
      _showProjectTasks = false;
      // Get all tasks and filter by current user in the UI
      _tasksStream = TaskService.getAllTasks();
    });
  }

  List<Task> _filterTasks(List<Task> tasks) {
    List<Task> filtered = tasks;
    
    // Filter by current user for "My Tasks" tab
    if (!_showProjectTasks && _currentUserId != null) {
      filtered = filtered.where((task) => task.assignedTo == _currentUserId).toList();
    }
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((task) {
        return task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               task.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               task.status.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               task.priority.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: Text(
          widget.selectedProjectName ?? 'Task Manager',
          style: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: AppTheme.textWhite,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          
          // Tab Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _switchToProjectTasks,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _showProjectTasks 
                        ? AppTheme.primaryBlue 
                        : AppTheme.backgroundGray,
                      foregroundColor: _showProjectTasks 
                        ? AppTheme.textWhite 
                        : AppTheme.textSecondary,
                    ),
                    child: const Text('Project Tasks'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _switchToMyTasks,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !_showProjectTasks 
                        ? AppTheme.primaryBlue 
                        : AppTheme.backgroundGray,
                      foregroundColor: !_showProjectTasks 
                        ? AppTheme.textWhite 
                        : AppTheme.textSecondary,
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
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryBlue,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppTheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading tasks',
                          style: AppTheme.headingMedium.copyWith(
                            color: AppTheme.error,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          style: AppTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.task_alt,
                          size: 64,
                          color: AppTheme.textLight,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _showProjectTasks ? 'No project tasks found' : 'No personal tasks found',
                          style: AppTheme.headingMedium.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create your first task to get started',
                          style: AppTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Navigate to add task screen
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add Task'),
                        ),
                      ],
                    ),
                  );
                }

                List<Task> filteredTasks = _filterTasks(snapshot.data!);

                if (filteredTasks.isEmpty && _searchQuery.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppTheme.textLight,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tasks found for "$_searchQuery"',
                          style: AppTheme.headingMedium.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search terms',
                          style: AppTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = filteredTasks[index];
                    return _buildTaskCard(task);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add task screen
          _showAddTaskDialog();
        },
        backgroundColor: AppTheme.primaryBlue,
        child: const Icon(Icons.add, color: AppTheme.textWhite),
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: AppTheme.headingSmall,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.getPriorityColor(task.priority).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    task.priority.toUpperCase(),
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.getPriorityColor(task.priority),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                task.description,
                style: AppTheme.bodyMedium,
              ),
            ],
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.getStatusColor(task.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    task.status.toUpperCase(),
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.getStatusColor(task.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                
                const Spacer(),
                
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppTheme.textLight,
                ),
                const SizedBox(width: 4),
                Text(
                  '${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
                  style: AppTheme.bodySmall,
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _updateTaskStatus(task, 'completed'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.success,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: const Size(0, 32),
                  ),
                  child: const Text(
                    'Complete',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                TextButton(
                  onPressed: () => _showEditTaskDialog(task),
                  child: const Text('Edit'),
                ),
                
                const Spacer(),
                
                IconButton(
                  onPressed: () => _deleteTask(task),
                  icon: const Icon(Icons.delete),
                  iconSize: 20,
                  color: AppTheme.error,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _updateTaskStatus(Task task, String newStatus) async {
    try {
      if (task.id != null) {
        await TaskService.updateTaskStatus(task.id!, newStatus);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task status updated to $newStatus'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating task: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  void _deleteTask(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && task.id != null) {
      try {
        await TaskService.deleteTask(task.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task deleted successfully'),
            backgroundColor: AppTheme.success,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting task: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Task'),
        content: const Text('Task creation form would go here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement task creation
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showEditTaskDialog(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Task'),
        content: const Text('Task editing form would go here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement task editing
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
