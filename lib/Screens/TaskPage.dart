import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';
import '../blocs/task_bloc.dart';
import '../blocs/project_bloc.dart';
import '../Services/firebase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_date_picker.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _particleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _particleAnimation;
  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'Todo', 'In Progress', 'Completed'];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadData();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _particleController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_particleController);

    _fadeController.forward();
    _slideController.forward();
    _particleController.repeat();
  }

  void _loadData() {
    print('🔄 Loading tasks and projects...');
    context.read<TaskBloc>().add(LoadTasks());
    context.read<ProjectBloc>().add(LoadProjects());
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: AppBar(
        title: Text(
          'Tasks',
          style: AppTheme.headingMedium.copyWith(color: AppTheme.textWhite),
        ),
        backgroundColor: AppTheme.primaryBlue,
        elevation: 0,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: _showAddTaskDialog,
              icon: Icon(Icons.add, size: 16),
              label: Text('Add Task'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.backgroundWhite,
                foregroundColor: AppTheme.primaryBlue,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryBlue.withOpacity(0.1),
              AppTheme.backgroundGray,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated particle background
            AnimatedBuilder(
              animation: _particleAnimation,
              child: Container(),
              builder: (context, child) {
                return CustomPaint(
                  painter: ParticlePainter(_particleAnimation.value),
                  size: Size.infinite,
                );
              },
            ),
            
            // Main content
            FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // Filter tabs with slide animation
                  SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      height: 80,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _filterOptions.length,
                        itemBuilder: (context, index) {
                          final filter = _filterOptions[index];
                          final isSelected = _selectedFilter == filter;
                          
                          return Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedFilter = filter;
                                });
                              },
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppTheme.primaryBlue : AppTheme.backgroundWhite,
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isSelected 
                                          ? AppTheme.primaryBlue.withOpacity(0.3)
                                          : AppTheme.backgroundGray.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  filter,
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: isSelected ? AppTheme.textWhite : AppTheme.textPrimary,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  
                  // Task list
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        _loadData();
                      },
                      color: AppTheme.backgroundWhite,
                      backgroundColor: AppTheme.primaryBlue,
                      child: BlocBuilder<TaskBloc, TaskState>(
                        builder: (context, state) {
                          if (state is TaskLoading) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Loading tasks...',
                                    style: AppTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            );
                          }

                          if (state is TasksLoaded) {
                            final filteredTasks = _getFilteredTasks(state.filteredTasks);
                            print('📋 TasksLoaded state: ${state.tasks.length} total tasks');
                            print('🔍 Filtered tasks (${_selectedFilter}): ${filteredTasks.length}');
                            print('📝 Task titles: ${filteredTasks.map((t) => t.title).toList()}');

                            if (filteredTasks.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.task_alt,
                                      size: 64,
                                      color: AppTheme.textLight,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      _selectedFilter == 'All' 
                                          ? 'No tasks yet'
                                          : 'No $_selectedFilter tasks',
                                      style: AppTheme.headingSmall.copyWith(color: AppTheme.textSecondary),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Tap the + button to create your first task',
                                      style: AppTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              );
                            }

                            return ListView.builder(
                              padding: EdgeInsets.all(20),
                              itemCount: filteredTasks.length,
                              itemBuilder: (context, index) {
                                final task = filteredTasks[index];
                                return SlideTransition(
                                  position: _slideAnimation,
                                  child: _TaskCard(
                                    task: task,
                                    onTap: () => _showTaskDetails(task),
                                    onStatusTap: () => _showUpdateStatusDialog(context, task),
                                  ),
                                );
                              },
                            );
                          }

                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: AppTheme.textLight,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Something went wrong',
                                  style: AppTheme.headingSmall.copyWith(color: AppTheme.textSecondary),
                                ),
                                SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: _loadData,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryBlue,
                                    foregroundColor: AppTheme.textWhite,
                                  ),
                                  child: Text('Try again'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Task> _getFilteredTasks(List<Task> tasks) {
    switch (_selectedFilter) {
      case 'Todo':
        return tasks.where((task) => task.status == TaskStatus.todo).toList();
      case 'In Progress':
        return tasks.where((task) => task.status == TaskStatus.inProgress).toList();
      case 'Completed':
        return tasks.where((task) => task.status == TaskStatus.completed).toList();
      default:
        return tasks;
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return AppTheme.urgentPriority;
      case TaskPriority.high:
        return AppTheme.highPriority;
      case TaskPriority.medium:
        return AppTheme.mediumPriority;
      case TaskPriority.low:
        return AppTheme.lowPriority;
    }
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return AppTheme.todoColor;
      case TaskStatus.inProgress:
        return AppTheme.inProgressColor;
      case TaskStatus.completed:
        return AppTheme.completedColor;
      case TaskStatus.review:
        return AppTheme.primaryBlue;
      case TaskStatus.cancelled:
        return AppTheme.urgentPriority;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference == -1) {
      return 'Yesterday';
    } else if (difference > 0) {
      return 'In $difference days';
    } else {
      return '${difference.abs()} days ago';
    }
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddTaskDialog(),
    );
  }

  void _showTaskDetails(Task task) {
    showDialog(
      context: context,
      builder: (context) => _TaskDetailsDialog(task: task),
    );
  }

  void _showUpdateStatusDialog(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Task Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: TaskStatus.values.map((status) {
            return ListTile(
              title: Text(status.name.toUpperCase()),
              leading: CircleAvatar(
                backgroundColor: _getStatusColor(status),
                radius: 8,
              ),
              onTap: () {
                context.read<TaskBloc>().add(UpdateTaskStatus(
                  taskId: task.id!,
                  status: status,
                ));
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onStatusTap;

  const _TaskCard({
    required this.task,
    required this.onTap,
    required this.onStatusTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(16),
        shadowColor: AppTheme.primaryBlue.withOpacity(0.1),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppTheme.backgroundWhite,
              border: Border.all(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: AppTheme.headingSmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onStatusTap,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(task.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _getStatusColor(task.status).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          task.status.name.toUpperCase(),
                          style: AppTheme.bodySmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(task.status),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (task.description.isNotEmpty) ...[
                  SizedBox(height: 12),
                  Text(
                    task.description,
                    style: AppTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(task.priority).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getPriorityColor(task.priority).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.flag,
                            size: 12,
                            color: _getPriorityColor(task.priority),
                          ),
                          SizedBox(width: 4),
                          Text(
                            task.priority.name.toUpperCase(),
                            style: AppTheme.bodySmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _getPriorityColor(task.priority),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: AppTheme.textSecondary,
                        ),
                        SizedBox(width: 6),
                        Text(
                          _formatDate(task.dueDate),
                          style: AppTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return Colors.deepPurple;
      case TaskPriority.high:
        return AppTheme.urgentPriority;
      case TaskPriority.medium:
        return AppTheme.todoColor;
      case TaskPriority.low:
        return AppTheme.completedColor;
    }
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return AppTheme.todoColor;
      case TaskStatus.inProgress:
        return AppTheme.inProgressColor;
      case TaskStatus.completed:
        return AppTheme.completedColor;
      case TaskStatus.review:
        return AppTheme.primaryBlue;
      case TaskStatus.cancelled:
        return AppTheme.urgentPriority;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference == -1) {
      return 'Yesterday';
    } else if (difference > 0) {
      return 'In $difference days';
    } else {
      return '${difference.abs()} days ago';
    }
  }
}

class _AddTaskDialog extends StatefulWidget {
  @override
  State<_AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<_AddTaskDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  TaskPriority _selectedPriority = TaskPriority.medium;
  DateTime _selectedDate = DateTime.now().add(Duration(days: 1));
  String? _selectedProjectId;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createTask() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a task title')),
      );
      return;
    }

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      print('🔄 Creating task with date: $_selectedDate');
      print('🔄 User ID: $userId');

      final task = Task(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        assignedTo: userId, // Assign to self so it shows up
        projectId: _selectedProjectId,
        priority: _selectedPriority,
        status: TaskStatus.todo,
        dueDate: _selectedDate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: userId,
      );

      print('🔄 Task object created: ${task.toMap()}');
      
      final taskId = await FirebaseService.createTask(task);
      print('✅ Task created with ID: $taskId');
      
      // Close dialog first
      Navigator.pop(context);
      
      // Reload tasks using BLoC
      context.read<TaskBloc>().add(LoadTasks());
      print('🔄 LoadTasks event dispatched');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task created successfully!'),
          backgroundColor: AppTheme.completedColor,
        ),
      );
    } catch (e) {
      print('❌ Error creating task: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating task: $e'),
          backgroundColor: AppTheme.urgentPriority,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add New Task'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Task Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<TaskPriority>(
              value: _selectedPriority,
              decoration: InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              items: TaskPriority.values.map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Text(priority.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPriority = value!;
                });
              },
            ),
            SizedBox(height: 16),
            // Custom Date Picker with better web compatibility  
            SimpleDatePicker(
              selectedDate: _selectedDate,
              onDateChanged: (DateTime date) {
                print('📅 Date selected via custom picker: $date');
                setState(() {
                  _selectedDate = date;
                });
              },
              labelText: 'Due Date',
            ),
            SizedBox(height: 16),
            BlocBuilder<ProjectBloc, ProjectState>(
              builder: (context, state) {
                if (state is ProjectsLoaded) {
                  return DropdownButtonFormField<String>(
                    value: _selectedProjectId,
                    decoration: InputDecoration(
                      labelText: 'Project (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem<String>(
                        value: null,
                        child: Text('No Project'),
                      ),
                      ...state.projects.map((project) {
                        return DropdownMenuItem(
                          value: project.id,
                          child: Text(project.name),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedProjectId = value;
                      });
                    },
                  );
                }
                return SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _createTask,
          child: Text('Create Task'),
        ),
      ],
    );
  }
}

