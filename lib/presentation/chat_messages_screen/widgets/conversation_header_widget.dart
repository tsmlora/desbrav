import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ConversationHeaderWidget extends StatelessWidget {
  final Map<String, dynamic> conversationData;
  final VoidCallback onBackPressed;
  final VoidCallback onInfoPressed;

  const ConversationHeaderWidget({
    Key? key,
    required this.conversationData,
    required this.onBackPressed,
    required this.onInfoPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final participants = conversationData["participants"] as List;
    final isGroup = conversationData["type"] == "group";
    final onlineCount = participants.where((p) => p["isOnline"] == true).length;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: AppTheme.lightTheme.dividerColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBackPressed,
            child: Container(
              padding: EdgeInsets.all(2.w),
              child: CustomIconWidget(
                iconName: 'arrow_back',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 24,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          _buildConversationAvatar(),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conversationData["name"] ?? "Conversa",
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 0.5.h),
                Text(
                  isGroup
                      ? "\$onlineCount online de \${participants.length} membros"
                      : _getLastSeenText(),
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onInfoPressed,
            child: Container(
              padding: EdgeInsets.all(2.w),
              child: CustomIconWidget(
                iconName: 'info_outline',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationAvatar() {
    final participants = conversationData["participants"] as List;
    final isGroup = conversationData["type"] == "group";

    if (isGroup && participants.length > 1) {
      return Stack(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.lightTheme.colorScheme.primary.withValues(
                alpha: 0.1,
              ),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: 'group',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
            ),
          ),
          if (participants.any((p) => p["isOnline"] == true))
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 3.w,
                height: 3.w,
                decoration: BoxDecoration(
                  color: AppTheme.successLight,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      );
    } else {
      final participant = participants.isNotEmpty ? participants.first : null;
      return Stack(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6.w),
              child: participant != null && participant["avatar"] != null
                  ? CustomImageWidget(
                      imageUrl: participant["avatar"],
                      width: 12.w,
                      height: 12.w,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.1),
                      child: Center(
                        child: CustomIconWidget(
                          iconName: 'person',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 20,
                        ),
                      ),
                    ),
            ),
          ),
          if (participant != null && participant["isOnline"] == true)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 3.w,
                height: 3.w,
                decoration: BoxDecoration(
                  color: AppTheme.successLight,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      );
    }
  }

  String _getLastSeenText() {
    final participants = conversationData["participants"] as List;
    if (participants.isEmpty) return "Offline";

    final participant = participants.first;
    if (participant["isOnline"] == true) {
      return "Online";
    } else {
      final lastSeen = DateTime.tryParse(participant["lastSeen"] ?? "");
      if (lastSeen != null) {
        final now = DateTime.now();
        final difference = now.difference(lastSeen);

        if (difference.inMinutes < 1) {
          return "Visto agora";
        } else if (difference.inMinutes < 60) {
          return "Visto \${difference.inMinutes}min atrás";
        } else if (difference.inHours < 24) {
          return "Visto \${difference.inHours}h atrás";
        } else {
          return "Visto \${difference.inDays}d atrás";
        }
      }
      return "Offline";
    }
  }
}
