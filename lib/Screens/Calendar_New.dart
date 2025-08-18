import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();

  // Sample events/tasks for the calendar
  final Map<DateTime, List<CalendarEvent>> _events = {
    DateTime(2024, DateTime.now().month, DateTime.now().day): [
      CalendarEvent(
        title: 'Team Standup',
        time: '09:00 AM',
        type: EventType.meeting,
        color: const Color(0xFF2D62ED),
      ),
      CalendarEvent(
        title: 'Website Redesign Review',
        time: '02:00 PM',
        type: EventType.task,
        color: const Color(0xFF1ED760),
      ),
    ],
    DateTime(2024, DateTime.now().month, DateTime.now().day + 1): [
      CalendarEvent(
        title: 'Marketing Campaign Kickoff',
        time: '10:00 AM',
        type: EventType.meeting,
        color: const Color(0xFFFF7A00),
      ),
      CalendarEvent(
        title: 'UI/UX Design Session',
        time: '03:30 PM',
        type: EventType.task,
        color: const Color(0xFF2D62ED),
      ),
    ],
    DateTime(2024, DateTime.now().month, DateTime.now().day + 2): [
      CalendarEvent(
        title: 'Project Deadline',
        time: '11:59 PM',
        type: EventType.deadline,
        color: const Color(0xFFFF4757),
      ),
    ],
    DateTime(2024, DateTime.now().month, DateTime.now().day + 5): [
      CalendarEvent(
        title: 'Sprint Planning',
        time: '09:30 AM',
        type: EventType.meeting,
        color: const Color(0xFF2D62ED),
      ),
      CalendarEvent(
        title: 'Code Review Session',
        time: '02:00 PM',
        type: EventType.task,
        color: const Color(0xFF1ED760),
      ),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2D62ED), Color(0xFF1A365D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.white, size: 28),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Calendar & Schedule',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.white, size: 28),
                        onPressed: () {
                          _showAddEventDialog();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Today\'s Events',
                          _getEventsForDay(_selectedDate).length.toString(),
                          Icons.event,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'This Week',
                          _getWeekEventCount().toString(),
                          Icons.date_range,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Calendar Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildCalendarHeader(),
                    const SizedBox(height: 16),
                    _buildCalendarGrid(),
                    const SizedBox(height: 24),
                    _buildEventsList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            count,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, size: 28),
          onPressed: () {
            setState(() {
              _focusedDate = DateTime(_focusedDate.year, _focusedDate.month - 1);
            });
          },
        ),
        Text(
          DateFormat('MMMM yyyy').format(_focusedDate),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF000000),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right, size: 28),
          onPressed: () {
            setState(() {
              _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + 1);
            });
          },
        ),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Weekday headers
          Row(
            children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                .map((day) => Expanded(
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF555555),
                          fontSize: 12,
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          // Calendar days
          ..._buildCalendarDays(),
        ],
      ),
    );
  }

  List<Widget> _buildCalendarDays() {
    final firstDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month, 1);
    final lastDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month + 1, 0);
    final firstDayWeekday = firstDayOfMonth.weekday % 7;
    
    List<Widget> weeks = [];
    List<Widget> currentWeek = [];
    
    // Add empty cells for days before the first day of the month
    for (int i = 0; i < firstDayWeekday; i++) {
      currentWeek.add(const Expanded(child: SizedBox()));
    }
    
    // Add all days of the month
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      final date = DateTime(_focusedDate.year, _focusedDate.month, day);
      final isSelected = _isSameDay(date, _selectedDate);
      final hasEvents = _events.containsKey(date);
      final isToday = _isSameDay(date, DateTime.now());
      
      currentWeek.add(
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
            },
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isSelected 
                    ? const Color(0xFF2D62ED)
                    : isToday 
                        ? const Color(0xFF2D62ED).withOpacity(0.1)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: isToday && !isSelected
                    ? Border.all(color: const Color(0xFF2D62ED), width: 1)
                    : null,
              ),
              child: Container(
                height: 40,
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        day.toString(),
                        style: TextStyle(
                          color: isSelected 
                              ? Colors.white
                              : isToday 
                                  ? const Color(0xFF2D62ED)
                                  : const Color(0xFF000000),
                          fontWeight: isSelected || isToday 
                              ? FontWeight.bold 
                              : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (hasEvents && !isSelected)
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF7A00),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      
      if (currentWeek.length == 7) {
        weeks.add(Row(children: currentWeek));
        weeks.add(const SizedBox(height: 4));
        currentWeek = [];
      }
    }
    
    // Fill the last week if necessary
    while (currentWeek.length < 7) {
      currentWeek.add(const Expanded(child: SizedBox()));
    }
    if (currentWeek.isNotEmpty) {
      weeks.add(Row(children: currentWeek));
    }
    
    return weeks;
  }

  Widget _buildEventsList() {
    final events = _getEventsForDay(_selectedDate);
    
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Events for ${DateFormat('MMM dd').format(_selectedDate)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF000000),
                ),
              ),
              if (events.isEmpty)
                TextButton.icon(
                  onPressed: _showAddEventDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Event'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (events.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_available,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No events scheduled',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap + to add a new event',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return _buildEventCard(event);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEventCard(CalendarEvent event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: event.color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: event.color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF000000),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      _getEventIcon(event.type),
                      size: 16,
                      color: const Color(0xFF555555),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      event.time,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF555555),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: event.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getEventTypeText(event.type),
                        style: TextStyle(
                          fontSize: 12,
                          color: event.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEventDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Event'),
        content: const Text('Event creation feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  List<CalendarEvent> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  int _getWeekEventCount() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday % 7));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    int count = 0;
    for (var date in _events.keys) {
      if (date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
          date.isBefore(endOfWeek.add(const Duration(days: 1)))) {
        count += _events[date]!.length;
      }
    }
    return count;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  IconData _getEventIcon(EventType type) {
    switch (type) {
      case EventType.meeting:
        return Icons.people;
      case EventType.task:
        return Icons.task_alt;
      case EventType.deadline:
        return Icons.schedule;
    }
  }

  String _getEventTypeText(EventType type) {
    switch (type) {
      case EventType.meeting:
        return 'Meeting';
      case EventType.task:
        return 'Task';
      case EventType.deadline:
        return 'Deadline';
    }
  }
}

enum EventType { meeting, task, deadline }

class CalendarEvent {
  final String title;
  final String time;
  final EventType type;
  final Color color;

  CalendarEvent({
    required this.title,
    required this.time,
    required this.type,
    required this.color,
  });
}
