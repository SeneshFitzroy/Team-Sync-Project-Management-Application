import 'package:flutter/material.dart';

// Import components from the template
import 'Components/backbutton.dart';
import 'Components/nav_bar.dart';
import 'Components/search_bar.dart';
import 'Components/search_field.dart';
import 'Components/profile_icon.dart';
import 'Components/filter_icon.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF192F5D)),
        useMaterial3: true,
      ),
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool isTeamsSelected = true;
  int _selectedNavIndex = 2; // Set default to Chat tab (index 2)
  final TextEditingController _searchController = TextEditingController();

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedNavIndex = index;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButtonWidget(),
        title: const Text(
          'Chat',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A2B4A),
          ),
        ),
        actions: [
          SearchIconButton(),
          const SizedBox(width: 8),
          FilterIcon(
            onPressed: () {
              print('Filter icon pressed');
            },
          ),
          const SizedBox(width: 8),
          ProfileIcon(),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search field from components
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: SearchField(
                controller: _searchController,
                onChanged: (value) {
                  print('Searching for: $value');
                },
              ),
            ),

            // Teams and Members toggle
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isTeamsSelected = true;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        decoration: BoxDecoration(
                          color: isTeamsSelected ? Color(0xFF1A2B4A) : Colors.white,
                          borderRadius: BorderRadius.circular(20.0),
                          border: Border.all(
                            color: isTeamsSelected ? Color(0xFF1A2B4A) : Colors.grey[300]!,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Teams',
                            style: TextStyle(
                              color: isTeamsSelected ? Colors.white : Color(0xFF1A2B4A),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isTeamsSelected = false;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        decoration: BoxDecoration(
                          color: !isTeamsSelected ? Color(0xFF1A2B4A) : Colors.white,
                          borderRadius: BorderRadius.circular(20.0),
                          border: Border.all(
                            color: !isTeamsSelected ? Color(0xFF1A2B4A) : Colors.grey[300]!,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Members',
                            style: TextStyle(
                              color: !isTeamsSelected ? Colors.white : Color(0xFF1A2B4A),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Chat list
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  // Sample chat entry
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Product Launch Team',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sarah: Updated the mockups',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '10:45 AM',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Divider(height: 1, color: Colors.grey[200]),
                    ],
                  ),
                ],
              ),
            ),

            // Using NavBar component instead of custom bottom nav
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: NavBar(
                selectedIndex: _selectedNavIndex,
                onTap: _onNavItemTapped,
              ),
            ),
          ],
        ),
      ),
    );
  }
}