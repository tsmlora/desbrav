import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_export.dart';
import '../../core/models/user_profile.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/supabase_service.dart';
import './widgets/conversation_card_widget.dart';
import './widgets/quick_actions_widget.dart';
import './widgets/user_search_modal.dart';

class DirectMessagesScreen extends StatefulWidget {
  const DirectMessagesScreen({super.key});

  @override
  State<DirectMessagesScreen> createState() => _DirectMessagesScreenState();
}

class _DirectMessagesScreenState extends State<DirectMessagesScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final SupabaseService _supabaseService = SupabaseService();

  List<Conversation> _conversations = [];
  List<Conversation> _filteredConversations = [];
  bool _isLoading = true;
  bool _isSearchActive = false;

  late AnimationController _searchAnimationController;
  late Animation<double> _searchAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadConversations();
    _setupRealTimeSubscription();
  }

  void _initializeAnimations() {
    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _searchAnimation = CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.easeInOut,
    );
  }

  Future<void> _loadConversations() async {
    try {
      setState(() => _isLoading = true);

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUserId = authProvider.currentUser?.id;

      if (currentUserId == null) return;

      final client = await _supabaseService.client;
      final response = await client
          .from('conversations')
          .select('''
            *,
            participant1:user_profiles!conversations_participant1_id_fkey(
              id, full_name, avatar_url, is_active
            ),
            participant2:user_profiles!conversations_participant2_id_fkey(
              id, full_name, avatar_url, is_active
            ),
            last_message:messages(
              id, content, sender_id, created_at, message_type
            )
          ''')
          .or('participant1_id.eq.$currentUserId,participant2_id.eq.$currentUserId')
          .order('updated_at', ascending: false);

      final conversations = (response as List).map((data) {
        return Conversation.fromJson(data, currentUserId);
      }).toList();

      setState(() {
        _conversations = conversations;
        _filteredConversations = conversations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Erro ao carregar conversas: $e');
    }
  }

  void _setupRealTimeSubscription() {
    // Listen for new messages and conversation updates
    _supabaseService.client.then((client) {
      client
          .channel('direct_messages')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'messages',
            callback: (payload) => _handleMessageUpdate(payload),
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'conversations',
            callback: (payload) => _handleConversationUpdate(payload),
          )
          .subscribe();
    });
  }

  void _handleMessageUpdate(PostgresChangePayload payload) {
    // Reload conversations when new messages arrive
    _loadConversations();
  }

  void _handleConversationUpdate(PostgresChangePayload payload) {
    // Reload conversations when conversation data changes
    _loadConversations();
  }

  void _filterConversations(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredConversations = _conversations;
      } else {
        _filteredConversations = _conversations
            .where((conversation) =>
                conversation.otherParticipantName
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                (conversation.lastMessage?.content
                        .toLowerCase()
                        .contains(query.toLowerCase()) ??
                    false))
            .toList();
      }
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearchActive = !_isSearchActive;
      if (!_isSearchActive) {
        _searchController.clear();
        _filteredConversations = _conversations;
        _searchAnimationController.reverse();
      } else {
        _searchAnimationController.forward();
      }
    });
  }

  void _openNewMessageModal() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UserSearchModal(
        onUserSelected: _startNewConversation,
      ),
    );
  }

  Future<void> _startNewConversation(UserProfile selectedUser) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUserId = authProvider.currentUser?.id;

      if (currentUserId == null) return;

      // Check if conversation already exists
      final existingConversation = _conversations.firstWhere(
        (conv) => conv.otherParticipantId == selectedUser.id,
        orElse: () => Conversation.empty(),
      );

      if (existingConversation.id.isNotEmpty) {
        // Navigate to existing conversation
        Navigator.pushNamed(
          context,
          AppRoutes.chatMessagesScreen,
          arguments: {
            'conversationId': existingConversation.id,
            'recipientName': existingConversation.otherParticipantName,
            'recipientAvatar': existingConversation.otherParticipantAvatar,
          },
        );
        return;
      }

      // Create new conversation
      final client = await _supabaseService.client;
      final response = await client
          .from('conversations')
          .insert({
            'participant1_id': currentUserId,
            'participant2_id': selectedUser.id,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      final newConversationId = response['id'] as String;

      // Navigate to new conversation
      Navigator.pushNamed(
        context,
        AppRoutes.chatMessagesScreen,
        arguments: {
          'conversationId': newConversationId,
          'recipientName': selectedUser.fullName,
          'recipientAvatar': selectedUser.avatarUrl,
        },
      );

      // Reload conversations
      await _loadConversations();
    } catch (e) {
      _showErrorSnackBar('Erro ao iniciar conversa: $e');
    }
  }

  void _openConversation(Conversation conversation) {
    HapticFeedback.selectionClick();
    Navigator.pushNamed(
      context,
      AppRoutes.chatMessagesScreen,
      arguments: {
        'conversationId': conversation.id,
        'recipientName': conversation.otherParticipantName,
        'recipientAvatar': conversation.otherParticipantAvatar,
      },
    ).then((_) {
      // Reload conversations when returning from chat
      _loadConversations();
    });
  }

  void _showQuickActions(Conversation conversation) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickActionsWidget(
        conversation: conversation,
        context: context,
        onMute: () => _muteConversation(conversation),
        onMarkUnread: () => _markAsUnread(conversation),
        onDelete: () => _deleteConversation(conversation),
        onBlock: () => _blockUser(conversation),
      ),
    );
  }

  Future<void> _muteConversation(Conversation conversation) async {
    // Implement mute functionality
    _showInfoSnackBar('Conversa silenciada');
  }

  Future<void> _markAsUnread(Conversation conversation) async {
    // Implement mark as unread functionality
    _showInfoSnackBar('Marcada como não lida');
  }

  Future<void> _deleteConversation(Conversation conversation) async {
    try {
      final client = await _supabaseService.client;
      await client.from('conversations').delete().eq('id', conversation.id);

      await _loadConversations();
      _showInfoSnackBar('Conversa deletada');
    } catch (e) {
      _showErrorSnackBar('Erro ao deletar conversa: $e');
    }
  }

  Future<void> _blockUser(Conversation conversation) async {
    // Implement block user functionality
    _showInfoSnackBar('Usuário bloqueado');
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorLight,
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successLight,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      elevation: 0,
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isSearchActive
            ? TextField(
                controller: _searchController,
                onChanged: _filterConversations,
                decoration: InputDecoration(
                  hintText: 'Pesquisar conversas...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
                style: AppTheme.lightTheme.textTheme.titleMedium,
                autofocus: true,
              )
            : Text(
                'Mensagens Diretas',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
      actions: [
        IconButton(
          onPressed: _toggleSearch,
          icon: CustomIconWidget(
            iconName: _isSearchActive ? 'close' : 'search',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppTheme.lightTheme.colorScheme.primary,
        ),
      );
    }

    if (_filteredConversations.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadConversations,
      color: AppTheme.lightTheme.colorScheme.primary,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 1.h),
        itemCount: _filteredConversations.length,
        itemBuilder: (context, index) {
          final conversation = _filteredConversations[index];
          return ConversationCardWidget(
            conversation: conversation,
            onTap: () => _openConversation(conversation),
            onLongPress: () => _showQuickActions(conversation),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: CustomIconWidget(
              iconName: 'chat_bubble_outline',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 48,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            'Nenhuma conversa ainda',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Inicie uma conversa com outros motociclistas\nda comunidade Desbrav',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          ElevatedButton.icon(
            onPressed: _openNewMessageModal,
            icon: CustomIconWidget(
              iconName: 'add',
              color: Colors.white,
              size: 20,
            ),
            label: Text('Iniciar Conversa'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: 6.w,
                vertical: 1.5.h,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _openNewMessageModal,
      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      child: CustomIconWidget(
        iconName: 'add',
        color: Colors.white,
        size: 24,
      ),
    );
  }
}

// Data Models
class Conversation {
  final String id;
  final String otherParticipantId;
  final String otherParticipantName;
  final String? otherParticipantAvatar;
  final bool isOtherParticipantOnline;
  final Message? lastMessage;
  final int unreadCount;
  final DateTime? updatedAt;

  Conversation({
    required this.id,
    required this.otherParticipantId,
    required this.otherParticipantName,
    this.otherParticipantAvatar,
    required this.isOtherParticipantOnline,
    this.lastMessage,
    this.unreadCount = 0,
    this.updatedAt,
  });

  factory Conversation.fromJson(
      Map<String, dynamic> json, String currentUserId) {
    final participant1 = json['participant1'] as Map<String, dynamic>?;
    final participant2 = json['participant2'] as Map<String, dynamic>?;
    final lastMessageData = json['last_message'] as List?;

    // Determine other participant
    final isCurrentUserParticipant1 = participant1?['id'] == currentUserId;
    final otherParticipant =
        isCurrentUserParticipant1 ? participant2 : participant1;

    Message? lastMessage;
    if (lastMessageData != null && lastMessageData.isNotEmpty) {
      lastMessage = Message.fromJson(lastMessageData.first);
    }

    return Conversation(
      id: json['id'] ?? '',
      otherParticipantId: otherParticipant?['id'] ?? '',
      otherParticipantName:
          otherParticipant?['full_name'] ?? 'Usuário Desconhecido',
      otherParticipantAvatar: otherParticipant?['avatar_url'],
      isOtherParticipantOnline: otherParticipant?['is_active'] ?? false,
      lastMessage: lastMessage,
      unreadCount: json['unread_count'] ?? 0,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  factory Conversation.empty() {
    return Conversation(
      id: '',
      otherParticipantId: '',
      otherParticipantName: '',
      isOtherParticipantOnline: false,
    );
  }
}

class Message {
  final String id;
  final String content;
  final String senderId;
  final DateTime createdAt;
  final String messageType;

  Message({
    required this.id,
    required this.content,
    required this.senderId,
    required this.createdAt,
    this.messageType = 'text',
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      senderId: json['sender_id'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      messageType: json['message_type'] ?? 'text',
    );
  }
}
