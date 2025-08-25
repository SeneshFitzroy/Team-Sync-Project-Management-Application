import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/chat_model.dart';
import '../models/user_model.dart';
import '../models/project.dart';
import '../Services/chat_service.dart';
import '../Services/auth_service.dart';
import '../Services/firebase_service.dart';
import 'IndividualChat.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Direct Messages'),
            Tab(text: 'Project Chats'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment),
            onPressed: _showNewChatDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search chats...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDirectChatsTab(),
                _buildProjectChatsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectChatsTab() {
    return StreamBuilder<List<ChatRoom>>(
      stream: ChatService.getUserChatRooms(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {});
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final chatRooms = snapshot.data ?? [];
        final filteredChatRooms = chatRooms.where((chatRoom) {
          return chatRoom.otherUserName?.toLowerCase().contains(_searchQuery) ?? false;
        }).toList();

        if (filteredChatRooms.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isEmpty ? 'No chats yet' : 'No chats found',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  _searchQuery.isEmpty
                      ? 'Start a conversation by tapping the + button'
                      : 'Try a different search term',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: filteredChatRooms.length,
          itemBuilder: (context, index) {
            final chatRoom = filteredChatRooms[index];
            return _buildChatRoomTile(chatRoom);
          },
        );
      },
    );
  }

  Widget _buildProjectChatsTab() {
    return StreamBuilder<List<ProjectChatRoom>>(
      stream: ChatService.getUserProjectChatRooms(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {});
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final projectChatRooms = snapshot.data ?? [];
        final filteredProjectChatRooms = projectChatRooms.where((chatRoom) {
          return chatRoom.projectName.toLowerCase().contains(_searchQuery);
        }).toList();

        if (filteredProjectChatRooms.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.group_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isEmpty ? 'No project chats yet' : 'No project chats found',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  _searchQuery.isEmpty
                      ? 'Project chats are created automatically when you join a project'
                      : 'Try a different search term',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: filteredProjectChatRooms.length,
          itemBuilder: (context, index) {
            final projectChatRoom = filteredProjectChatRooms[index];
            return _buildProjectChatRoomTile(projectChatRoom);
          },
        );
      },
    );
  }

  Widget _buildChatRoomTile(ChatRoom chatRoom) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            chatRoom.otherUserName?.isNotEmpty == true 
                ? chatRoom.otherUserName![0].toUpperCase() 
                : '?',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          chatRoom.otherUserName ?? 'Unknown User',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              chatRoom.lastMessage?.isNotEmpty == true 
                  ? chatRoom.lastMessage! 
                  : 'No messages yet',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (chatRoom.lastMessageTime != null) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  DateFormat('MMM dd, HH:mm').format(chatRoom.lastMessageTime!),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ],
        ),
        trailing: chatRoom.unreadCount > 0
            ? Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  chatRoom.unreadCount.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              )
            : null,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => IndividualChat(
                chatRoomId: chatRoom.id,
                receiverId: chatRoom.otherUserId,
                receiverName: chatRoom.otherUserName ?? 'Unknown User',
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProjectChatRoomTile(ProjectChatRoom projectChatRoom) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green,
          child: Text(
            projectChatRoom.projectName.isNotEmpty 
                ? projectChatRoom.projectName[0].toUpperCase() 
                : 'P',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          projectChatRoom.projectName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${projectChatRoom.memberCount} members',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            if (projectChatRoom.lastMessage?.isNotEmpty == true) ...[
              const SizedBox(height: 4),
              Text(
                projectChatRoom.lastMessage!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (projectChatRoom.lastMessageTime != null) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  DateFormat('MMM dd, HH:mm').format(projectChatRoom.lastMessageTime!),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ],
        ),
        trailing: projectChatRoom.unreadCount > 0
            ? Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  projectChatRoom.unreadCount.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              )
            : null,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => IndividualChat(
                chatRoomId: projectChatRoom.id,
                receiverId: '', // Project chat doesn't have a single receiver
                receiverName: projectChatRoom.projectName,
                isProjectChat: true,
              ),
            ),
          );
        },
      ),
    );
  }

  void _showNewChatDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Start New Chat'),
          content: const Text('Select a user to start chatting with:'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showUserSelectionDialog();
              },
              child: const Text('Select User'),
            ),
          ],
        );
      },
    );
  }

  void _showUserSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select User'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: StreamBuilder<List<UserModel>>(
              stream: FirebaseService.getAllUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final users = snapshot.data ?? [];
                final currentUserId = AuthService.getCurrentUserId();
                final filteredUsers = users.where((user) => user.uid != currentUserId).toList();

                if (filteredUsers.isEmpty) {
                  return const Center(child: Text('No users available'));
                }

                return ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Text(
                          user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(user.fullName),
                      subtitle: Text(user.email),
                      onTap: () async {
                        try {
                          final chatRoomId = await ChatService.createOrGetChatRoom(user.uid);
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => IndividualChat(
                                chatRoomId: chatRoomId,
                                receiverId: user.uid,
                                receiverName: user.fullName,
                              ),
                            ),
                          );
                        } catch (e) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error creating chat: $e')),
                          );
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
