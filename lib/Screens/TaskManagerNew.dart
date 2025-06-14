import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../Components/nav_bar.dart';
import '../Services/firebase_service.dart';
import 'Profile.dart';

// Enhanced Task model with Firebase ID support
class Task {
  String? id;
  String projectName;
  String taskName;
  String status;
  String dueDate;
  String priority;
  Color priorityColor;
  String assignee;
  Color statusColor;
  String? category;

  Task({
    this.id,
    required this.projectName,
    required this.taskName,
    required this.status,
    required this.dueDate,
    required this.priority,
    required this.priorityColor,
    required this.assignee,
    required this.statusColor,
    this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'projectName': projectName,
      'taskName': taskName,
      'status': status,
      'dueDate': dueDate,
      'priority': priority,
      'assignee': assignee,
      'category': category,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static Task fromMap(Map<String, dynamic> map, String id) {
    return Task(
      id: id,
      projectName: map['projectName'] ?? '',
      taskName: map['taskName'] ?? '',
      status: map['status'] ?? 'To Do',
      dueDate: map['dueDate'] ?? '',
      priority: map['priority'] ?? 'Medium',
      priorityColor: _getPriorityColor(map['priority'] ?? 'Medium'),
      assignee: map['assignee'] ?? 'Me',
      statusColor: _getStatusColor(map['status'] ?? 'To Do'),
      category: map['category'],
    );
  }

  static Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return const Color(0xFFE53E3E);
      case 'medium':
        return const Color(0xFF187E0F);
      case 'low':
        return const Color(0xFF3182CE);
      default:
        return const Color(0xFF187E0F);
    }
  }

  static Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF38A169);
      case 'in progress':
        return const Color(0xFFD69E2E);
      case 'to do':
        return const Color(0xFF3182CE);
      default:
        return const Color(0xFF192F5D);
    }
  }
}

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

class _TaskManagerState extends State<TaskManager> {
  List<Task> _projectTasks = [];
  List<Task> _myTasks = [];
  List<Task> _filteredTasks = [];
  bool _showProjectTasks = false;
  String _searchQuery = "";
  bool _isLoading = true;
  int _currentIndex = 1;

  StreamSubscription<QuerySnapshot>? _tasksSubscription;
  StreamSubscription<QuerySnapshot>? _myTasksSubscription;

  @override
  void initState() {
    super.initState();
    _setupFirebaseListeners();
    _initializeWithProject();
  }

  @override
  void dispose() {
    _tasksSubscription?.cancel();
    _myTasksSubscription?.cancel();
    super.dispose();
  }

  void _setupFirebaseListeners() {
    setState(() {
      _isLoading = true;
    });
    
    _tasksSubscription = FirebaseService.getUserTasks().listen((snapshot) {
      setState(() {
        _projectTasks = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Task(
            id: doc.id,
            projectName: data['projectName'] ?? '',
            taskName: data['taskName'] ?? '',
            status: data['status'] ?? 'To Do',
            dueDate: data['dueDate'] ?? '',
            priority: data['priority'] ?? 'Medium',
            priorityColor: Task._getPriorityColor(data['priority'] ?? 'Medium'),
            assignee: data['assignee'] ?? 'Me',
            statusColor: Task._getStatusColor(data['status'] ?? 'To Do'),
          );
        }).where((task) => !_isPersonalTask(task)).toList();
        
        _filterTasks();
        _isLoading = false;
      });
    });

    _myTasksSubscription = FirebaseService.getUserTasks().listen((snapshot) {
      setState(() {
        _myTasks = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Task(
            id: doc.id,
            projectName: data['projectName'] ?? 'Personal',
            taskName: data['taskName'] ?? '',
            status: data['status'] ?? 'To Do',
            dueDate: data['dueDate'] ?? '',
            priority: data['priority'] ?? 'Medium',
            priorityColor: Task._getPriorityColor(data['priority'] ?? 'Medium'),
            assignee: data['assignee'] ?? 'Me',
            statusColor: Task._getStatusColor(data['status'] ?? 'To Do'),
            category: data['category'],
          );
        }).where((task) => _isPersonalTask(task)).toList();
        
        _filterTasks();
        _isLoading = false;
      });
    });
  }

  bool _isPersonalTask(Task task) {
    return task.projectName == 'Personal' || task.category != null;
  }

  void _initializeWithProject() {
    if (widget.selectedProject != null) {
      setState(() {
        _showProjectTasks = true;
      });
    }
  }

  void _filterTasks() {
    List<Task> sourceTasks = _showProjectTasks ? _projectTasks : _myTasks;
    
    if (_searchQuery.isEmpty) {
      _filteredTasks = sourceTasks;
    } else {
      _filteredTasks = sourceTasks.where((task) {
        return task.taskName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               task.projectName.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
  }

  void _onNavBarTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index != 1) {
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/dashboard');
          break;
        case 2:
          Navigator.pushReplacementNamed(context, '/chat');
          break;
        case 3:
          Navigator.pushReplacementNamed(context, '/calendar');
          break;
      }
    }
  }

  Future<void> _showAddTaskDialog() async {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    String selectedPriority = 'Medium';
    String selectedStatus = 'To Do';
    String selectedProject = _showProjectTasks ? (widget.selectedProject ?? 'General') : 'Personal';

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add New Task'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Task Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedPriority,
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                        border: OutlineInputBorder(),
                      ),
                      items: ['High', 'Medium', 'Low'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setDialogState(() {
                          selectedPriority = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      items: ['To Do', 'In Progress', 'Completed'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setDialogState(() {
                          selectedStatus = newValue!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.isNotEmpty) {
                      try {
                        final task = Task(
                          projectName: selectedProject,
                          taskName: titleController.text,
                          status: selectedStatus,
                          dueDate: DateTime.now().add(const Duration(days: 7)).toString().split(' ')[0],
                          priority: selectedPriority,
                          priorityColor: Task._getPriorityColor(selectedPriority),
                          assignee: 'Me',
                          statusColor: Task._getStatusColor(selectedStatus),
                          category: selectedProject == 'Personal' ? 'personal' : null,
                        );

                        await FirebaseService.createTask(task.toMap());
                        
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Task created successfully!')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error creating task: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTaskCard(Task task) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 40,
                  color: task.priorityColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.taskName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        task.projectName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: task.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    task.status,
                    style: TextStyle(
                      fontSize: 12,
                      color: task.statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  task.dueDate,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                Text(
                  task.priority,
                  style: TextStyle(
                    fontSize: 12,
                    color: task.priorityColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF192F5D),
        foregroundColor: Colors.white,
        title: Text(_showProjectTasks ? 'Project Tasks' : 'My Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Search functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab buttons
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _showProjectTasks = true;
                        _filterTasks();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _showProjectTasks ? const Color(0xFF192F5D) : Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        'Project Tasks',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _showProjectTasks ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _showProjectTasks = false;
                        _filterTasks();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !_showProjectTasks ? const Color(0xFF192F5D) : Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        'Personal Tasks',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: !_showProjectTasks ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Tasks list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.task_alt, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No tasks found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Create your first task using the + button',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredTasks.length,
                        itemBuilder: (context, index) {
                          return _buildTaskCard(_filteredTasks[index]);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        backgroundColor: const Color(0xFF192F5D),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: NavBar(
        selectedIndex: _currentIndex,
        onTap: _onNavBarTap,
      ),
    );
  }
}
