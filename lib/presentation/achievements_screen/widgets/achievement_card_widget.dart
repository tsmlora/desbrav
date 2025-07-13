import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AchievementCardWidget extends StatelessWidget {
  final Map<String, dynamic> achievement;
  final Color rarityColor;
  final VoidCallback onTap;

  const AchievementCardWidget({
    Key? key,
    required this.achievement,
    required this.rarityColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isUnlocked = achievement["isUnlocked"] as bool;
    final progress = achievement["progress"] as int;
    final maxProgress = achievement["maxProgress"] as int;
    final progressPercentage = progress / maxProgress;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnlocked
                ? rarityColor.withValues(alpha: 0.3)
                : AppTheme.lightTheme.colorScheme.outline.withValues(
                    alpha: 0.2,
                  ),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isUnlocked
                  ? rarityColor.withValues(alpha: 0.1)
                  : AppTheme.lightTheme.shadowColor,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Rarity sparkle effect for unlocked achievements
            if (isUnlocked && achievement["rarity"] != "Common")
              Positioned(
                top: 2.w,
                right: 2.w,
                child: CustomIconWidget(
                  iconName: 'auto_awesome',
                  color: rarityColor.withValues(alpha: 0.6),
                  size: 16,
                ),
              ),

            Padding(
              padding: EdgeInsets.all(3.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon and rarity
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: isUnlocked
                              ? rarityColor.withValues(alpha: 0.1)
                              : AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: CustomIconWidget(
                          iconName: achievement["iconName"],
                          color: isUnlocked
                              ? rarityColor
                              : AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.3),
                          size: 28,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 0.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: isUnlocked
                              ? rarityColor.withValues(alpha: 0.1)
                              : AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          achievement["rarity"],
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: isUnlocked
                                ? rarityColor
                                : AppTheme.lightTheme.colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                            fontWeight: FontWeight.w600,
                            fontSize: 9.sp,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 2.h),

                  // Title
                  Text(
                    achievement["title"],
                    style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isUnlocked
                          ? AppTheme.lightTheme.colorScheme.onSurface
                          : AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 1.h),

                  // Description
                  Text(
                    achievement["description"],
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: isUnlocked
                          ? AppTheme.lightTheme.colorScheme.onSurfaceVariant
                          : AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.4),
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const Spacer(),

                  // Progress or completion info
                  if (isUnlocked) ...[
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'check_circle',
                          color: AppTheme.successLight,
                          size: 16,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          'Concluída',
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: AppTheme.successLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '+${achievement["xpReward"]} XP',
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progresso',
                              style: AppTheme.lightTheme.textTheme.labelSmall
                                  ?.copyWith(
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              '${(progressPercentage * 100).toInt()}%',
                              style: AppTheme.lightTheme.textTheme.labelSmall
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 0.5.h),
                        Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: progressPercentage,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.lightTheme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          '$progress/$maxProgress',
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Locked overlay
            if (!isUnlocked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface.withValues(
                      alpha: 0.7,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'lock',
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.3),
                      size: 32,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
