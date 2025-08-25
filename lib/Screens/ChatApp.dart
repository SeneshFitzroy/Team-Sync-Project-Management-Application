import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Chat extends StatefulWidget {
  const Chat({Key? key}) : super(key: key);

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  int _selectedChatIndex = 0;
  
  // Sample chat contacts
  final List<Map<String, dynamic>> _chatContacts = [
    {
      'id': '1',
      'name': 'John Doe',
      'avatar': 'JD',
      'isOnline': true,
      'lastMessage': 'Hey! How\'s the project going?',
      'lastMessageTime': DateTime.now().subtract(const Duration(minutes: 5)),
      'unreadCount': 2,
      'color': Colors.blue,
    },
    {
      'id': '2',
      'name': 'Sarah Wilson',
      'avatar': 'SW',
      'isOnline': true,
      'lastMessage': 'The design looks great!',
      'lastMessageTime': DateTime.now().subtract(const Duration(hours: 1)),
      'unreadCount': 0,
      'color': Colors.purple,
    },
    {
      'id': '3',
      'name': 'Team Project',
      'avatar': 'TP',
      'isOnline': false,
      'lastMessage': 'Meeting at 3 PM tomorrow',
      'lastMessageTime': DateTime.now().subtract(const Duration(hours: 2)),
      'unreadCount': 5,
      'color': Colors.green,
    },
    {
      'id': '4',
      'name': 'Mike Johnson',
      'avatar': 'MJ',
      'isOnline': false,
      'lastMessage': 'Thanks for the help!',
      'lastMessageTime': DateTime.now().subtract(const Duration(days: 1)),
      'unreadCount': 0,
      'color': Colors.orange,
    },
  ];

  // Sample messages for each chat
  final Map<String, List<Map<String, dynamic>>> _chatMessages = {
    '1': [
      {
        'id': '1',
        'text': 'Hey! How\'s the project going?',
        'senderName': 'John Doe',
        'isMe': false,
        'timestamp': DateTime.now().subtract(const Duration(minutes: 10)),
      },
      {
        'id': '2',
        'text': 'It\'s going well! Just finished the login page.',
        'senderName': 'Me',
        'isMe': true,
        'timestamp': DateTime.now().subtract(const Duration(minutes: 8)),
      },
    ],
    '2': [
      {
        'id': '1',
        'text': 'The design looks great!',
        'senderName': 'Sarah Wilson',
        'isMe': false,
        'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
      },
    ],
    '3': [
      {
        'id': '1',
        'text': 'Meeting at 3 PM tomorrow',
        'senderName': 'Team Lead',
        'isMe': false,
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      },
    ],
    '4': [
      {
        'id': '1',
        'text': 'Thanks for the help!',
        'senderName': 'Mike Johnson',
        'isMe': false,
        'timestamp': DateTime.now().subtract(const Duration(days: 1)),
      },
    ],
  };

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar with chat list
          Container(
            width: 320,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                right: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Column(
              children: [
                // Sidebar header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.chat, color: Colors.white),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Chats',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Chat list
                Expanded(
                  child: ListView.builder(
                    itemCount: _chatContacts.length,
                    itemBuilder: (context, index) {
                      final contact = _chatContacts[index];
                      final isSelected = index == _selectedChatIndex;
                      return _buildChatListTile(contact, index, isSelected);
                    },
                  ),
                ),
              ],
            ),
          ),
          // Main chat area
          Expanded(
            child: _buildChatArea(),
          ),
        ],
      ),
    );
  }

  Widget _buildChatListTile(Map<String, dynamic> contact, int index, bool isSelected) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue[50] : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: contact['color'],
              child: Text(
                contact['avatar'],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (contact['isOnline'])
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          contact['name'],
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.blue : Colors.black,
          ),
        ),
        subtitle: Text(
          contact['lastMessage'],
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isSelected ? Colors.blue[700] : Colors.grey[600],
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatTime(contact['lastMessageTime']),
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.blue : Colors.grey,
              ),
            ),
            if (contact['unreadCount'] > 0) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  contact['unreadCount'].toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        onTap: () {
          setState(() {
            _selectedChatIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildChatArea() {
    final currentContact = _chatContacts[_selectedChatIndex];
    final messages = _chatMessages[currentContact['id']] ?? [];

    return Column(
      children: [
        // Chat header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    backgroundColor: currentContact['color'],
                    child: Text(
                      currentContact['avatar'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (currentContact['isOnline'])
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentContact['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      currentContact['isOnline'] ? 'Online' : 'Last seen recently',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.videocam, color: Colors.blue),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Video call feature coming soon!')),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.call, color: Colors.blue),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Voice call feature coming soon!')),
                  );
                },
              ),
            ],
          ),
        ),
        // Messages area
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
            ),
            child: messages.isEmpty
                ? Center(
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
                          'No messages yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start the conversation by sending a message',
                          style: TextStyle(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return _buildMessageBubble(message, currentContact['color']);
                    },
                  ),
          ),
        ),
        // Message input
        _buildMessageInput(currentContact),
      ],
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, Color contactColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: message['isMe'] ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message['isMe']) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: contactColor,
              child: Text(
                message['senderName'].isNotEmpty ? message['senderName'][0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message['isMe'] ? Colors.blue : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: message['isMe'] ? const Radius.circular(20) : const Radius.circular(4),
                  bottomRight: message['isMe'] ? const Radius.circular(4) : const Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!message['isMe'])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        message['senderName'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: contactColor,
                        ),
                      ),
                    ),
                  Text(
                    message['text'],
                    style: TextStyle(
                      color: message['isMe'] ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTimestamp(message['timestamp']),
                    style: TextStyle(
                      fontSize: 12,
                      color: message['isMe'] ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message['isMe']) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.green,
              child: Text(
                'M',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput(Map<String, dynamic> contact) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file, color: Colors.grey),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Attachment feature coming soon!')),
              );
            },
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message to ${contact['name']}...',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: contact['color'],
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) {
      return;
    }

    final messageText = _messageController.text.trim();
    final currentContact = _chatContacts[_selectedChatIndex];
    
    final newMessage = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'text': messageText,
      'senderName': 'Me',
      'isMe': true,
      'timestamp': DateTime.now(),
    };

    setState(() {
      _chatMessages[currentContact['id']]?.add(newMessage);
      _messageController.clear();
      
      // Update last message in contact
      currentContact['lastMessage'] = messageText;
      currentContact['lastMessageTime'] = DateTime.now();
    });

    // Auto-scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // Simulate a reply after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        final replyMessage = {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'text': _getRandomReply(),
          'senderName': currentContact['name'],
          'isMe': false,
          'timestamp': DateTime.now(),
        };

        setState(() {
          _chatMessages[currentContact['id']]?.add(replyMessage);
          currentContact['lastMessage'] = replyMessage['text'];
          currentContact['lastMessageTime'] = DateTime.now();
        });

        // Auto-scroll to bottom for reply
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });
  }

  String _getRandomReply() {
    final replies = [
      'Sounds good!',
      'I agree with that.',
      'Let me check and get back to you.',
      'That\'s a great idea!',
      'Perfect, thanks for the update.',
      'I\'ll work on that right away.',
      'Got it, thanks!',
      'Let\'s discuss this in our next meeting.',
      'Absolutely!',
      'I\'m on it!',
    ];
    return replies[DateTime.now().millisecondsSinceEpoch % replies.length];
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else if (now.difference(dateTime).inDays < 7) {
      return DateFormat('EEE').format(dateTime);
    } else {
      return DateFormat('dd/MM').format(dateTime);
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(timestamp.year, timestamp.month, timestamp.day);
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDate == today) {
      return DateFormat('HH:mm').format(timestamp);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday ${DateFormat('HH:mm').format(timestamp)}';
    } else if (now.difference(timestamp).inDays < 7) {
      return DateFormat('EEE HH:mm').format(timestamp);
    } else {
      return DateFormat('MMM dd, HH:mm').format(timestamp);
    }
  }
}
