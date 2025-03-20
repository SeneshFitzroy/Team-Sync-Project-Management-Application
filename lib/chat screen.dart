import 'package:flutter/material.dart';

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
  bool isTeamsSelected = false;
  final TextEditingController _searchController = TextEditingController();

  // Chat data model
  List<ChatItem> chats = [
    ChatItem(
      name: "Sarah Johnson",
      message: "Hey, how are you?",
      time: "2m ago",
      isOnline: true,
    ),
    ChatItem(
      name: "Michael Chen",
      message: "See you tomorrow!",
      time: "1h ago",
      isOnline: false,
    ),
    ChatItem(
      name: "Emma Wilson",
      message: "Thanks for the help!",
      time: "3h ago",
      isOnline: true,
    ),
    ChatItem(
      name: "James Rodriguez",
      message: "Meeting at 3pm",
      time: "5h ago",
      isOnline: true,
    ),
    ChatItem(
      name: "Lisa Wang",
      message: "Got it, will do!",
      time: "1d ago",
      isOnline: false,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar with Chat title and profile icon
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chat',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    child: Icon(Icons.person, color: Colors.white),
                  )
                ],
              ),
            ),

            // Search bar - Updated to match the new template
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                          color: isTeamsSelected ? Color(0xFF1A2B4A) : Colors.grey[200],
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                        child: Center(
                          child: Text(
                            'Teams',
                            style: TextStyle(
                              color: isTeamsSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w500,
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
                          color: !isTeamsSelected ? Color(0xFF1A2B4A) : Colors.grey[200],
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                        child: Center(
                          child: Text(
                            'Members',
                            style: TextStyle(
                              color: !isTeamsSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // All chats label
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
              child: Text(
                'All chats',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ),

            // Chat list
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: chats.length,
                separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[200]),
                itemBuilder: (context, index) {
                  return ChatListItem(chat: chats[index]);
                },
              ),
            ),

            // Bottom navigation bar - Updated to match template styling
            NavBar(
              selectedIndex: 2, // Chat is selected (index 2)
              onTap: (index) {
                print('Navigation item $index tapped');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ChatItem {
  final String name;
  final String message;
  final String time;
  final bool isOnline;

  ChatItem({
    required this.name,
    required this.message,
    required this.time,
    required this.isOnline,
  });
}

class ChatListItem extends StatelessWidget {
  final ChatItem chat;

  const ChatListItem({
    Key? key,
    required this.chat,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left section with user info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      chat.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1A2B4A),
                      ),
                    ),
                    Text(
                      chat.time,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  chat.message,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: chat.isOnline ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      chat.isOnline ? 'online' : 'offline',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
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
}

// Updated Search Field component from template
class SearchField extends StatelessWidget {
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final VoidCallback? onTap;

  const SearchField({
    Key? key,
    this.controller,
    this.onChanged,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFF060D17)),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        children: [
          // Search Icon
          const Padding(
            padding: EdgeInsets.only(left: 16, right: 12),
            child: Icon(
              Icons.search,
              color: Color(0xFF999999),
              size: 20,
            ),
          ),
          // Search TextField
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              onTap: onTap,
              textAlignVertical: TextAlignVertical.center,
              decoration: const InputDecoration(
                hintText: 'Search tasks...',
                hintStyle: TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              style: const TextStyle(
                color: Color(0xFF192F5D),
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Navigation Bar component from template
class NavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const NavBar({
    Key? key,
    required this.selectedIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.dashboard_outlined, 'Dashboard', 0),
          _buildNavItem(1, Icons.assignment_outlined, 'Tasks', 0),
          _buildNavItem(2, Icons.chat_bubble_outline, 'Chat', 0),
          _buildNavItem(3, Icons.calendar_today_outlined, 'Calendar', 0),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, int badgeCount) {
    final bool isSelected = selectedIndex == index;
    final Color iconColor = isSelected ? Color(0xFF192F5D) : Colors.grey;
    final Color textColor = isSelected ? Color(0xFF192F5D) : Colors.grey;
    final double iconSize = 24.0;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              Icon(
                icon,
                color: iconColor,
                size: iconSize,
              ),
              if (badgeCount > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Center(
                      child: Text(
                        badgeCount.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}