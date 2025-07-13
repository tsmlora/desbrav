import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MessageBubbleWidget extends StatelessWidget {
  final Map<String, dynamic> message;
  final bool isSelected;
  final VoidCallback onLongPress;
  final VoidCallback onTap;

  const MessageBubbleWidget({
    Key? key,
    required this.message,
    required this.isSelected,
    required this.onLongPress,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = message["isCurrentUser"] ?? false;
    final messageType = message["type"] ?? "text";

    return GestureDetector(
      onLongPress: onLongPress,
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 1.h),
        child: Row(
          mainAxisAlignment:
              isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isCurrentUser) ...[_buildSenderAvatar(), SizedBox(width: 2.w)],
            Flexible(
              child: Container(
                constraints: BoxConstraints(maxWidth: 75.w),
                child: Column(
                  crossAxisAlignment: isCurrentUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    if (!isCurrentUser)
                      Padding(
                        padding: EdgeInsets.only(left: 3.w, bottom: 0.5.h),
                        child: Text(
                          message["senderName"] ?? "Usuário",
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.primary
                                .withValues(alpha: 0.1)
                            : isCurrentUser
                                ? AppTheme.lightTheme.colorScheme.primary
                                : AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(isCurrentUser ? 16 : 4),
                          topRight: Radius.circular(isCurrentUser ? 4 : 16),
                          bottomLeft: const Radius.circular(16),
                          bottomRight: const Radius.circular(16),
                        ),
                        border: !isCurrentUser
                            ? Border.all(
                                color: AppTheme.lightTheme.dividerColor,
                                width: 1,
                              )
                            : null,
                      ),
                      child: _buildMessageContent(messageType, isCurrentUser),
                    ),
                    SizedBox(height: 0.5.h),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTimestamp(message["timestamp"]),
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                            fontSize: 10.sp,
                          ),
                        ),
                        if (isCurrentUser) ...[
                          SizedBox(width: 1.w),
                          _buildMessageStatus(),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (isCurrentUser) ...[
              SizedBox(width: 2.w),
              _buildCurrentUserAvatar(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSenderAvatar() {
    return Container(
      width: 8.w,
      height: 8.w,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.w),
        child: message["senderAvatar"] != null
            ? CustomImageWidget(
                imageUrl: message["senderAvatar"],
                width: 8.w,
                height: 8.w,
                fit: BoxFit.cover,
              )
            : Container(
                color: AppTheme.lightTheme.colorScheme.primary.withValues(
                  alpha: 0.1,
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: 'person',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 16,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildCurrentUserAvatar() {
    return Container(
      width: 8.w,
      height: 8.w,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.w),
        child: message["senderAvatar"] != null
            ? CustomImageWidget(
                imageUrl: message["senderAvatar"],
                width: 8.w,
                height: 8.w,
                fit: BoxFit.cover,
              )
            : Container(
                color: AppTheme.lightTheme.colorScheme.primary.withValues(
                  alpha: 0.1,
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: 'person',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 16,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildMessageContent(String messageType, bool isCurrentUser) {
    switch (messageType) {
      case "text":
        return _buildTextMessage(isCurrentUser);
      case "image":
        return _buildImageMessage(isCurrentUser);
      case "location":
        return _buildLocationMessage(isCurrentUser);
      case "route":
        return _buildRouteMessage(isCurrentUser);
      default:
        return _buildTextMessage(isCurrentUser);
    }
  }

  Widget _buildTextMessage(bool isCurrentUser) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
      child: Text(
        message["content"] ?? "",
        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
          color: isCurrentUser
              ? Colors.white
              : AppTheme.lightTheme.colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildImageMessage(bool isCurrentUser) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CustomImageWidget(
            imageUrl: message["content"] ?? "",
            width: 60.w,
            height: 40.h,
            fit: BoxFit.cover,
          ),
        ),
        if (message["caption"] != null)
          Padding(
            padding: EdgeInsets.all(3.w),
            child: Text(
              message["caption"],
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: isCurrentUser
                    ? Colors.white
                    : AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLocationMessage(bool isCurrentUser) {
    final locationData = message["locationData"] as Map<String, dynamic>?;

    return Container(
      width: 60.w,
      padding: EdgeInsets.all(3.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'location_on',
                color: isCurrentUser
                    ? Colors.white
                    : AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  message["content"] ?? "Localização compartilhada",
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: isCurrentUser
                        ? Colors.white
                        : AppTheme.lightTheme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (locationData != null) ...[
            SizedBox(height: 1.h),
            Container(
              height: 20.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.lightTheme.dividerColor,
                  width: 1,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'map',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 32,
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      locationData["address"] ?? "Localização",
                      style: AppTheme.lightTheme.textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRouteMessage(bool isCurrentUser) {
    final routeData = message["routeData"] as Map<String, dynamic>?;

    return Container(
      width: 65.w,
      padding: EdgeInsets.all(3.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'route',
                color: isCurrentUser
                    ? Colors.white
                    : AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  message["content"] ?? "Rota compartilhada",
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: isCurrentUser
                        ? Colors.white
                        : AppTheme.lightTheme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (routeData != null) ...[
            SizedBox(height: 1.h),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.lightTheme.dividerColor,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                    child: CustomImageWidget(
                      imageUrl: routeData["thumbnail"] ?? "",
                      width: double.infinity,
                      height: 15.h,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(3.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          routeData["name"] ?? "Rota",
                          style: AppTheme.lightTheme.textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 0.5.h),
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'straighten',
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                              size: 14,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              routeData["distance"] ?? "",
                              style: AppTheme.lightTheme.textTheme.bodySmall,
                            ),
                            SizedBox(width: 3.w),
                            CustomIconWidget(
                              iconName: 'schedule',
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                              size: 14,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              routeData["duration"] ?? "",
                              style: AppTheme.lightTheme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageStatus() {
    final status = message["status"] ?? "sent";
    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case "sending":
        statusColor = AppTheme.lightTheme.colorScheme.onSurfaceVariant;
        statusIcon = Icons.access_time;
        break;
      case "sent":
        statusColor = AppTheme.lightTheme.colorScheme.onSurfaceVariant;
        statusIcon = Icons.check;
        break;
      case "delivered":
        statusColor = AppTheme.lightTheme.colorScheme.onSurfaceVariant;
        statusIcon = Icons.done_all;
        break;
      case "read":
        statusColor = AppTheme.lightTheme.colorScheme.primary;
        statusIcon = Icons.done_all;
        break;
      default:
        statusColor = AppTheme.lightTheme.colorScheme.onSurfaceVariant;
        statusIcon = Icons.check;
    }

    return Icon(statusIcon, size: 12.sp, color: statusColor);
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return "";

    DateTime dateTime;
    if (timestamp is String) {
      dateTime = DateTime.tryParse(timestamp) ?? DateTime.now();
    } else {
      dateTime = timestamp as DateTime;
    }

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    } else if (difference.inDays == 1) {
      return "Ontem";
    } else if (difference.inDays < 7) {
      const weekdays = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
      return weekdays[dateTime.weekday % 7];
    } else {
      return "${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}";
    }
  }
}
