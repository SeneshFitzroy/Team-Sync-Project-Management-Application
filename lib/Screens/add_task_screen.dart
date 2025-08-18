import 'package:flutter/material.dart';
import '../Services/task_service.dart';
import '../models/task.dart';

class add_task_screenScreen extends StatefulWidget {
  const add_task_screenScreen({super.key});

  @override
  State<add_task_screenScreen> createState() => _add_task_screenScreenState();
}

class _add_task_screenScreenState extends State<add_task_screenScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedPriority = 'medium';
  String _selectedStatus = 'pending';
  DateTime _selectedDueDate = DateTime.now().add(const Duration(days: 1));
  bool _isLoading = false;

  final List<String> _priorities = ['low', 'medium', 'high', 'urgent'];
  final List<String> _statuses = ['pending', 'in_progress', 'completed'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDueDate) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  Future<void> _createTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final task = Task(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: _selectedPriority,
        status: _selectedStatus,
        dueDate: _selectedDueDate,
        createdAt: DateTime.now(),
      );

      await TaskService.createTask(task);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Task created successfully!',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error creating task: $e',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Create New Task',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2D62ED),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Task Title
                Text(
                  'Task Title',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: const Color(0xFF192F5D),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'Enter task title',
                    hintStyle: TextStyle(fontFamily: 'Poppins'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF2D62ED)),
                    ),
                  ),
                  style: TextStyle(fontFamily: 'Poppins'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a task title';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Task Description
                Text(
                  'Description',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: const Color(0xFF192F5D),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Enter task description',
                    hintStyle: TextStyle(fontFamily: 'Poppins'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF2D62ED)),
                    ),
                  ),
                  style: TextStyle(fontFamily: 'Poppins'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a task description';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Priority Selection
                Text(
                  'Priority',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: const Color(0xFF192F5D),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedPriority,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF2D62ED)),
                    ),
                  ),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: const Color(0xFF192F5D),
                  ),
                  items: _priorities.map((priority) {
                    return DropdownMenuItem(
                      value: priority,
                      child: Text(
                        priority.toUpperCase(),
                        style: TextStyle(fontFamily: 'Poppins'),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPriority = value!;
                    });
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Status Selection
                Text(
                  'Status',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: const Color(0xFF192F5D),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF2D62ED)),
                    ),
                  ),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: const Color(0xFF192F5D),
                  ),
                  items: _statuses.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(
                        status.replaceAll('_', ' ').toUpperCase(),
                        style: TextStyle(fontFamily: 'Poppins'),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                    });
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Due Date Selection
                Text(
                  'Due Date',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: const Color(0xFF192F5D),
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _selectDueDate,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_selectedDueDate.day}/${_selectedDueDate.month}/${_selectedDueDate.year}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: const Color(0xFF192F5D),
                          ),
                        ),
                        const Icon(Icons.calendar_today, color: Color(0xFF2D62ED)),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Create Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D62ED),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Create Task',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
