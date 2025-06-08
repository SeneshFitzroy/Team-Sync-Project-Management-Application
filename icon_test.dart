import 'package:flutter/material.dart';

void main() {
  runApp(IconTestApp());
}

class IconTestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Icon Test',
      home: IconTestScreen(),
    );
  }
}

class IconTestScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Icon Test'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Testing Material Icons:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            
            Row(
              children: [
                Icon(Icons.dashboard_outlined, size: 24),
                SizedBox(width: 10),
                Text('dashboard_outlined'),
              ],
            ),
            SizedBox(height: 10),
            
            Row(
              children: [
                Icon(Icons.assignment_outlined, size: 24),
                SizedBox(width: 10),
                Text('assignment_outlined'),
              ],
            ),
            SizedBox(height: 10),
            
            Row(
              children: [
                Icon(Icons.chat_bubble_outline, size: 24),
                SizedBox(width: 10),
                Text('chat_bubble_outline'),
              ],
            ),
            SizedBox(height: 10),
            
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 24),
                SizedBox(width: 10),
                Text('calendar_today_outlined'),
              ],
            ),
            SizedBox(height: 10),
            
            Row(
              children: [
                Icon(Icons.person, size: 24),
                SizedBox(width: 10),
                Text('person'),
              ],
            ),
            SizedBox(height: 10),
            
            Row(
              children: [
                Icon(Icons.filter_list, size: 24),
                SizedBox(width: 10),
                Text('filter_list'),
              ],
            ),
            SizedBox(height: 10),
            
            Row(
              children: [
                Icon(Icons.search, size: 24),
                SizedBox(width: 10),
                Text('search'),
              ],
            ),
            SizedBox(height: 10),
            
            Row(
              children: [
                Icon(Icons.add, size: 24),
                SizedBox(width: 10),
                Text('add'),
              ],
            ),
            
            SizedBox(height: 30),
            Text('If you can see all the icons above, then Material Icons are working correctly.'),
          ],
        ),
      ),
    );
  }
}
