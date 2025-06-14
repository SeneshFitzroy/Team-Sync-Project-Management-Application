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
              itemCount: 42, // 6 weeks * 7 days
              itemBuilder: (context, index) {
                final int firstDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1).weekday;
                final int daysInMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
                final int dayNumber = index - (firstDayOfMonth - 2);
                
                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return Container(); // Empty container for days outside the month
                }
                
                final bool isToday = dayNumber == DateTime.now().day &&
                    _selectedMonth.month == DateTime.now().month &&
                    _selectedMonth.year == DateTime.now().year;
                
                return Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isToday ? const Color(0xFF3B82F6) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      dayNumber.toString(),
                      style: TextStyle(
                        color: isToday ? Colors.white : const Color(0xFF1E293B),
                        fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Filter dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Text(
                  'Filter by priority: ',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                DropdownButton<String>(
                  value: _filterPriority,
                  onChanged: (String? newValue) {
                    setState(() {
                      _filterPriority = newValue!;
                    });
                  },
                  items: <String>['all', 'high', 'medium', 'low']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value == 'all' ? 'All' : value.toUpperCase()),
                    );
                  }).toList(),
                ),
              ],
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
