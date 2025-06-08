import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../Components/nav_bar.dart';
import '../Services/firebase_service.dart';
// Import other screens that we'll navigate to
import './Dashboard.dart';
import './Chat.dart';
import './Calendar.dart';
import './Profile.dart';

// Enhanced Task model with Firebase ID support
class Task {
  String? id; // Firebase document ID
  String projectName;
  String taskName;
  String status;
  String dueDate;
  String priority;
  Color priorityColor;
  String assignee;
  Color statusColor;
  String? category; // For personal tasks

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

  // Convert Task to Map for Firebase
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

  // Create Task from Firebase document
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
  // Add parameters to receive project data from Dashboard
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
  bool _showProjectTasks = true;
  int _currentIndex = 1; // Set to 1 for Tasks tab
  String _searchQuery = ''; // For search functionality

  List<Task> _projectTasks = [];
  List<Task> _myTasks = [];
  List<Task> _filteredTasks = []; // Filtered tasks based on search
  
  StreamSubscription<QuerySnapshot>? _tasksSubscription;
  StreamSubscription<QuerySnapshot>? _myTasksSubscription;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeTasks();
    _loadFirebaseTasks();
  }

  void _initializeTasks() {
    // Initialize with empty lists
    _projectTasks = [];
    _myTasks = [];
    _filteredTasks = [];
  }

  void _loadFirebaseTasks() {
    try {
      // Listen to user's tasks stream
      _myTasksSubscription = FirebaseService.getUserTasks().listen(
        (snapshot) {
          if (mounted) {
            setState(() {
              _myTasks = snapshot.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return Task(
                  id: doc.id, // Store Firebase document ID
                  projectName: data['projectName'] ?? 'Unknown Project',
                  taskName: data['title'] ?? data['taskName'] ?? 'Untitled Task',
                  status: data['status'] ?? 'Not Started',
                  dueDate: _formatDate(data['dueDate']),
                  priority: data['priority'] ?? 'Medium',
                  priorityColor: _getPriorityColor(data['priority'] ?? 'Medium'),
                  assignee: data['assigneeEmail'] ?? 'Unassigned',                  statusColor: _getStatusColor(data['status'] ?? 'Not Started'),
                );
              }).toList();
              _isLoading = false;
              _filterTasks();
            });
          }
        },
        onError: (error) {
          print('Error loading tasks: $error');
          _loadSampleTasks();
        },
      );
    } catch (e) {
      print('Error setting up tasks listener: $e');
      _loadSampleTasks();
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return DateTime.now().toString().split(' ')[0];
    if (date is Timestamp) {
      return date.toDate().toString().split(' ')[0];
    }
    return date.toString();
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return const Color(0xFFD14318);
      case 'medium':
        return const Color(0xFF187E0F);
      case 'low':
        return const Color(0xFF192F5D);
      default:
        return const Color(0xFF187E0F);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF187E0F);
      case 'in progress':
        return const Color(0xFF187E0F);
      case 'pending':
        return const Color(0xFFD14318);
      case 'not started':
        return const Color(0xFFCCCCCC);
      default:
        return const Color(0xFF187E0F);
    }
  }

  void _loadSampleTasks() {
    setState(() {
      // Initialize task lists with sample data as fallback
      _projectTasks = [
        Task(
          projectName: 'Website Redesign',
          taskName: 'Design System Update',
          status: 'In Progress',
          dueDate: '2024-02-15',
          priority: 'High',
          priorityColor: const Color(0xFFD14318),
          assignee: 'Sarah Chen',
          statusColor: const Color(0xFF187E0F),
        ),
        Task(
          projectName: 'Mobile App v2.0',
          taskName: 'API Integration',
          status: 'Pending',
          dueDate: '2024-02-20',
          priority: 'Medium',
          priorityColor: const Color(0xFF187E0F),
          assignee: 'Mike Ross',
          statusColor: const Color(0xFFD14318),
        ),
      ];

      _myTasks = [
        Task(
          projectName: 'Personal Development',
          taskName: 'Flutter Training',
          status: 'In Progress',
          dueDate: '2024-02-25',
          priority: 'High',
          priorityColor: const Color(0xFFD14318),
          assignee: 'Me',
          statusColor: const Color(0xFF187E0F),
        ),
        Task(
          projectName: 'Documentation',
          taskName: 'Update User Manual',
          status: 'Completed',
          dueDate: '2024-02-10',
          priority: 'Medium',
          priorityColor: const Color(0xFF187E0F),
          assignee: 'Me',
          statusColor: const Color(0xFF192F5D),
        ),
      ];
      
      _isLoading = false;
      _filterTasks();
    });
  }

  @override
  void dispose() {
    _tasksSubscription?.cancel();
    _myTasksSubscription?.cancel();
    super.dispose();
  }

  void _filterTasks() {
    setState(() {
      // If a project was selected, filter tasks and set to project tab
      if (widget.selectedProject != null) {
        _showProjectTasks = true;
        // Filter project tasks to show only tasks for the selected project
        _projectTasks = _projectTasks
            .where((task) => task.projectName == widget.selectedProject)
            .toList();

        // If no tasks match the selected project, add a placeholder task
        if (_projectTasks.isEmpty && widget.selectedProject != null) {
          _projectTasks = [
            Task(
              projectName: widget.selectedProject!,
              taskName: 'Create first task',
              status: 'Not Started',
              dueDate: 'No date',
              priority: 'Medium',
              priorityColor: widget.projectColor ?? const Color(0xFF187E0F),
              assignee: 'Unassigned',
              statusColor: const Color(0xFFCCCCCC),
            ),
          ];
        }
      }

      _filteredTasks = _showProjectTasks ? _projectTasks : _myTasks;
    });
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _filteredTasks = (_showProjectTasks ? _projectTasks : _myTasks)
          .where((task) =>
              task.taskName.toLowerCase().contains(_searchQuery) ||
              task.assignee.toLowerCase().contains(_searchQuery) ||
              task.status.toLowerCase().contains(_searchQuery))
          .toList();
    });
  }

  void _toggleTaskTab(bool showProjectTasks) {
    setState(() {
      _showProjectTasks = showProjectTasks;
      _filteredTasks = _showProjectTasks ? _projectTasks : _myTasks;
    });
  }

  void _onNavBarTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Navigate to the appropriate screen based on index
    if (index != 1) {
      // If not Tasks tab (since we're already in TaskManager)
      switch (index) {
        case 0: // Dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Dashboard()),
          );
          break;
        case 2: // Chat
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ChatScreen()),
          );
          break;
        case 3: // Calendar
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Calendar()),
          );
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            // Add project summary card if a project was selected
            if (widget.selectedProject != null) _buildProjectSummary(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const SizedBox(height: 24),
                  _buildTabs(),
                  const SizedBox(height: 24),
                  _buildSearchBar(),
                  const SizedBox(height: 24),
                  // Display appropriate tasks based on selected tab
                  ..._buildTaskList(),
                  const SizedBox(height: 36),
                  _buildAddButton(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            NavBar(
              selectedIndex: _currentIndex,
              onTap: _onNavBarTap,
            ),
          ],
        ),
      ),
    );
  }

  // New method to build project summary card
  Widget _buildProjectSummary() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x56192F5D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.projectColor?.withOpacity(0.3) ??
              const Color(0xFF192F5D).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.projectColor ?? const Color(0xFF187E0F),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.selectedProject ?? '',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.group,
                  size: 16, color: Colors.black.withOpacity(0.75)),
              const SizedBox(width: 8),
              Text(
                widget.projectMembers ?? '0 Members',
                style: TextStyle(
                  color: Colors.black.withOpacity(0.75),
                  fontSize: 14,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(width: 20),
              Icon(
                widget.projectStatus == 'active'
                    ? Icons.check_circle
                    : widget.projectStatus == 'at-risk'
                        ? Icons.warning
                        : Icons.pause_circle,
                size: 16,
                color: widget.projectStatus == 'active'
                    ? Colors.green
                    : widget.projectStatus == 'at-risk'
                        ? Colors.orange
                        : Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                widget.projectStatus ?? 'status',
                style: TextStyle(
                  color: Colors.black.withOpacity(0.75),
                  fontSize: 14,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          if (widget.projectProgress != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Progress: ',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.75),
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  '${(widget.projectProgress! * 100).toInt()}%',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: Colors.grey.withOpacity(0.3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: widget.projectProgress!,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: widget.projectColor ?? const Color(0xFF187E0F),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
        ),
        Task(
          projectName: 'Documentation',
          taskName: 'Update User Manual',
          status: 'Completed',
          dueDate: '2024-02-10',
          priority: 'Medium',
          priorityColor: const Color(0xFF187E0F),
          assignee: 'Me',
          statusColor: const Color(0xFF192F5D),
        ),
      ];
      
      _isLoading = false;
      _filterTasks();
    });
  }

  @override
  void dispose() {
    _tasksSubscription?.cancel();
    _myTasksSubscription?.cancel();
    super.dispose();
  }

  void _filterTasks() {
    setState(() {
      // If a project was selected, filter tasks and set to project tab
      if (widget.selectedProject != null) {
        _showProjectTasks = true;
        // Filter project tasks to show only tasks for the selected project
        _projectTasks = _projectTasks
            .where((task) => task.projectName == widget.selectedProject)
            .toList();

        // If no tasks match the selected project, add a placeholder task
        if (_projectTasks.isEmpty && widget.selectedProject != null) {
          _projectTasks = [
            Task(
              projectName: widget.selectedProject!,
              taskName: 'Create first task',
              status: 'Not Started',
              dueDate: 'No date',
              priority: 'Medium',
              priorityColor: widget.projectColor ?? const Color(0xFF187E0F),
              assignee: 'Unassigned',
              statusColor: const Color(0xFFCCCCCC),
            ),
          ];
        }
      });
    }

    _filteredTasks = _showProjectTasks ? _projectTasks : _myTasks;
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _filteredTasks = (_showProjectTasks ? _projectTasks : _myTasks)
          .where((task) =>
              task.taskName.toLowerCase().contains(_searchQuery) ||
              task.assignee.toLowerCase().contains(_searchQuery) ||
              task.status.toLowerCase().contains(_searchQuery))
          .toList();
    });
  }

  void _toggleTaskTab(bool showProjectTasks) {
    setState(() {
      _showProjectTasks = showProjectTasks;
      _filteredTasks = _showProjectTasks ? _projectTasks : _myTasks;
    });
  }

  void _onNavBarTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Navigate to the appropriate screen based on index
    if (index != 1) {
      // If not Tasks tab (since we're already in TaskManager)
      switch (index) {
        case 0: // Dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Dashboard()),
          );
          break;
        case 2: // Chat
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ChatScreen()),
          );
          break;
        case 3: // Calendar
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Calendar()),
          );
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            // Add project summary card if a project was selected
            if (widget.selectedProject != null) _buildProjectSummary(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const SizedBox(height: 24),
                  _buildTabs(),
                  const SizedBox(height: 24),
                  _buildSearchBar(),
                  const SizedBox(height: 24),
                  // Display appropriate tasks based on selected tab
                  ..._buildTaskList(),
                  const SizedBox(height: 36),
                  _buildAddButton(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            NavBar(
              selectedIndex: _currentIndex,
              onTap: _onNavBarTap,
            ),
          ],
        ),
      ),
    );
  }

  // New method to build project summary card
  Widget _buildProjectSummary() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x56192F5D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.projectColor?.withOpacity(0.3) ??
              const Color(0xFF192F5D).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.projectColor ?? const Color(0xFF187E0F),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.selectedProject ?? '',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.group,
                  size: 16, color: Colors.black.withOpacity(0.75)),
              const SizedBox(width: 8),
              Text(
                widget.projectMembers ?? '0 Members',
                style: TextStyle(
                  color: Colors.black.withOpacity(0.75),
                  fontSize: 14,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(width: 20),
              Icon(
                  widget.projectStatus == 'active'
                      ? Icons.check_circle
                      : widget.projectStatus == 'at-risk'
                          ? Icons.warning
                          : Icons.task_alt,
                  size: 16,
                  color: Colors.black.withOpacity(0.75)),
              const SizedBox(width: 8),
              Text(
                widget.projectStatus ?? 'status',
                style: TextStyle(
                  color: Colors.black.withOpacity(0.75),
                  fontSize: 14,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          if (widget.projectProgress != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.75),
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  '${(widget.projectProgress! * 100).toInt()}%',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.75),
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Progress bar
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 7,
                  decoration: ShapeDecoration(
                    color: const Color(0x26192F5D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width *
                          widget.projectProgress! -
                      32,
                  height: 7,
                  decoration: ShapeDecoration(
                    color: widget.projectColor ?? const Color(0xFF187E0F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // New method to build task list based on selected tab
  List<Widget> _buildTaskList() {
    if (_filteredTasks.isEmpty) {
      return [
        const SizedBox(height: 50),
        Center(
          child: Text(
            'No ${_showProjectTasks ? "project" : "personal"} tasks found.',
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Inter',
              color: Color(0xFF666666),
            ),
          ),
        ),
      ];
    }

    return _filteredTasks.map((task) {
      return Column(
        children: [
          _showProjectTasks
              ? _buildProjectTaskCard(task)
              : _buildPersonalTaskCard(task),
          const SizedBox(height: 16),
        ],
      );
    }).toList();
  }

  // Simplified Project Task Card
  Widget _buildProjectTaskCard(Task task) {
    return Container(
      height: 140,
      decoration: ShapeDecoration(
        color: const Color(0x56192F5D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 140,
            decoration: ShapeDecoration(
              color: task.statusColor,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.projectName,
                    style: const TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          task.taskName,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: ShapeDecoration(
                          color: task.priorityColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: Text(
                          task.priority,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoChip(Icons.calendar_today_outlined,
                          task.dueDate),
                      _buildInfoChip(Icons.person_outline, task.assignee),
                      _buildInfoChip(Icons.info_outline, task.status),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _showEditTaskDialog(task),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteTask(task),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Improved Personal Task Card with edit and delete capabilities
  Widget _buildPersonalTaskCard(Task task) {
    return Container(
      height: 140, // Increased height to match project tasks
      decoration: ShapeDecoration(
        color: const Color(0x40192F5D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        shadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 140,
            decoration: ShapeDecoration(
              color: task.statusColor,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.taskName,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.category, size: 14, color: Color(0xFF666666)),
                      const SizedBox(width: 4),
                      Text(
                        task.projectName,
                        style: const TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoChip(Icons.calendar_today_outlined, "Due: ${task.dueDate}"),
                      _buildInfoChip(Icons.info_outline, task.status),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: ShapeDecoration(
                          color: task.priorityColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: Text(
                          task.priority,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _showEditTaskDialog(task),
                tooltip: 'Edit Task',
                iconSize: 22,
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteTask(task),
                tooltip: 'Delete Task',
                iconSize: 22,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper method to create info chips
  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: const Color(0xFF666666),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF666666),
            fontSize: 12,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE5E9EF),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (widget.selectedProject != null)
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.only(right: 12),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF192F5D),
                      size: 24,
                    ),
                  ),
                ),
              Text(
                widget.selectedProject != null
                    ? 'Tasks for ${widget.selectedProject}'
                    : 'Task Management',
                style: const TextStyle(
                  color: Color(0xFF192F5D),
                  fontSize: 20,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              // Navigate to Profile page when user icon is tapped
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200,
              ),
              child: Icon(Icons.person, color: Colors.grey[700], size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            _toggleTaskTab(true);
          },
          child: Container(
            width: 167,
            height: 50,
            decoration: ShapeDecoration(
              color: _showProjectTasks
                  ? const Color(0xFF192F5D)
                  : Colors.transparent,
              shape: RoundedRectangleBorder(
                side: const BorderSide(
                  width: 1,
                  color: Color(0xFF192F5D),
                ),
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              'Project Tasks',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _showProjectTasks
                    ? const Color(0xFFF7F8FB)
                    : Colors.black,
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                height: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: () {
            _toggleTaskTab(false);
          },
          child: Container(
            width: 138,
            height: 50,
            decoration: ShapeDecoration(
              color: !_showProjectTasks
                  ? const Color(0xFF192F5D)
                  : const Color(0xFFFCFDFF),
              shape: RoundedRectangleBorder(
                side: const BorderSide(
                  width: 1,
                  color: Color(0xFF192F5D),
                ),
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              'My Tasks',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: !_showProjectTasks
                    ? const Color(0xFFF7F8FB)
                    : const Color(0xFF190A0A),
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Enhanced search bar with real-time filtering
  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 1,
            color: Color(0xFF060D17),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.search, size: 20, color: Color(0xFF999999)),
          const SizedBox(width: 17),
          Expanded(
            child: TextField(
              onChanged: _onSearch,
              decoration: const InputDecoration(
                hintText: 'Search tasks...',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return Center(
      child: GestureDetector(
        onTap: () {
          // Show dialog to add new task to the appropriate list
          _showAddTaskDialog();
        },
        child: Container(
          width: 205,
          height: 56,
          decoration: ShapeDecoration(
            color: const Color(0xFF192F5D),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            shadows: const [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add,
                color: Colors.white,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Add New Task',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Enhanced task creation dialog with improved project selection
  void _showAddTaskDialog() {
    final TextEditingController taskNameController = TextEditingController();
    final TextEditingController assigneeController = TextEditingController();
    final TextEditingController dueDateController = TextEditingController();
    
    // Set default values
    String priority = 'Medium';
    String status = 'Not Started';
    String selectedProject = widget.selectedProject ?? '';
    DateTime selectedDate = DateTime.now().add(const Duration(days: 3));
    bool taskAdded = false;
    
    // Prepare a list of available projects for the dropdown
    List<String> availableProjects = [
      'Website Redesign',
      'Mobile App v2.0',
      'Data Analytics',
      'Marketing Campaign',
      'Product Launch',
    ];
    
    // If the widget has a selected project, add it to available projects if not already there
    if (widget.selectedProject != null && 
        !availableProjects.contains(widget.selectedProject)) {
      availableProjects.add(widget.selectedProject!);
    }
    
    // Sort alphabetically for better UX
    availableProjects.sort();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          // Get screen size to make dialog responsive
          final size = MediaQuery.of(context).size;
          final maxWidth = size.width > 600 ? 550.0 : size.width * 0.85;
          
          // Function to clear the form fields
          void clearForm() {
            taskNameController.clear();
            assigneeController.clear();
            dueDateController.text = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
            setState(() {
              priority = 'Medium';
              status = 'Not Started';
              taskAdded = false;
              selectedProject = widget.selectedProject ?? ''; // Reset to current project if any
            });
          }
            // Function to add a new task with Firebase integration
          void addTask() async {
            // Validate inputs
            if (taskNameController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter a task name'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }
            
            if (selectedProject.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please select a project'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            try {
              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              // Prepare task data for Firebase
              final taskData = {
                'title': taskNameController.text.trim(),
                'taskName': taskNameController.text.trim(),
                'projectName': selectedProject,
                'status': status,
                'priority': priority,
                'dueDate': dueDateController.text,
                'assigneeEmail': _showProjectTasks 
                    ? (assigneeController.text.isEmpty ? 'Unassigned' : assigneeController.text)
                    : FirebaseService.getCurrentUserEmail() ?? 'Me',
                'assignedTo': [FirebaseService.getCurrentUserId()], // Assign to current user
                'description': '',
                'progress': 0,
                'isPersonalTask': !_showProjectTasks,
              };

              // Create task in Firebase
              final taskId = await FirebaseService.createTask(taskData);

              // Hide loading indicator
              Navigator.pop(context);

              // Create the new task locally for immediate UI update
              Color statusColor;
              if (status == 'In Progress') {
                statusColor = const Color(0xFF187E0F);
              } else if (status == 'Pending') {
                statusColor = const Color(0xFFD14318);
              } else if (status == 'Completed') {
                statusColor = const Color(0xFF192F5D);
              } else {
                statusColor = const Color(0xFFCCCCCC);
              }

              final newTask = Task(
                id: taskId, // Store Firebase document ID
                projectName: selectedProject,
                taskName: taskNameController.text,
                status: status,
                dueDate: dueDateController.text,
                priority: priority,
                priorityColor: priority == 'High'
                    ? const Color(0xFFD14318)
                    : priority == 'Medium'
                        ? const Color(0xFF187E0F)
                        : const Color(0xFF192F5D),
                assignee: _showProjectTasks 
                    ? (assigneeController.text.isEmpty ? 'Unassigned' : assigneeController.text)
                    : 'Me',
                statusColor: statusColor,
              );

              // Add to the appropriate list and update state
              setState(() {
                if (_showProjectTasks) {
                  _projectTasks.add(newTask);
                } else {
                  _myTasks.add(newTask);
                }
                _filteredTasks = _showProjectTasks ? _projectTasks : _myTasks;
                taskAdded = true;
              });
              
              // Show a success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Task "${taskNameController.text}" created successfully!'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
              
              // Clear the form for the next task
              clearForm();

            } catch (e) {
              // Hide loading indicator if still showing
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
              
              // Show error message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to create task: ${e.toString()}'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
              
              print('Error creating task: $e');
            }
          }
            );
            
            // Clear the form for the next task
            clearForm();
          }
          
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxWidth,
                maxHeight: size.height * 0.8,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.add_task, color: Color(0xFF192F5D), size: 20),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Add New ${_showProjectTasks ? "Project" : "My"} Task',
                            style: const TextStyle(
                              color: Color(0xFF192F5D),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    
                    // Show success message when a task is added
                    if (taskAdded) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green, size: 18),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Task added! You can add another task or close the dialog.',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Task Details',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF192F5D),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: taskNameController,
                              decoration: InputDecoration(
                                labelText: 'Task Name*',
                                hintText: 'Enter task name',
                                prefixIcon: const Icon(Icons.task_alt, size: 18),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            // Project selection for both tabs
                            const Text(
                              'Project',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF666666),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFF192F5D)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedProject.isEmpty ? null : selectedProject,
                                  hint: const Text('Select Project'),
                                  isExpanded: true,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  items: availableProjects
                                      .map((project) => DropdownMenuItem(
                                            value: project,
                                            child: Text(
                                              project,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontSize: 13),
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedProject = value!;
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            const Text(
                              'Due Date',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF666666),
                              ),
                            ),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () async {
                                final DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: selectedDate,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2030),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: const ColorScheme.light(
                                          primary: Color(0xFF192F5D),
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (pickedDate != null) {
                                  setState(() {
                                    selectedDate = pickedDate;
                                    dueDateController.text = 
                                      "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  border: Border.all(color: const Color(0xFF192F5D)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 16),
                                    const SizedBox(width: 8),
                                    Text(
                                      "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}",
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            // Priority and Status in a row with Flexible to prevent overflow
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Priority',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF666666),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: const Color(0xFF192F5D)),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: priority,
                                            isDense: true,
                                            isExpanded: true,
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                            items: [
                                              DropdownMenuItem(
                                                value: 'High',
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 10,
                                                      height: 10,
                                                      decoration: const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Color(0xFFD14318),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    const Text('High', style: TextStyle(fontSize: 13)),
                                                  ],
                                                ),
                                              ),
                                              DropdownMenuItem(
                                                value: 'Medium',
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 10,
                                                      height: 10,
                                                      decoration: const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Color(0xFF187E0F),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    const Text('Medium', style: TextStyle(fontSize: 13)),
                                                  ],
                                                ),
                                              ),
                                              DropdownMenuItem(
                                                value: 'Low',
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 10,
                                                      height: 10,
                                                      decoration: const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Color(0xFF192F5D),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    const Text('Low', style: TextStyle(fontSize: 13)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                            onChanged: (value) {
                                              setState(() {
                                                priority = value!;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Status',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF666666),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: const Color(0xFF192F5D)),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: status,
                                            isDense: true,
                                            isExpanded: true,
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                            items: [
                                              DropdownMenuItem(
                                                value: 'Not Started',
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 10,
                                                      height: 10,
                                                      decoration: const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Color(0xFFCCCCCC),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    const Text('Not Started', 
                                                        style: TextStyle(fontSize: 13),
                                                        overflow: TextOverflow.ellipsis),
                                                  ],
                                                ),
                                              ),
                                              DropdownMenuItem(
                                                value: 'In Progress',
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 10,
                                                      height: 10,
                                                      decoration: const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Color(0xFF187E0F),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    const Text('In Progress', 
                                                        style: TextStyle(fontSize: 13),
                                                        overflow: TextOverflow.ellipsis),
                                                  ],
                                                ),
                                              ),
                                              DropdownMenuItem(
                                                value: 'Completed',
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 10,
                                                      height: 10,
                                                      decoration: const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Color(0xFF192F5D),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    const Text('Completed', 
                                                        style: TextStyle(fontSize: 13),
                                                        overflow: TextOverflow.ellipsis),
                                                  ],
                                                ),
                                              ),
                                              DropdownMenuItem(
                                                value: 'Pending',
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 10,
                                                      height: 10,
                                                      decoration: const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Color(0xFFD14318),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    const Text('Pending', 
                                                        style: TextStyle(fontSize: 13)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                            onChanged: (value) {
                                              setState(() {
                                                status = value!;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            
                            if (_showProjectTasks) ...[
                              TextField(
                                controller: assigneeController,
                                decoration: InputDecoration(
                                  labelText: 'Assignee',
                                  hintText: 'Enter team member name',
                                  prefixIcon: const Icon(Icons.person, size: 18),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            
                            // Button row with Add Task button and Clear Form button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: addTask,
                                    icon: const Icon(Icons.add_circle, size: 18),
                                    label: const Text('Add Task'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF192F5D),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: clearForm,
                                    icon: const Icon(Icons.clear_all, size: 18),
                                    label: const Text('Clear Form'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey.shade200,
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF192F5D)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Close', style: TextStyle(color: Color(0xFF192F5D))),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showEditTaskDialog(Task task) {
    final TextEditingController taskNameController =
        TextEditingController(text: task.taskName);
    final TextEditingController assigneeController =
        TextEditingController(text: task.assignee);
    final TextEditingController dueDateController =
        TextEditingController(text: task.dueDate);
    String priority = task.priority;
    String status = task.status;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final size = MediaQuery.of(context).size;
          final maxWidth = size.width > 600 ? 550.0 : size.width * 0.85;
          
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxWidth,
                maxHeight: size.height * 0.8,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.edit, color: Color(0xFF192F5D), size: 20),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Edit Task',
                            style: TextStyle(
                              color: Color(0xFF192F5D),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: taskNameController,
                              decoration: InputDecoration(
                                labelText: 'Task Name',
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: assigneeController,
                              decoration: InputDecoration(
                                labelText: 'Assignee',
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: dueDateController,
                              decoration: InputDecoration(
                                labelText: 'Due Date (YYYY-MM-DD)',
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Priority',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF666666),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: const Color(0xFF192F5D)),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: priority,
                                            isExpanded: true,
                                            isDense: true,
                                            padding: const EdgeInsets.symmetric(horizontal: 10),
                                            items: [
                                              DropdownMenuItem(
                                                value: 'High',
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 10,
                                                      height: 10,
                                                      decoration: const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Color(0xFFD14318),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    const Text('High', style: TextStyle(fontSize: 13)),
                                                  ],
                                                ),
                                              ),
                                              DropdownMenuItem(
                                                value: 'Medium',
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 10,
                                                      height: 10,
                                                      decoration: const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Color(0xFF187E0F),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    const Text('Medium', style: TextStyle(fontSize: 13)),
                                                  ],
                                                ),
                                              ),
                                              DropdownMenuItem(
                                                value: 'Low',
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 10,
                                                      height: 10,
                                                      decoration: const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Color(0xFF192F5D),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    const Text('Low', style: TextStyle(fontSize: 13)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                            onChanged: (value) {
                                              setState(() {
                                                priority = value!;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Status',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF666666),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: const Color(0xFF192F5D)),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: status,
                                            isExpanded: true,
                                            isDense: true,
                                            padding: const EdgeInsets.symmetric(horizontal: 10),
                                            items: [
                                              DropdownMenuItem(
                                                value: 'Not Started',
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 10,
                                                      height: 10,
                                                      decoration: const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Color(0xFFCCCCCC),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    const Text('Not Started', style: TextStyle(fontSize: 13)),
                                                  ],
                                                ),
                                              ),
                                              DropdownMenuItem(
                                                value: 'In Progress',
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 10,
                                                      height: 10,
                                                      decoration: const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Color(0xFF187E0F),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    const Text('In Progress', style: TextStyle(fontSize: 13)),
                                                  ],
                                                ),
                                              ),
                                              DropdownMenuItem(
                                                value: 'Pending',
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 10,
                                                      height: 10,
                                                      decoration: const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Color(0xFFD14318),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    const Text('Pending', style: TextStyle(fontSize: 13)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                            onChanged: (value) {
                                              setState(() {
                                                status = value!;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 4),                        ElevatedButton(
                          onPressed: () async {
                            // Validate inputs
                            if (taskNameController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Task name cannot be empty'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            try {
                              // Show loading indicator
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );

                              // Prepare update data for Firebase
                              final updateData = {
                                'title': taskNameController.text.trim(),
                                'taskName': taskNameController.text.trim(),
                                'assigneeEmail': assigneeController.text.trim().isEmpty ? 'Unassigned' : assigneeController.text.trim(),
                                'dueDate': dueDateController.text,
                                'priority': priority,
                                'status': status,
                              };

                              // Update task in Firebase
                              if (task.id != null) {
                                await FirebaseService.updateTask(task.id!, updateData);
                              }

                              // Hide loading indicator
                              Navigator.pop(context);

                              // Update local state for immediate UI feedback
                              setState(() {
                                task.taskName = taskNameController.text;
                                task.assignee = assigneeController.text;
                                task.dueDate = dueDateController.text;
                                task.priority = priority;
                                task.status = status;
                                
                                // Update colors based on status and priority
                                task.priorityColor = priority == 'High'
                                    ? const Color(0xFFD14318)
                                    : priority == 'Medium'
                                        ? const Color(0xFF187E0F)
                                        : const Color(0xFF192F5D);
                                        
                                // Update status color
                                if (status == 'In Progress') {
                                  task.statusColor = const Color(0xFF187E0F);
                                } else if (status == 'Pending') {
                                  task.statusColor = const Color(0xFFD14318);
                                } else if (status == 'Not Started') {
                                  task.statusColor = const Color(0xFFCCCCCC);
                                } else if (status == 'Completed') {
                                  task.statusColor = const Color(0xFF192F5D);
                                }
                              });

                              // Show success message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Task "${taskNameController.text}" updated successfully!'),
                                  backgroundColor: Colors.green,
                                  duration: const Duration(seconds: 2),
                                ),
                              );

                              Navigator.pop(context);

                            } catch (e) {
                              // Hide loading indicator if still showing
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              }
                              
                              // Show error message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to update task: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                              
                              print('Error updating task: $e');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF192F5D),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Save Changes',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Add specialized edit dialog for personal tasks
  void _showEditPersonalTaskDialog(Task task) {
    final TextEditingController taskNameController =
        TextEditingController(text: task.taskName);
    final TextEditingController categoryController =
        TextEditingController(text: task.projectName);
    final TextEditingController dueDateController =
        TextEditingController(text: task.dueDate);
    String priority = task.priority;
    String status = task.status;
    
    // Get original date from the task for date picker
    DateTime selectedDate;
    try {
      final parts = task.dueDate.split('-');
      if (parts.length == 3) {
        selectedDate = DateTime(
          int.parse(parts[0]), 
          int.parse(parts[1]), 
          int.parse(parts[2])
        );
      } else {
        selectedDate = DateTime.now().add(const Duration(days: 3));
      }
    } catch (e) {
      selectedDate = DateTime.now().add(const Duration(days: 3));
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final size = MediaQuery.of(context).size;
          final maxWidth = size.width > 600 ? 550.0 : size.width * 0.85;
          
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxWidth,
                maxHeight: size.height * 0.8,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.edit, color: Color(0xFF192F5D), size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Edit Personal Task',
                          style: TextStyle(
                            color: Color(0xFF192F5D),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        // Add a help icon with tooltip for personal tasks
                        Tooltip(
                          message: 'Edit your personal task details',
                          child: IconButton(
                            icon: const Icon(Icons.help_outline, 
                                size: 18, color: Color(0xFF192F5D)),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: taskNameController,
                              decoration: InputDecoration(
                                labelText: 'Task Name',
                                prefixIcon: const Icon(Icons.task_alt, size: 18),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            // Add category field for personal tasks
                            TextField(
                              controller: categoryController,
                              decoration: InputDecoration(
                                labelText: 'Category',
                                prefixIcon: const Icon(Icons.category, size: 18),
                                hintText: 'E.g., Personal Development, Health, Hobby',
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            // Date picker for personal tasks
                            const Text(
                              'Due Date',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF666666),
                              ),
                            ),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () async {
                                final DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: selectedDate,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2030),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: const ColorScheme.light(
                                          primary: Color(0xFF192F5D),
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (pickedDate != null) {
                                  setState(() {
                                    selectedDate = pickedDate;
                                    dueDateController.text = 
                                      "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  border: Border.all(color: const Color(0xFF192F5D)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 16),
                                    const SizedBox(width: 8),
                                    Text(
                                      dueDateController.text,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Priority',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF666666),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: const Color(0xFF192F5D)),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: priority,
                                            isExpanded: true,
                                            isDense: true,
                                            padding: const EdgeInsets.symmetric(horizontal: 10),
                                            items: [
                                              DropdownMenuItem(
                                                value: 'High',
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 10,
                                                      height: 10,
                                                      decoration: const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Color(0xFFD14318),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    const Text('High', style: TextStyle(fontSize: 13)),
                                                  ],
                                                ),
                                              ),
                                              DropdownMenuItem(
                                                value: 'Medium',
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 10,
                                                      height: 10,
                                                      decoration: const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Color(0xFF187E0F),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    const Text('Medium', style: TextStyle(fontSize: 13)),
                                                  ],
                                                ),
                                              ),
                                              DropdownMenuItem(
                                                value: 'Low',
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 10,
                                                      height: 10,
                                                      decoration: const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Color(0xFF192F5D),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    const Text('Low', style: TextStyle(fontSize: 13)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                            onChanged: (value) {
                                              setState(() {
                                                priority = value!;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Status',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF666666),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: const Color(0xFF192F5D)),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: status,
                                            isExpanded: true,
                                            isDense: true,
                                            padding: const EdgeInsets.symmetric(horizontal: 10),
                                            items: [
                                              DropdownMenuItem(
                                                value: 'Not Started',
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 10,
                                                      height: 10,
                                                      decoration: const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Color(0xFFCCCCCC),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    const Text('Not Started', style: TextStyle(fontSize: 13)),
                                                  ],
                                                ),
                                              ),
                                              DropdownMenuItem(
                                                value: 'In Progress',
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 10,
                                                      height: 10,
                                                      decoration: const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Color(0xFF187E0F),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    const Text('In Progress', style: TextStyle(fontSize: 13)),
                                                  ],
                                                ),
                                              ),
                                              DropdownMenuItem(
                                                value: 'Completed',
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 10,
                                                      height: 10,
                                                      decoration: const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Color(0xFF192F5D),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    const Text('Completed', style: TextStyle(fontSize: 13)),
                                                  ],
                                                ),
                                              ),
                                              DropdownMenuItem(
                                                value: 'Pending',
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 10,
                                                      height: 10,
                                                      decoration: const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Color(0xFFD14318),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    const Text('Pending', style: TextStyle(fontSize: 13)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                            onChanged: (value) {
                                              setState(() {
                                                status = value!;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, size: 18),
                          label: const Text('Cancel'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey,
                            side: const BorderSide(color: Colors.grey),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),                        ElevatedButton.icon(
                          onPressed: () async {
                            // Validate inputs
                            if (taskNameController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Task name cannot be empty'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            
                            try {
                              // Show loading indicator
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );

                              // Prepare update data for Firebase
                              final updateData = {
                                'title': taskNameController.text.trim(),
                                'taskName': taskNameController.text.trim(),
                                'projectName': categoryController.text.trim(),
                                'dueDate': dueDateController.text,
                                'priority': priority,
                                'status': status,
                                'isPersonalTask': true,
                              };

                              // Update task in Firebase
                              if (task.id != null) {
                                await FirebaseService.updateTask(task.id!, updateData);
                              }

                              // Hide loading indicator
                              Navigator.pop(context);

                              // Update local state for immediate UI feedback
                              setState(() {
                                task.taskName = taskNameController.text;
                                task.projectName = categoryController.text;
                                task.dueDate = dueDateController.text;
                                task.priority = priority;
                                task.status = status;
                                
                                // Update colors based on status and priority
                                task.priorityColor = priority == 'High'
                                    ? const Color(0xFFD14318)
                                    : priority == 'Medium'
                                        ? const Color(0xFF187E0F)
                                        : const Color(0xFF192F5D);
                                        
                                // Update status color
                                if (status == 'In Progress') {
                                  task.statusColor = const Color(0xFF187E0F);
                                } else if (status == 'Pending') {
                                  task.statusColor = const Color(0xFFD14318);
                                } else if (status == 'Not Started') {
                                  task.statusColor = const Color(0xFFCCCCCC);
                                } else if (status == 'Completed') {
                                  task.statusColor = const Color(0xFF192F5D);
                                }
                              });
                              
                              // Show success message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Personal task "${taskNameController.text}" updated successfully!'),
                                  backgroundColor: Colors.green,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                              
                              Navigator.pop(context);

                            } catch (e) {
                              // Hide loading indicator if still showing
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              }
                              
                              // Show error message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to update personal task: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                              
                              print('Error updating personal task: $e');
                            }
                          },
                          icon: const Icon(Icons.save, size: 18),
                          label: const Text('Save Changes'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF192F5D),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Add dedicated method for deleting personal tasks
  void _deletePersonalTask(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Personal Task'),
        content: Text('Are you sure you want to delete "${task.taskName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _myTasks.remove(task);
                _filteredTasks = _myTasks;
              });
              
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Task deleted successfully'),
                  backgroundColor: Colors.red,
                ),
              );
              
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Update the existing delete task method to also confirm with a dialog
  void _deleteTask(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project Task'),
        content: Text('Are you sure you want to delete "${task.taskName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _projectTasks.remove(task);
                _filteredTasks = _projectTasks;
              });
              
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Task deleted successfully'),
                  backgroundColor: Colors.red,
                ),
              );
              
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
