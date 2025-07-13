import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/conversation_header_widget.dart';
import './widgets/message_bubble_widget.dart';
import './widgets/message_input_widget.dart';
import './widgets/typing_indicator_widget.dart';

class ChatMessagesScreen extends StatefulWidget {
  const ChatMessagesScreen({Key? key}) : super(key: key);

  @override
  State<ChatMessagesScreen> createState() => _ChatMessagesScreenState();
}

class _ChatMessagesScreenState extends State<ChatMessagesScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();
  bool _isTyping = false;
  bool _isLoading = false;
  String _selectedMessageId = '';

  // Mock conversation data
  final Map<String, dynamic> conversationData = {
    "id": "conv_001",
    "type": "group", // "direct" or "group"
    "name": "Aventureiros SP",
    "participants": [
      {
        "id": "user_001",
        "name": "Carlos Silva",
        "avatar":
            "https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg",
        "isOnline": true,
        "lastSeen": "2025-07-13T06:20:00Z",
      },
      {
        "id": "user_002",
        "name": "Ana Costa",
        "avatar":
            "https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg",
        "isOnline": false,
        "lastSeen": "2025-07-13T05:45:00Z",
      },
      {
        "id": "user_003",
        "name": "Miguel Santos",
        "avatar":
            "https://images.pexels.com/photos/1222271/pexels-photo-1222271.jpeg",
        "isOnline": true,
        "lastSeen": "2025-07-13T06:22:00Z",
      },
    ],
  };

  final List<Map<String, dynamic>> messages = [
    {
      "id": "msg_001",
      "senderId": "user_002",
      "senderName": "Ana Costa",
      "senderAvatar":
          "https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg",
      "content": "Pessoal, quem topa uma trilha no fim de semana?",
      "type": "text",
      "timestamp": "2025-07-13T05:30:00Z",
      "status": "read",
      "isCurrentUser": false,
    },
    {
      "id": "msg_002",
      "senderId": "user_001",
      "senderName": "Carlos Silva",
      "senderAvatar":
          "https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg",
      "content": "Eu topo! Que tal a Serra da Mantiqueira?",
      "type": "text",
      "timestamp": "2025-07-13T05:32:00Z",
      "status": "read",
      "isCurrentUser": true,
    },
    {
      "id": "msg_003",
      "senderId": "user_003",
      "senderName": "Miguel Santos",
      "senderAvatar":
          "https://images.pexels.com/photos/1222271/pexels-photo-1222271.jpeg",
      "content":
          "https://images.pexels.com/photos/163210/motorcycles-race-helmets-pilots-163210.jpeg",
      "type": "image",
      "timestamp": "2025-07-13T05:35:00Z",
      "status": "read",
      "isCurrentUser": false,
      "caption": "Minha nova moto chegou! 🏍️",
    },
    {
      "id": "msg_004",
      "senderId": "user_001",
      "senderName": "Carlos Silva",
      "senderAvatar":
          "https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg",
      "content": "Que máquina! Vamos testar ela na trilha 😎",
      "type": "text",
      "timestamp": "2025-07-13T05:37:00Z",
      "status": "read",
      "isCurrentUser": true,
    },
    {
      "id": "msg_005",
      "senderId": "user_002",
      "senderName": "Ana Costa",
      "senderAvatar":
          "https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg",
      "content": "Compartilhando minha localização",
      "type": "location",
      "timestamp": "2025-07-13T05:40:00Z",
      "status": "delivered",
      "isCurrentUser": false,
      "locationData": {
        "latitude": -23.5505,
        "longitude": -46.6333,
        "address": "São Paulo, SP, Brasil",
      },
    },
    {
      "id": "msg_006",
      "senderId": "user_003",
      "senderName": "Miguel Santos",
      "senderAvatar":
          "https://images.pexels.com/photos/1222271/pexels-photo-1222271.jpeg",
      "content": "Rota compartilhada: Trilha da Pedra Grande",
      "type": "route",
      "timestamp": "2025-07-13T06:00:00Z",
      "status": "read",
      "isCurrentUser": false,
      "routeData": {
        "name": "Trilha da Pedra Grande",
        "distance": "45.2 km",
        "duration": "2h 30min",
        "difficulty": "Intermediário",
        "thumbnail":
            "https://images.pexels.com/photos/1624438/pexels-photo-1624438.jpeg",
      },
    },
    {
      "id": "msg_007",
      "senderId": "user_001",
      "senderName": "Carlos Silva",
      "senderAvatar":
          "https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg",
      "content": "Perfeito! Vamos nos encontrar às 8h no posto da entrada",
      "type": "text",
      "timestamp": "2025-07-13T06:15:00Z",
      "status": "sent",
      "isCurrentUser": true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _messageController.addListener(_onTypingChanged);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreMessages();
    }
  }

  void _onTypingChanged() {
    final isTyping = _messageController.text.isNotEmpty;
    if (isTyping != _isTyping) {
      setState(() {
        _isTyping = isTyping;
      });
    }
  }

  void _loadMoreMessages() {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });

      // Simulate loading delay
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _isLoading = false;
        });
      });
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final newMessage = {
      "id": "msg_${DateTime.now().millisecondsSinceEpoch}",
      "senderId": "user_001",
      "senderName": "Carlos Silva",
      "senderAvatar":
          "https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg",
      "content": _messageController.text.trim(),
      "type": "text",
      "timestamp": DateTime.now().toIso8601String(),
      "status": "sending",
      "isCurrentUser": true,
    };

    setState(() {
      messages.add(newMessage);
      _messageController.clear();
    });

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    // Simulate message delivery
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        final index = messages.indexWhere(
          (msg) => msg["id"] == newMessage["id"],
        );
        if (index != -1) {
          messages[index]["status"] = "delivered";
        }
      });
    });
  }

  void _onMessageLongPress(String messageId) {
    setState(() {
      _selectedMessageId = messageId;
    });
    _showMessageOptions(messageId);
  }

  void _showMessageOptions(String messageId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4,
              margin: EdgeInsets.symmetric(vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'reply',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text(
                'Responder',
                style: AppTheme.lightTheme.textTheme.bodyLarge,
              ),
              onTap: () {
                Navigator.pop(context);
                _replyToMessage(messageId);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'content_copy',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 24,
              ),
              title: Text(
                'Copiar',
                style: AppTheme.lightTheme.textTheme.bodyLarge,
              ),
              onTap: () {
                Navigator.pop(context);
                _copyMessage(messageId);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'delete',
                color: AppTheme.errorLight,
                size: 24,
              ),
              title: Text(
                'Excluir',
                style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.errorLight,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _deleteMessage(messageId);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'report',
                color: AppTheme.warningLight,
                size: 24,
              ),
              title: Text(
                'Denunciar',
                style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.warningLight,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _reportMessage(messageId);
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _replyToMessage(String messageId) {
    final message = messages.firstWhere((msg) => msg["id"] == messageId);
    _messageFocusNode.requestFocus();
    // Implementation for reply functionality
  }

  void _copyMessage(String messageId) {
    final message = messages.firstWhere((msg) => msg["id"] == messageId);
    // Implementation for copy functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Mensagem copiada')));
  }

  void _deleteMessage(String messageId) {
    setState(() {
      messages.removeWhere((msg) => msg["id"] == messageId);
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Mensagem excluída')));
  }

  void _reportMessage(String messageId) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Mensagem denunciada')));
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4,
              margin: EdgeInsets.symmetric(vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'Compartilhar',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
            ),
            SizedBox(height: 2.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  icon: 'camera_alt',
                  label: 'Câmera',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  onTap: () {
                    Navigator.pop(context);
                    _openCamera();
                  },
                ),
                _buildAttachmentOption(
                  icon: 'photo_library',
                  label: 'Galeria',
                  color: AppTheme.successLight,
                  onTap: () {
                    Navigator.pop(context);
                    _openGallery();
                  },
                ),
                _buildAttachmentOption(
                  icon: 'location_on',
                  label: 'Localização',
                  color: AppTheme.warningLight,
                  onTap: () {
                    Navigator.pop(context);
                    _shareLocation();
                  },
                ),
                _buildAttachmentOption(
                  icon: 'route',
                  label: 'Rota',
                  color: AppTheme.accentLight,
                  onTap: () {
                    Navigator.pop(context);
                    _shareRoute();
                  },
                ),
              ],
            ),
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required String icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 15.w,
            height: 15.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: CustomIconWidget(iconName: icon, color: color, size: 24),
            ),
          ),
          SizedBox(height: 1.h),
          Text(label, style: AppTheme.lightTheme.textTheme.bodySmall),
        ],
      ),
    );
  }

  void _openCamera() {
    // Implementation for camera functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Abrindo câmera...')));
  }

  void _openGallery() {
    // Implementation for gallery functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Abrindo galeria...')));
  }

  void _shareLocation() {
    // Implementation for location sharing
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Compartilhando localização...')));
  }

  void _shareRoute() {
    // Implementation for route sharing
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Compartilhando rota...')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            ConversationHeaderWidget(
              conversationData: conversationData,
              onBackPressed: () => Navigator.pop(context),
              onInfoPressed: () {
                // Navigate to group/user info
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Informações do grupo')));
              },
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  _loadMoreMessages();
                  await Future.delayed(const Duration(seconds: 1));
                },
                child: ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  itemCount: messages.length + (_isLoading ? 1 : 0) + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return TypingIndicatorWidget(
                        participants: (conversationData["participants"] as List)
                            .where(
                              (p) =>
                                  p["id"] != "user_001" &&
                                  p["isOnline"] == true,
                            )
                            .toList(),
                      );
                    }

                    if (_isLoading && index == 1) {
                      return Container(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.lightTheme.colorScheme.primary,
                          ),
                        ),
                      );
                    }

                    final messageIndex = _isLoading ? index - 2 : index - 1;
                    if (messageIndex >= messages.length)
                      return const SizedBox.shrink();

                    final message =
                        messages[messages.length - 1 - messageIndex];
                    final isSelected = _selectedMessageId == message["id"];

                    return MessageBubbleWidget(
                      message: message,
                      isSelected: isSelected,
                      onLongPress: () => _onMessageLongPress(message["id"]),
                      onTap: () {
                        if (_selectedMessageId.isNotEmpty) {
                          setState(() {
                            _selectedMessageId = '';
                          });
                        }
                      },
                    );
                  },
                ),
              ),
            ),
            MessageInputWidget(
              controller: _messageController,
              focusNode: _messageFocusNode,
              onSendPressed: _sendMessage,
              onAttachmentPressed: _showAttachmentOptions,
            ),
          ],
        ),
      ),
    );
  }
}
