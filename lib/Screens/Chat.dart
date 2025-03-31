import 'package:flutter/material.dart';
import '../Components/nav_bar.dart';
import './Dashboard.dart';
import './TaskManager.dart';
import './Calendar.dart';
import './Profile.dart'; // Add this import

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  bool _isTeamsTab = true;
  int _currentIndex = 2; // Set to 2 for Chat tab
  final List<String> _teams = ['Product Launch Team', 'Marketing Team', 'Development Team'];
  final List<String> _members = ['Alice', 'Bob', 'Charlie', 'David', 'Eve'];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _isTeamsTab = _tabController.index == 0;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onNavBarTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    // Navigate to the appropriate screen based on index
    if (index != 2) { // If not Chat tab (since we're already in Chat)
      switch (index) {
        case 0: // Dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Dashboard()),
          );
          break;
        case 1: // Tasks
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const TaskManager()),
          );
          break;
        case 3: // Calendar
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Calendar()),
          );
          break;
      }
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  List<String> _getFilteredTeams() {
    return _teams
        .where((team) => team.toLowerCase().contains(_searchQuery))
        .toList();
  }

  List<String> _getFilteredMembers() {
    return _members
        .where((member) => member.toLowerCase().contains(_searchQuery))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove the back button
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Chat',
          style: TextStyle(
            color: Color(0xFF192F5D),
            fontSize: 20,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              // Navigate to Profile page when user icon is tapped
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            child: CircleAvatar(
              backgroundColor: Colors.grey[200],
              child: const Icon(Icons.person, color: Color(0xFF192F5D)),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Search bar with functionality
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Color(0xFF999999)),
                hintText: 'Search...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          
          // Custom Tab Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _tabController.animateTo(0);
                    },
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: _isTeamsTab 
                            ? const Color(0xFF192F5D) 
                            : Colors.white,
                        border: Border.all(color: const Color(0xFF192F5D)),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Center(
                        child: Text(
                          'Teams',
                          style: TextStyle(
                            color: _isTeamsTab 
                                ? Colors.white 
                                : const Color(0xFF192F5D),
                            fontSize: 16,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _tabController.animateTo(1);
                    },
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: !_isTeamsTab 
                            ? const Color(0xFF192F5D) 
                            : Colors.white,
                        border: Border.all(color: const Color(0xFF192F5D)),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Center(
                        child: Text(
                          'Members',
                          style: TextStyle(
                            color: !_isTeamsTab 
                                ? Colors.white 
                                : const Color(0xFF192F5D),
                            fontSize: 16,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Teams Tab with dynamic filtering
                ListView.builder(
                  itemCount: _getFilteredTeams().length,
                  itemBuilder: (context, index) {
                    final team = _getFilteredTeams()[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.withOpacity(0.2)),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  team,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Text(
                                  '10:45 AM',
                                  style: TextStyle(
                                    color: Color(0xFF666666),
                                    fontSize: 12,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Sarah: Updated the mockups',
                              style: TextStyle(
                                color: Color(0xFF666666),
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
                // Members Tab with dynamic filtering
                ListView.builder(
                  itemCount: _getFilteredMembers().length,
                  itemBuilder: (context, index) {
                    final member = _getFilteredMembers()[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey[300],
                        child: const Icon(Icons.person, color: Color.fromARGB(255, 85, 84, 84)),
                      ),
                      title: Text(member),
                      subtitle: Text(index % 2 == 0 ? 'Online' : 'Last seen 2h ago'),
                      trailing: index % 3 == 0 
                          ? Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ) 
                          : null,
                    );
                  },
                ),
              ],
            ),
          ),
          
          // Message input (when in a chat)
          // Uncomment when implementing full chat functionality
          /*
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Color(0xFF192F5D)),
                  onPressed: () {
                    // Send message logic
                    if (_messageController.text.isNotEmpty) {
                      // Handle sending message
                      _messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
          */
        ],
      ),
      bottomNavigationBar: NavBar(
        selectedIndex: _currentIndex,
        onTap: _onNavBarTap,
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected, {int? badgeCount}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF150303) : const Color(0xFF666666),
            ),
            if (badgeCount != null)
              Positioned(
                right: -10,
                top: -5,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF1212),
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Center(
                    child: Text(
                      badgeCount.toString(),
                      style: const TextStyle(
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
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF150303) : const Color(0xFF666666),
            fontSize: 12,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
