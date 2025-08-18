import 'package:flutter/material.dart';
import '../Services/chat_service.dart';
import '../Services/auth_service.dart';
import '../models/chat_model.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<UserModel> _allUsers = [];
  List<UserModel> _filteredUsers = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    try {
      List<UserModel> users = await ChatService.getAllUsers();
      setState(() {
        _allUsers = users;
        _filteredUsers = users;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading users: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  void _filterUsers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = _allUsers;
      } else {
        _filteredUsers = _allUsers
            .where((user) =>
                user.fullName.toLowerCase().contains(query.toLowerCase()) ||
                user.email.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _startChat(UserModel user) async {
    try {
      String chatRoomId = await ChatService.createOrGetChatRoom(user.uid);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              chatRoomId: chatRoomId,
              otherUserId: user.uid,
              otherUserName: user.fullName,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error starting chat: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  Widget _buildChatRoomTile(ChatRoom chatRoom) {
    String? currentUserId = AuthService.currentUserId;
    if (currentUserId == null) return const SizedBox.shrink();

    String otherUserName = chatRoom.getOtherParticipantName(currentUserId);
    int unreadCount = chatRoom.getUnreadCount(currentUserId);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryBlue,
          child: Text(
            otherUserName.isNotEmpty ? otherUserName[0].toUpperCase() : 'U',
            style: const TextStyle(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        title: Text(
          otherUserName,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        subtitle: Text(
          chatRoom.lastMessage ?? 'No messages yet',
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            color: AppTheme.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (chatRoom.lastMessageTime != null)
              Text(
                _formatTime(chatRoom.lastMessageTime!),
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textLight,
                  fontFamily: AppTheme.fontFamily,
                ),
              ),
            if (unreadCount > 0) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: const BoxDecoration(
                  color: AppTheme.primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  unreadCount > 99 ? '99+' : unreadCount.toString(),
                  style: const TextStyle(
                    color: AppTheme.textWhite,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        onTap: () {
          String? otherUserId = chatRoom.getOtherParticipantId(currentUserId);
          if (otherUserId != null && otherUserId.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  chatRoomId: chatRoom.id,
                  otherUserId: otherUserId,
                  otherUserName: otherUserName,
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildUserTile(UserModel user) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryLight,
          backgroundImage: user.hasProfilePhoto 
            ? NetworkImage(user.photoURL!) 
            : null,
          child: !user.hasProfilePhoto
              ? Text(
                  user.initials,
                  style: const TextStyle(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.w600,
                  ),
                )
              : null,
        ),
        title: Text(
          user.fullName,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        subtitle: Text(
          user.email,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            color: AppTheme.textSecondary,
          ),
        ),
        trailing: const Icon(
          Icons.chat_bubble_outline,
          color: AppTheme.primaryBlue,
        ),
        onTap: () => _startChat(user),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isSearching ? 'Start New Chat' : 'Messages',
          style: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _filteredUsers = _allUsers;
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isSearching) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  hintStyle: TextStyle(
                    color: AppTheme.textLight,
                    fontFamily: AppTheme.fontFamily,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppTheme.textSecondary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.textLight.withOpacity(0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.textLight.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppTheme.primaryBlue,
                      width: 2,
                    ),
                  ),
                ),
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                ),
                onChanged: _filterUsers,
              ),
            ),
            Expanded(
              child: _filteredUsers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_search,
                            size: 48,
                            color: AppTheme.textLight,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No users found',
                            style: AppTheme.bodyLarge.copyWith(
                              color: AppTheme.textLight,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredUsers.length,
                      itemBuilder: (context, index) {
                        return _buildUserTile(_filteredUsers[index]);
                      },
                    ),
            ),
          ] else ...[
            Expanded(
              child: StreamBuilder<List<ChatRoom>>(
                stream: ChatService.getUserChatRooms(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryBlue,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: AppTheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading chats',
                            style: AppTheme.bodyLarge.copyWith(
                              color: AppTheme.error,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              setState(() {}); // Refresh
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  List<ChatRoom> chatRooms = snapshot.data ?? [];

                  if (chatRooms.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 48,
                            color: AppTheme.textLight,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No conversations yet',
                            style: AppTheme.bodyLarge.copyWith(
                              color: AppTheme.textLight,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap the search icon to start a new chat',
                            style: AppTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: chatRooms.length,
                    itemBuilder: (context, index) {
                      return _buildChatRoomTile(chatRooms[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
