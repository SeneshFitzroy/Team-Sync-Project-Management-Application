import 'package:flutter/material.dart';
import '../Services/task_service.dart';
import '../models/task.dart';
import './add_task_screen.dart';

class task_management_screenScreen extends StatefulWidget {
  const task_management_screenScreen({super.key});

  @override
  State<task_management_screenScreen> createState() => _task_management_screenScreenState();
}

class _task_management_screenScreenState extends State<task_management_screenScreen> {
  String _selectedFilter = 'all';
  final List<String> _filters = ['all', 'pending', 'in_progress', 'completed'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Task Management',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2D62ED),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const add_task_screenScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF2D62ED) : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        filter.replaceAll('_', ' ').toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[700],
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          // Task List
          Expanded(
            child: StreamBuilder<List<Task>>(
              stream: _selectedFilter == 'all' 
                  ? TaskService.getAllTasks()
                  : TaskService.getTasksByStatus(_selectedFilter),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, color: Colors.red, size: 48),
                        SizedBox(height: 16),
                        Text(
                          'Error loading tasks',
                          style: TextStyle(
                            color: Colors.red,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                final tasks = snapshot.data ?? [];
                
                if (tasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.task_alt, color: Colors.grey[400], size: 64),
                        const SizedBox(height: 16),
                        Text(
                          'No tasks found',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create your first task to get started!',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontFamily: 'Poppins',
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const add_task_screenScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2D62ED),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.add),
                          label: const Text(
                            'Create Task',
                            style: TextStyle(fontFamily: 'Poppins'),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return _buildTaskCard(task);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    Color priorityColor;
    switch (task.priority.toLowerCase()) {
      case 'urgent':
        priorityColor = const Color(0xFFFF1212);
        break;
      case 'high':
        priorityColor = const Color(0xFFF59E0B);
        break;
      case 'medium':
        priorityColor = const Color(0xFF4318D1);
        break;
      default:
        priorityColor = const Color(0xFF4CAF50);
    }

    Color statusColor;
    switch (task.status.toLowerCase()) {
      case 'completed':
        statusColor = const Color(0xFF4CAF50);
        break;
      case 'in_progress':
        statusColor = const Color(0xFFFF9800);
        break;
      default:
        statusColor = const Color(0xFF6B7280);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  decoration: BoxDecoration(
                    color: priorityColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xFF192F5D),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        task.description,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'delete') {
                      _deleteTask(task);
                    } else {
                      await TaskService.updateTaskStatus(task.id!, value);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'pending',
                      child: Text('Mark as Pending'),
                    ),
                    const PopupMenuItem(
                      value: 'in_progress',
                      child: Text('Mark as In Progress'),
                    ),
                    const PopupMenuItem(
                      value: 'completed',
                      child: Text('Mark as Completed'),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    task.priority.toUpperCase(),
                    style: TextStyle(
                      color: priorityColor,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    task.status.replaceAll('_', ' ').toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  '${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontFamily: 'Poppins',
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _deleteTask(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Task',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        content: Text(
          'Are you sure you want to delete "${task.title}"?',
          style: const TextStyle(fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await TaskService.deleteTask(task.id!);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Task deleted successfully',
                        style: TextStyle(fontFamily: 'Poppins'),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Error deleting task: $e',
                        style: const TextStyle(fontFamily: 'Poppins'),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.red,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