class _TaskDetailsDialog extends StatelessWidget {
  final Task task;

  const _TaskDetailsDialog({required this.task});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(task.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty) ...[
              Text(
                'Description:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(task.description),
              SizedBox(height: 16),
            ],
            Text(
              'Priority:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getPriorityColor(task.priority).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                task.priority.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _getPriorityColor(task.priority),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Status:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(task.status).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                task.status.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(task.status),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Due Date:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(_formatDate(task.dueDate)),
            SizedBox(height: 16),
            Text(
              'Created:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(_formatDate(task.createdAt)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close'),
        ),
      ],
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return Colors.deepPurple;
      case TaskPriority.high:
        return AppTheme.urgentPriority;
      case TaskPriority.medium:
        return AppTheme.todoColor;
      case TaskPriority.low:
        return AppTheme.completedColor;
    }
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return AppTheme.todoColor;
      case TaskStatus.inProgress:
        return AppTheme.inProgressColor;
      case TaskStatus.completed:
        return AppTheme.completedColor;
      case TaskStatus.review:
        return AppTheme.primaryBlue;
      case TaskStatus.cancelled:
        return AppTheme.urgentPriority;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference == -1) {
      return 'Yesterday';
    } else if (difference > 0) {
      return 'In $difference days';
    } else {
      return '${difference.abs()} days ago';
    }
  }
}
  
// Particle Painter for background animation  
class ParticlePainter extends CustomPainter {  
  final double animationValue;  
  
  ParticlePainter(this.animationValue);  
  
  @override  
  void paint(Canvas canvas, Size size) {  
    final paint = Paint()  
      ..color = AppTheme.primaryBlue.withOpacity(0.1)  
      ..style = PaintingStyle.fill;  
  
    for (int i = 0; i < 50; i++) {  
      final x = (i * 50 + animationValue * 100) % size.width;  
      final y = (i * 30 + animationValue * 50) % size.height;  
      canvas.drawCircle(Offset(x, y), 2, paint);  
    }  
  }  
  
  @override  
  bool shouldRepaint(CustomPainter oldDelegate) => true;  
} 
