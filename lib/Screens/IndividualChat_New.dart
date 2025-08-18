import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Services/chat_service.dart';
import '../models/chat_model.dart';
import '../theme/app_theme.dart';

class IndividualChatScreen extends StatefulWidget {
  final String chatName;
  final String chatType;
  final String? receiverId;

  const IndividualChatScreen({
    super.key,
    required this.chatName,
    this.chatType = 'individual',
    this.receiverId,
  });

  @override
  State<IndividualChatScreen> createState() => _IndividualChatScreenState();
}

class _IndividualChatScreenState extends State<IndividualChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _chatRoomId;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _initializeChat();
  }

  void _initializeChat() async {
    if (_currentUser != null && widget.receiverId != null) {
      try {
        _chatRoomId = await ChatService.createOrGetChatRoom(widget.receiverId!);
        setState(() {});
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initialize chat: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _currentUser == null || _chatRoomId == null || widget.receiverId == null) return;

    final message = _messageController.text.trim();
    _messageController.clear();

    try {
      await ChatService.sendMessage(
        chatRoomId: _chatRoomId!,
        receiverId: widget.receiverId!,
        message: message,
      );

      // Scroll to bottom after sending message
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send message: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildMessageBubble(ChatMessage message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.primaryBlue : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(
                message.senderName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                  fontFamily: AppTheme.fontFamily,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              message.message,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 16,
                fontFamily: AppTheme.fontFamily,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(message.timestamp),
              style: TextStyle(
                fontSize: 10,
                color: isMe ? Colors.white70 : Colors.grey[500],
                fontFamily: AppTheme.fontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDate == today) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.day}/${timestamp.month} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Chat',
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text(
            'Please log in to access chat',
            style: TextStyle(
              fontSize: 16,
              fontFamily: AppTheme.fontFamily,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.chatName,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _chatRoomId != null ? ChatService.getMessages(_chatRoomId!) : null,
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
                          Icons.error,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading messages',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontFamily: AppTheme.fontFamily,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontFamily: AppTheme.fontFamily,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontFamily: AppTheme.fontFamily,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start the conversation!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                            fontFamily: AppTheme.fontFamily,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Auto-scroll to bottom when new messages arrive
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == _currentUser!.uid;
                    return _buildMessageBubble(message, isMe);
                  },
                );
              },
            ),
          ),

          // Message input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.withOpacity(0.2)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        color: Colors.grey[500],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(color: AppTheme.primaryBlue),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                    ),
                    maxLines: null,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
