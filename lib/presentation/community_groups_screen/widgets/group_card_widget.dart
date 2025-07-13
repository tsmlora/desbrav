import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class GroupCardWidget extends StatelessWidget {
  final Map<String, dynamic> group;
  final VoidCallback onJoinToggle;
  final VoidCallback onTap;

  const GroupCardWidget({
    Key? key,
    required this.group,
    required this.onJoinToggle,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isJoined = group['isJoined'] as bool? ?? false;
    final bool isPrivate = group['isPrivate'] as bool? ?? false;
    final bool isVerified = group['isVerified'] as bool? ?? false;
    final int unreadMessages = group['unreadMessages'] as int? ?? 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.shadowLight,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image with overlay info
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: CustomImageWidget(
                    imageUrl: group['coverImage'] as String? ?? '',
                    width: double.infinity,
                    height: 20.h,
                    fit: BoxFit.cover,
                  ),
                ),
                // Gradient overlay
                Container(
                  height: 20.h,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
                // Top badges
                Positioned(
                  top: 2.h,
                  left: 3.w,
                  child: Row(
                    children: [
                      if (isPrivate)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 0.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomIconWidget(
                                iconName: 'lock',
                                color: Colors.white,
                                size: 12,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                'Privado',
                                style: AppTheme.lightTheme.textTheme.labelSmall
                                    ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (isVerified) ...[
                        if (isPrivate) SizedBox(width: 2.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 0.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.successLight.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomIconWidget(
                                iconName: 'verified',
                                color: Colors.white,
                                size: 12,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                'Verificado',
                                style: AppTheme.lightTheme.textTheme.labelSmall
                                    ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Bottom info overlay
                Positioned(
                  bottom: 2.h,
                  left: 3.w,
                  right: 3.w,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              group['name'] as String? ?? '',
                              style: AppTheme.lightTheme.textTheme.titleLarge
                                  ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 0.5.h),
                            Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'location_on',
                                  color: Colors.white.withValues(alpha: 0.8),
                                  size: 14,
                                ),
                                SizedBox(width: 1.w),
                                Expanded(
                                  child: Text(
                                    group['location'] as String? ?? '',
                                    style: AppTheme
                                        .lightTheme.textTheme.bodySmall
                                        ?.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Join/Joined button
                      GestureDetector(
                        onTap: onJoinToggle,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 1.h,
                          ),
                          decoration: BoxDecoration(
                            color: isJoined
                                ? AppTheme.successLight
                                : AppTheme.primaryLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomIconWidget(
                                iconName: isJoined ? 'check' : 'add',
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                isJoined ? 'Membro' : 'Entrar',
                                style: AppTheme.lightTheme.textTheme.labelMedium
                                    ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Unread messages badge
                if (isJoined && unreadMessages > 0)
                  Positioned(
                    top: 2.h,
                    right: 3.w,
                    child: Container(
                      padding: EdgeInsets.all(1.w),
                      decoration: BoxDecoration(
                        color: AppTheme.errorLight,
                        shape: BoxShape.circle,
                      ),
                      constraints: BoxConstraints(
                        minWidth: 6.w,
                        minHeight: 6.w,
                      ),
                      child: Center(
                        child: Text(
                          unreadMessages > 99
                              ? '99+'
                              : unreadMessages.toString(),
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 10.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Card content
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  Text(
                    group['description'] as String? ?? '',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textMediumEmphasisLight,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  // Stats row
                  Row(
                    children: [
                      // Member count
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'people',
                            color: AppTheme.textMediumEmphasisLight,
                            size: 16,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            '${group['memberCount']} membros',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.textMediumEmphasisLight,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 4.w),
                      // Motorcycle type
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'motorcycle',
                            color: AppTheme.textMediumEmphasisLight,
                            size: 16,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            group['motorcycleType'] as String? ?? '',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.textMediumEmphasisLight,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Last activity
                      Text(
                        group['lastActivity'] as String? ?? '',
                        style: AppTheme.lightTheme.textTheme.bodySmall
                            ?.copyWith(color: AppTheme.textDisabledLight),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  // Recent post preview
                  if (group['recentPost'] != null &&
                      (group['recentPost'] as String).isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.dividerLight,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'chat_bubble_outline',
                            color: AppTheme.primaryLight,
                            size: 16,
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              group['recentPost'] as String,
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme.textHighEmphasisLight,
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
