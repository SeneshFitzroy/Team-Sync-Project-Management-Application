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
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Add New Task',
                          style: TextStyle(
                            color: Color(0xFF192F5D),
                            fontSize: 24,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Color(0xFF192F5D)),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Content
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          // Task Title
                          TextField(
                            controller: titleController,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Task Title',
                              labelStyle: const TextStyle(
                                color: Color(0xFF192F5D),
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0x33192F5D)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF192F5D), width: 2),
                              ),
                              filled: true,
                              fillColor: const Color(0x0A192F5D),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Description
                          TextField(
                            controller: descriptionController,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Description',
                              labelStyle: const TextStyle(
                                color: Color(0xFF192F5D),
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0x33192F5D)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF192F5D), width: 2),
                              ),
                              filled: true,
                              fillColor: const Color(0x0A192F5D),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          
                          // Priority Dropdown
                          DropdownButtonFormField<String>(
                            value: selectedPriority,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Priority',
                              labelStyle: const TextStyle(
                                color: Color(0xFF192F5D),
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0x33192F5D)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF192F5D), width: 2),
                              ),
                              filled: true,
                              fillColor: const Color(0x0A192F5D),
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
                          
                          // Status Dropdown
                          DropdownButtonFormField<String>(
                            value: selectedStatus,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Status',
                              labelStyle: const TextStyle(
                                color: Color(0xFF192F5D),
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0x33192F5D)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF192F5D), width: 2),
                              ),
                              filled: true,
                              fillColor: const Color(0x0A192F5D),
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
                    
                    const SizedBox(height: 32),
                    
                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.grey,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
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
                                  SnackBar(
                                    content: const Text(
                                      'Task created successfully!',
                                      style: TextStyle(fontFamily: 'Inter'),
                                    ),
                                    backgroundColor: const Color(0xFF192F5D),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Error creating task: $e',
                                      style: const TextStyle(fontFamily: 'Inter'),
                                    ),
                                    backgroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF192F5D),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            'Create Task',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
    );
  }

  Widget _buildTaskCard(Task task) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: GestureDetector(
        onTap: () {
          // Handle task tap
        },
        child: Container(
          width: double.infinity,
          height: 165,
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            shadows: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Left accent bar
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 165,
                  decoration: ShapeDecoration(
                    color: task.priorityColor,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Task title
              Positioned(
                left: 24,
                top: 24,
                right: 24,
                child: Text(
                  task.taskName,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    height: 1.50,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              // Project name
              Positioned(
                left: 24,
                top: 59,
                child: Row(
                  children: [
                    const Icon(
                      Icons.folder_outlined,
                      size: 16,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      task.projectName,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Status and priority
              Positioned(
                right: 24,
                top: 24,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: task.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    task.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      color: task.statusColor,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              
              // Due date
              Positioned(
                left: 24,
                top: 101,
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Due: ${task.dueDate}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Priority indicator
              Positioned(
                right: 24,
                top: 101,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: task.priorityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    task.priority.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      color: task.priorityColor,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              
              // Assignee
              Positioned(
                left: 24,
                bottom: 24,
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF192F5D).withOpacity(0.1),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 12,
                        color: Color(0xFF192F5D),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      task.assignee,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(),
                    _buildTitle(),
                    _buildTabSection(),
                    _buildTasksList(),
                  ],
                ),
              ),
            ),
            NavBar(
              selectedIndex: _currentIndex,
              onTap: _onNavBarTap,
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 70),
        child: FloatingActionButton(
          onPressed: _showAddTaskDialog,
          backgroundColor: const Color(0xFF192F5D),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Container(
              height: 40,
              decoration: ShapeDecoration(
                color: const Color(0x11192F5D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: InkWell(
                onTap: () {
                  // Search functionality
                },
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Icon(Icons.search, color: Colors.grey[600], size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'Search tasks...',
                      style: TextStyle(
                        color: const Color(0xFF999999),
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Text(
                                'Profile Options',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF192F5D),
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.close, color: Color(0xFF192F5D)),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.person_outline, color: Color(0xFF192F5D)),
                          title: const Text(
                            'View Profile',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ProfileScreen()),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  );
                },
              );
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
              ),
              child: Icon(Icons.person, color: Colors.grey[700], size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _showProjectTasks ? 'Project Tasks' : 'My Tasks',
              style: const TextStyle(
                color: Color(0xFF192F5D),
                fontSize: 28,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              // Filter functionality
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0x11192F5D),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.filter_list, size: 16, color: const Color(0xFF192F5D).withOpacity(0.8)),
                  const SizedBox(width: 6),
                  const Text(
                    'Filters',
                    style: TextStyle(
                      color: Color(0xFF192F5D),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0x11192F5D),
        borderRadius: BorderRadius.circular(12),
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
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _showProjectTasks ? const Color(0xFF192F5D) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Project Tasks',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _showProjectTasks ? Colors.white : const Color(0xFF192F5D),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
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
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: !_showProjectTasks ? const Color(0xFF192F5D) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Personal Tasks',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: !_showProjectTasks ? Colors.white : const Color(0xFF192F5D),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(40.0),
        child: Center(child: CircularProgressIndicator(color: Color(0xFF192F5D))),
      );
    }

    if (_filteredTasks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0x11192F5D),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.task_alt,
                size: 40,
                color: Color(0xFF192F5D),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No tasks found',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: Color(0xFF192F5D),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first task using the + button',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Inter',
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: _filteredTasks.map((task) => _buildTaskCard(task)).toList(),
    );
  }
}
