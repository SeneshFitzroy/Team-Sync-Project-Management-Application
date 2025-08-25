import 'package:flutter/material.dart';
import '../Services/chat_service.dart';
import '../Services/auth_service.dart';
import '../models/chat_model.dart';
import '../models/user_model.dart';
import 'IndividualChat.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
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
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDirectChatsTab(),
          _buildProjectChatsTab(),
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
              ],
            ),
          );
        }

        final chatRooms = snapshot.data ?? [];

        if (chatRooms.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No chats yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
                SizedBox(height: 8),
                Text('Start a conversation by tapping the + button', 
                     style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: chatRooms.length,
          itemBuilder: (context, index) {
            final chatRoom = chatRooms[index];
            final currentUserId = AuthService.currentUserId;
            final otherUserId = chatRoom.participants.firstWhere(
              (id) => id != currentUserId,
              orElse: () => '',
            );
            final otherUserName = chatRoom.participantNames[otherUserId] ?? 'Unknown User';

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    otherUserName.isNotEmpty ? otherUserName[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(otherUserName),
                subtitle: chatRoom.lastMessage != null
                    ? Text(
                        chatRoom.lastMessage!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : const Text('No messages yet'),
                onTap: () async {
                  try {
                    final chatRoomId = await ChatService.createOrGetChatRoom(otherUserId);
                    if (mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => IndividualChat(
                            chatRoomId: chatRoomId,
                            receiverId: otherUserId,
                            receiverName: otherUserName,
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProjectChatsTab() {
    return StreamBuilder<List<ProjectChatRoom>>(
      stream: ChatService.getUserProjectChats(),
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
              ],
            ),
          );
        }

        final projectChats = snapshot.data ?? [];

        if (projectChats.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.group_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No project chats yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
                SizedBox(height: 8),
                Text('Project chats will appear when you join projects',
                     style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: projectChats.length,
          itemBuilder: (context, index) {
            final projectChat = projectChats[index];
            final memberCount = projectChat.members.length;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.deepPurple,
                  child: Icon(Icons.group, color: Colors.white),
                ),
                title: Text(projectChat.projectName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$memberCount members', 
                         style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    if (projectChat.lastMessage != null)
                      Text(
                        projectChat.lastMessage!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Opening ${projectChat.projectName} chat...')),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  void _showNewChatDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: double.maxFinite,
          height: 500,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'Select User to Chat',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List<UserModel>>(
                  future: ChatService.getAllUsers(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final users = snapshot.data ?? [];

                    if (users.isEmpty) {
                      return const Center(child: Text('No users found'));
                    }

                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primary,
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
                              if (mounted) {
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
                              }
                            } catch (e) {
                              Navigator.pop(context);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
