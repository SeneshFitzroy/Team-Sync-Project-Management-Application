import 'package:flutter/material.dart';
import 'Dashboard.dart';
import 'TaskManager.dart';
import 'Chat.dart';
import 'Calendar.dart';
import '../Components/nav_bar.dart';

class MainAppNavigator extends StatefulWidget {
  const MainAppNavigator({super.key});

  @override
  State<MainAppNavigator> createState() => _MainAppNavigatorState();
}

class _MainAppNavigatorState extends State<MainAppNavigator> {
  int _selectedIndex = 0;
  
  final List<Widget> _pages = [
    const Dashboard(),
    const TaskManager(),
    const Chat(),
    const Calendar(),
  ];

  void _onNavigationTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavBar(
        selectedIndex: _selectedIndex,
        onTap: _onNavigationTap,
      ),
    );
  }
}
