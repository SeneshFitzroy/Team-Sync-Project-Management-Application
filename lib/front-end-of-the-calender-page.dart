import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: CalendarScreen(),
    );
  }
}

class CalendarScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F4F9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
        title: const Text(''),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Calender',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF304878),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.calendar_month, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Nov 22',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              CalendarGrid(),
              const SizedBox(height: 20),
              EventsList(),
            ],
          ),
        ),
      ),
    );
  }
}

class CalendarGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: 42, // 6 weeks × 7 days
          itemBuilder: (context, index) {
            // Days of the previous month (29, 30)
            if (index < 2) {
              return CalendarDay(
                day: index + 29,
                isCurrentMonth: false,
                color: Colors.transparent,
              );
            }
            // Days of the current month (1-30)
            else if (index < 32) {
              final day = index - 1;
              Color? bgColor;

              // Highlight specific dates
              if (day == 4) bgColor = Colors.blue[400];
              else if (day == 5) bgColor = Colors.blue[400];
              else if (day == 8) bgColor = Colors.red[400];
              else if (day == 16) bgColor = Colors.amber[300];
              else if (day == 17) bgColor = Colors.amber[300];
              else if (day == 20) bgColor = Colors.green[400];
              else if (day == 21) bgColor = Colors.green[400];
              else if (day == 22) bgColor = Colors.green[400];

              return CalendarDay(
                day: day,
                isCurrentMonth: true,
                color: bgColor,
              );
            }
            // Days of the next month (1, 2)
            else {
              return CalendarDay(
                day: index - 31,
                isCurrentMonth: false,
                color: Colors.transparent,
              );
            }
          },
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            Text('Mon', style: TextStyle(fontSize: 12)),
            Text('Tue', style: TextStyle(fontSize: 12)),
            Text('Wed', style: TextStyle(fontSize: 12)),
            Text('Thu', style: TextStyle(fontSize: 12)),
            Text('Fri', style: TextStyle(fontSize: 12)),
            Text('Sat', style: TextStyle(fontSize: 12)),
            Text('Sun', style: TextStyle(fontSize: 12)),
          ],
        ),
      ],
    );
  }
}

class CalendarDay extends StatelessWidget {
  final int day;
  final bool isCurrentMonth;
  final Color? color;

  const CalendarDay({
    required this.day,
    required this.isCurrentMonth,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color ?? const Color(0xFFDDE6F3),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        day.toString(),
        style: TextStyle(
          color: !isCurrentMonth
              ? Colors.grey
              : (color != null ? Colors.white : Colors.black),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class EventsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        EventCard(
          title: 'Special lecture on business administration',
          date: 'Nov 4-5, 2025',
          time: '9:00 AM - 11:00 PM',
          room: 'Meeting Room 1',
          color: Colors.blue[400]!,
        ),
        const SizedBox(height: 12),
        EventCard(
          title: 'Special lecture on business administration',
          date: 'Nov 4-5, 2025',
          time: '9:00 AM - 11:00 PM',
          room: 'Meeting Room 1',
          color: Colors.red[400]!,
        ),
        const SizedBox(height: 12),
        EventCard(
          title: 'Special lecture on business administration',
          date: 'Nov 4-5, 2025',
          time: '9:00 AM - 11:00 PM',
          room: 'Meeting Room 1',
          color: Colors.amber[300]!,
        ),
        const SizedBox(height: 12),
        EventCard(
          title: 'Special lecture on business administration',
          date: 'Nov 4-5, 2025',
          time: '9:00 AM - 11:00 PM',
          room: 'Meeting Room 1',
          color: Colors.green[400]!,
        ),
      ],
    );
  }
}

class EventCard extends StatelessWidget {
  final String title;
  final String date;
  final String time;
  final String room;
  final Color color;

  const EventCard({
    required this.title,
    required this.date,
    required this.time,
    required this.room,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: color, width: 6),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      date,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            room,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
