import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import './Profile.dart';
import '../Services/task_service.dart';
import '../Services/auth_service.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  DateTime _selectedMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  final List<String> _weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  String _filterPriority = 'all';

  void _changeMonth(int offset) {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + offset);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
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
                        
                        // Is selected?
                        final bool isSelected = isCurrentMonth && 
                            day == _selectedDate.day && 
                            _selectedMonth.month == _selectedDate.month && 
                            _selectedMonth.year == _selectedDate.year;
                        
                        return GestureDetector(
                          onTap: isCurrentMonth ? () {
                            setState(() {
                              _selectedDate = DateTime(_selectedMonth.year, _selectedMonth.month, day);
                            });
                          } : null,
                          child: Container(
                            margin: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isSelected ? Color(0xFF2D62ED) : 
                                     isToday ? Color(0xFFEFF6FF) : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: isToday && !isSelected
                                  ? Border.all(color: Color(0xFF3B82F6)) 
                                  : null,
                            ),
                            child: Center(
                              child: isCurrentMonth 
                                  ? Text(
                                      day.toString(),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                                        color: isSelected ? Colors.white :
                                               isToday ? Color(0xFF3B82F6) : Color(0xFF1E293B),
                                      ),
                                    )
                                  : Text(''),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Add Task for Selected Date Button
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: ElevatedButton.icon(
                  onPressed: () => _showAddTaskDialog(),
                  icon: Icon(Icons.add_task, color: Colors.white),
                  label: Text(
                    'Add Task for ${DateFormat('MMM dd').format(_selectedDate)}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2D62ED),
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
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
              
              // Task items from Firebase
              StreamBuilder<List<Task>>(
                stream: TaskService.getTasksForDate(_selectedDate),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading tasks',
                        style: TextStyle(
                          color: Colors.red,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    );
                  }
                  
                  List<Task> tasks = snapshot.data ?? [];
                  
                  // Filter by priority if needed
                  if (_filterPriority != 'all') {
                    tasks = tasks.where((task) => task.priority == _filterPriority).toList();
                  }
                  
                  if (tasks.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.task_alt, color: Colors.grey[400], size: 48),
                          const SizedBox(height: 12),
                          Text(
                            'No tasks for this date',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return Column(
                    children: tasks.map((task) {
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
                      
                      return _buildTaskCard(
                        task.title,
                        DateFormat('HH:mm').format(task.dueDate),
                        DateFormat('yyyy-MM-dd').format(task.dueDate),
                        task.priority,
                        priorityColor,
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ), // Close Column
        ), // Close Padding
      ), // Close SingleChildScrollView
    ), // Close SafeArea
  ); // Close Scaffold
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
