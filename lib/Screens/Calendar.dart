import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import './Profile.dart'; // Add this import

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  DateTime _selectedMonth = DateTime.now();
  final List<String> _weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  final List<Map<String, dynamic>> _tasks = [
    {'title': 'Q4 Revenue Report', 'time': '10:00 AM', 'date': '2024-01-25', 'priority': 'urgent'},
    {'title': 'Design Review Meeting', 'time': '02:30 PM', 'date': '2024-01-26', 'priority': 'pending'},
    {'title': 'Product Launch Prep', 'time': '11:00 AM', 'date': '2024-01-28', 'priority': 'in-progress'},
  ];
  String _filterPriority = 'all';

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
              Column(
                children: List.generate(
                  _getFilteredTasks().length,
                  (index) {
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
