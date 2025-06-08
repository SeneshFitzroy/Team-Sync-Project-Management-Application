import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../Components/nav_bar.dart';
import '../Services/firebase_service.dart';
import './Profile.dart' show ProfileScreen;

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  DateTime _selectedMonth = DateTime.now();
  final List<String> _weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  int _currentIndex = 3; // Set to 3 for Calendar tab
  List<Map<String, dynamic>> _tasks = [];
  String _filterPriority = 'all';
  bool _isLoadingTasks = true;
  StreamSubscription<QuerySnapshot>? _tasksSubscription;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void dispose() {
    _tasksSubscription?.cancel();
    super.dispose();
  }

  void _loadTasks() {
    setState(() {
      _isLoadingTasks = true;
    });
    
    // Listen to Firebase tasks stream
    _tasksSubscription = FirebaseService.getUserTasks().listen(
      (snapshot) {
        if (mounted) {
          setState(() {
            _tasks = snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return {
                'title': data['taskName'] ?? 'Untitled Task',
                'time': _formatTaskTime(data['dueDate']),
                'date': _formatTaskDate(data['dueDate']),
                'priority': _mapPriority(data['priority']),
                'id': doc.id,
              };
            }).toList();
            _isLoadingTasks = false;
          });
        }
      },
      onError: (e) {
        if (mounted) {
          setState(() {
            _isLoadingTasks = false;
            _tasks = [];
          });
        }
        print('Error loading tasks: $e');
      },
    );
  }

  String _formatTaskTime(dynamic dueDate) {
    if (dueDate == null) return 'No time set';
    try {
      DateTime date;
      if (dueDate is Timestamp) {
        date = dueDate.toDate();
      } else if (dueDate is String) {
        date = DateTime.parse(dueDate);
      } else {
        return 'No time set';
      }
      return DateFormat('h:mm a').format(date);
    } catch (e) {
      return 'No time set';
    }
  }

  String _formatTaskDate(dynamic dueDate) {
    if (dueDate == null) return DateFormat('yyyy-MM-dd').format(DateTime.now());
    try {
      DateTime date;
      if (dueDate is Timestamp) {
        date = dueDate.toDate();
      } else if (dueDate is String) {
        date = DateTime.parse(dueDate);
      } else {
        return DateFormat('yyyy-MM-dd').format(DateTime.now());
      }
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (e) {
      return DateFormat('yyyy-MM-dd').format(DateTime.now());
    }
  }

  String _mapPriority(dynamic priority) {
    if (priority == null) return 'pending';
    String priorityStr = priority.toString().toLowerCase();
    if (priorityStr.contains('high') || priorityStr.contains('urgent')) return 'urgent';
    if (priorityStr.contains('medium') || priorityStr.contains('progress')) return 'in-progress';
    return 'pending';
  }

  void _onNavBarTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    // Navigate to the appropriate screen based on index    if (index != 3) { // If not Calendar tab (since we're already in Calendar)
      switch (index) {
        case 0: // Dashboard
          Navigator.pushReplacementNamed(context, '/dashboard');
          break;
        case 1: // Tasks
          Navigator.pushReplacementNamed(context, '/tasks');
          break;
        case 2: // Chat
          Navigator.pushReplacementNamed(context, '/chat');
          break;
      }
    }
  }

  void _changeMonth(int offset) {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + offset);
    });
  }

  List<Map<String, dynamic>> _getFilteredTasks() {
    if (_filterPriority == 'all') return _tasks;
    return _tasks.where((task) => task['priority'] == _filterPriority).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and profile
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Calendar',
                    style: TextStyle(
                      color: const Color(0xFF192F5D),
                      fontSize: 22,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigate to Profile page when user icon is tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProfileScreen()),
                      );
                    },
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey[200],
                      child: Icon(Icons.person, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Month selector
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    // Month and year with navigation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('MMMM yyyy').format(_selectedMonth),
                          style: TextStyle(
                            color: const Color(0xFF192F5D),
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.arrow_back_ios, size: 16),
                              onPressed: () => _changeMonth(-1),
                            ),
                            IconButton(
                              icon: Icon(Icons.arrow_forward_ios, size: 16),
                              onPressed: () => _changeMonth(1),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Week days header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: _weekDays.map((day) => SizedBox(
                        width: 32,
                        child: Text(
                          day,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFF64748B),
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )).toList(),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Calendar grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        childAspectRatio: 1,
                      ),
                      itemCount: 35, // 5 weeks display
                      itemBuilder: (context, index) {
                        // Get the date for this cell
                        final int firstDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1).weekday;
                        final int daysInMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
                        
                        // Calculate day number (1-31)
                        final int day = index - firstDayOfMonth + 2;
                        
                        // Determine if this day is in the current month
                        final bool isCurrentMonth = day > 0 && day <= daysInMonth;
                        
                        // Is today?
                        final bool isToday = isCurrentMonth && 
                            day == DateTime.now().day && 
                            _selectedMonth.month == DateTime.now().month && 
                            _selectedMonth.year == DateTime.now().year;
                        
                        return Container(
                          margin: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isToday ? Color(0xFFEFF6FF) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: isToday 
                                ? Border.all(color: Color(0xFF3B82F6)) 
                                : null,
                          ),
                          child: Center(
                            child: isCurrentMonth 
                                ? Text(
                                    day.toString(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                      color: isToday ? Color(0xFF3B82F6) : Color(0xFF1E293B),
                                    ),
                                  )
                                : Text(''),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Upcoming Tasks section with filter
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Upcoming Tasks',
                    style: TextStyle(
                      color: const Color(0xFF192F5D),
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  DropdownButton<String>(
                    value: _filterPriority,
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All')),
                      DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                      DropdownMenuItem(value: 'pending', child: Text('Pending')),
                      DropdownMenuItem(value: 'in-progress', child: Text('In Progress')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _filterPriority = value!;
                      });
                    },
                  ),
                ],
              ),
                const SizedBox(height: 12),
              // Task items  
              Flexible(
                child: _isLoadingTasks
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : _getFilteredTasks().isEmpty
                        ? const Center(
                            child: Text(
                              'No tasks found',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _getFilteredTasks().length,
                            itemBuilder: (context, index) {
                              final task = _getFilteredTasks()[index];
                              return _buildTaskCard(
                                task['title'],
                                task['time'],
                                task['date'],
                                task['priority'],
                                task['priority'] == 'urgent'
                                    ? const Color(0xFFFF1212)
                                    : task['priority'] == 'pending'
                                        ? const Color(0xFF4318D1)
                                        : const Color(0xFFF59E0B),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavBar(
        selectedIndex: _currentIndex,
        onTap: _onNavBarTap,
      ),
    );
  }

  Widget _buildTaskCard(String title, String time, String date, String priority, Color indicatorColor) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: const Color(0xFFF8FAFC),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Task indicator
            Container(
              width: 8,
              height: 40,
              decoration: BoxDecoration(
                color: indicatorColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            
            // Task details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: const Color(0xFF1E293B),
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 12, color: Color(0xFF64748B)),
                      SizedBox(width: 4),
                      Text(
                        time,
                        style: TextStyle(
                          color: const Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(width: 16),
                      Icon(Icons.calendar_today, size: 12, color: Color(0xFF64748B)),
                      SizedBox(width: 4),
                      Text(
                        date,
                        style: TextStyle(
                          color: const Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Priority badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                priority,
                style: TextStyle(
                  color: const Color(0xFF64748B),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
