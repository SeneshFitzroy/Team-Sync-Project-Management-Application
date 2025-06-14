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
  DateTime? _selectedDate;
  final List<String> _weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  int _currentIndex = 3; // Set to 3 for Calendar tab
  List<Map<String, dynamic>> _tasks = [];
  List<Map<String, dynamic>> _selectedDateTasks = [];
  String _filterPriority = 'all';
  bool _isLoadingTasks = true;
  StreamSubscription<QuerySnapshot>? _tasksSubscription;
  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadTasks();
    _loadSelectedDateTasks();
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
    
    // Listen to Firebase tasks stream for the current month
    final startOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final endOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    
    _tasksSubscription?.cancel();
    _tasksSubscription = FirebaseService.getTasksForDateRange(
      startDate: startOfMonth,
      endDate: endOfMonth,
    ).listen(
      (snapshot) {
        if (mounted) {
          setState(() {
            _tasks = snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return {
                'id': doc.id,
                'title': data['taskName'] ?? 'Untitled Task',
                'time': _formatTaskTime(data['scheduledDate']),
                'date': _formatTaskDate(data['scheduledDate']),
                'priority': _mapPriority(data['priority']),
                'status': data['status'] ?? 'To Do',
                'scheduledDate': data['scheduledDate'],
                'projectName': data['projectName'] ?? 'Personal',
                ...data,
              };
            }).toList();
            _isLoadingTasks = false;
            _loadSelectedDateTasks();
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

  void _loadSelectedDateTasks() {
    if (_selectedDate == null) return;
    
    final selectedDateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    setState(() {
      _selectedDateTasks = _tasks.where((task) {
        return task['date'] == selectedDateStr;
      }).toList();
    });
  }
  String _formatTaskTime(dynamic scheduledDate) {
    if (scheduledDate == null) return 'No time set';
    try {
      DateTime date;
      if (scheduledDate is Timestamp) {
        date = scheduledDate.toDate();
      } else if (scheduledDate is String) {
        date = DateTime.parse(scheduledDate);
      } else {
        return 'No time set';
      }
      return DateFormat('h:mm a').format(date);
    } catch (e) {
      return 'No time set';
    }
  }

  String _formatTaskDate(dynamic scheduledDate) {
    if (scheduledDate == null) return DateFormat('yyyy-MM-dd').format(DateTime.now());
    try {
      DateTime date;
      if (scheduledDate is Timestamp) {
        date = scheduledDate.toDate();
      } else if (scheduledDate is String) {
        date = DateTime.parse(scheduledDate);
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
    if (index == _currentIndex) return;
    
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0: // Dashboard
        Navigator.pushReplacementNamed(context, '/dashboard');
        break;
      case 1: // Tasks
        Navigator.pushReplacementNamed(context, '/taskmanager');
        break;
      case 2: // Chat
        Navigator.pushReplacementNamed(context, '/chat');
        break;
      case 3: // Calendar - already here
        break;
      case 4: // Profile
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        break;
    }  }

  void _navigateToMonth(int offset) {
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Calendar',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 24,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Calendar navigation
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _navigateToMonth(-1),
                ),
                Text(
                  DateFormat('MMMM yyyy').format(_selectedMonth),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _navigateToMonth(1),
                ),
              ],
            ),
          ),
          
          // Week days header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _weekDays.map((day) => SizedBox(
                width: 40,
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              )).toList(),
            ),
          ),
          
          // Calendar grid
          Container(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemCount: 42, // 6 weeks * 7 days              itemBuilder: (context, index) {
                final int firstDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1).weekday;
                final int daysInMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
                final int dayNumber = index - (firstDayOfMonth - 2);
                
                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return Container(); // Empty container for days outside the month
                }
                
                final currentDate = DateTime(_selectedMonth.year, _selectedMonth.month, dayNumber);
                final bool isToday = dayNumber == DateTime.now().day &&
                    _selectedMonth.month == DateTime.now().month &&
                    _selectedMonth.year == DateTime.now().year;
                final bool isSelected = _selectedDate != null &&
                    dayNumber == _selectedDate!.day &&
                    _selectedMonth.month == _selectedDate!.month &&
                    _selectedMonth.year == _selectedDate!.year;
                
                // Check if this date has tasks
                final dateStr = DateFormat('yyyy-MM-dd').format(currentDate);
                final hasTask = _tasks.any((task) => task['date'] == dateStr);
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = currentDate;
                    });
                    _loadSelectedDateTasks();
                  },
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? const Color(0xFF3B82F6)
                          : isToday 
                              ? const Color(0xFF3B82F6).withOpacity(0.3)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: hasTask 
                          ? Border.all(color: const Color(0xFF10B981), width: 2)
                          : null,
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            dayNumber.toString(),
                            style: TextStyle(
                              color: isSelected 
                                  ? Colors.white 
                                  : isToday 
                                      ? const Color(0xFF1E293B)
                                      : const Color(0xFF1E293B),
                              fontWeight: isSelected || isToday 
                                  ? FontWeight.w600 
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (hasTask && !isSelected)
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
            // Add Task Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedDate != null 
                      ? 'Tasks for ${DateFormat('MMM d, yyyy').format(_selectedDate!)}'
                      : 'Tasks for Today',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddTaskDialog(),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Task'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Selected date tasks
          if (_selectedDate != null && _selectedDateTasks.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tasks for selected date:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._selectedDateTasks.map((task) => _buildTaskCard(
                    task['title'] as String,
                    task['time'] as String,
                    task['date'] as String,
                    task['priority'] as String,
                  )).toList(),
                ],
              ),
            ),
          
          if (_selectedDate != null && _selectedDateTasks.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.event_available,
                        color: Colors.grey.shade400,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'No tasks scheduled for this date',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Tasks list
          Expanded(
            child: _isLoadingTasks
                ? const Center(child: CircularProgressIndicator())
                : Flexible(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: _getFilteredTasks().length,
                      itemBuilder: (context, index) {
                        final task = _getFilteredTasks()[index];
                        return _buildTaskCard(
                          task['title'] as String,
                          task['time'] as String,
                          task['date'] as String,
                          task['priority'] as String,
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: NavBar(
        selectedIndex: _currentIndex,
        onTap: _onNavBarTap,
      ),
    );
  }

  Widget _buildTaskCard(String title, String time, String date, String priority) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Priority indicator
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: priority == 'high' 
                  ? Colors.red 
                  : priority == 'medium' 
                      ? Colors.orange 
                      : Colors.green,
              borderRadius: BorderRadius.circular(2),
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
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 12, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.calendar_today, size: 12, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Text(
                      date,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              priority,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
