import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RouteCardWidget extends StatelessWidget {
  final Map<String, dynamic> route;
  final bool isMultiSelectMode;
  final bool isSelected;
  final Function(Map<String, dynamic>) onSwipeRight;

  const RouteCardWidget({
    Key? key,
    required this.route,
    required this.isMultiSelectMode,
    required this.isSelected,
    required this.onSwipeRight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('route_${route['id']}'),
      direction: DismissDirection.startToEnd,
      background: Container(
        margin: EdgeInsets.symmetric(vertical: 1.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 6.w),
        child: CustomIconWidget(
          iconName: 'share',
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 24,
        ),
      ),
      confirmDismiss: (direction) async {
        onSwipeRight(route);
        return false;
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.lightTheme.colorScheme.primary.withValues(
                  alpha: 0.1,
                )
              : AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  width: 2,
                )
              : null,
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
            // Header with thumbnail and basic info
            Container(
              height: 20.h,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                color: AppTheme.lightTheme.colorScheme.surface,
              ),
              child: Stack(
                children: [
                  // Thumbnail map
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: CustomImageWidget(
                      imageUrl: route['thumbnailUrl'] as String,
                      width: double.infinity,
                      height: 20.h,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Gradient overlay
                  Container(
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

                  // Top right indicators
                  Positioned(
                    top: 2.h,
                    right: 4.w,
                    child: Row(
                      children: [
                        if (isMultiSelectMode)
                          Container(
                            width: 6.w,
                            height: 6.w,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.lightTheme.colorScheme.primary
                                  : Colors.white.withValues(alpha: 0.8),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.lightTheme.colorScheme.primary
                                    : AppTheme.lightTheme.colorScheme.outline,
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? CustomIconWidget(
                                    iconName: 'check',
                                    color: Colors.white,
                                    size: 16,
                                  )
                                : null,
                          ),
                        if (isMultiSelectMode) SizedBox(width: 2.w),
                        if (!(route['isSynced'] as bool))
                          Container(
                            padding: EdgeInsets.all(1.w),
                            decoration: BoxDecoration(
                              color: AppTheme.warningLight,
                              shape: BoxShape.circle,
                            ),
                            child: CustomIconWidget(
                              iconName: 'cloud_off',
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Bottom info overlay
                  Positioned(
                    bottom: 2.h,
                    left: 4.w,
                    right: 4.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          route['title'] as String,
                          style: AppTheme.lightTheme.textTheme.titleLarge
                              ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'location_on',
                              color: Colors.white.withValues(alpha: 0.8),
                              size: 16,
                            ),
                            SizedBox(width: 1.w),
                            Expanded(
                              child: Text(
                                '${route['startLocation']} → ${route['endLocation']}',
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: Colors.white.withValues(
                                    alpha: 0.8,
                                  ),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content section
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date and stats row
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 0.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          route['date'] as String,
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if ((route['photos'] as int) > 0) ...[
                        CustomIconWidget(
                          iconName: 'photo_camera',
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                          size: 16,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          '${route['photos']}',
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ],
                  ),

                  SizedBox(height: 2.h),

                  // Stats grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          context,
                          'straighten',
                          'Distância',
                          route['distance'] as String,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          context,
                          'schedule',
                          'Duração',
                          route['duration'] as String,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          context,
                          'trending_up',
                          'Elevação',
                          route['elevationGain'] as String,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 2.h),

                  // Achievement badges
                  if ((route['achievements'] as List).isNotEmpty) ...[
                    Wrap(
                      spacing: 2.w,
                      runSpacing: 1.h,
                      children:
                          (route['achievements'] as List).map((achievement) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 3.w,
                            vertical: 0.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.successLight.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.successLight.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomIconWidget(
                                iconName: 'emoji_events',
                                color: AppTheme.successLight,
                                size: 14,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                achievement as String,
                                style: AppTheme.lightTheme.textTheme.labelSmall
                                    ?.copyWith(
                                  color: AppTheme.successLight,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 1.h),
                  ],

                  // Notes
                  if ((route['notes'] as String).isNotEmpty) ...[
                    Text(
                      route['notes'] as String,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.7),
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String iconName,
    String label,
    String value,
  ) {
    return Column(
      children: [
        CustomIconWidget(
          iconName: iconName,
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 20,
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
              alpha: 0.6,
            ),
          ),
        ),
      ],
    );
  }
}
