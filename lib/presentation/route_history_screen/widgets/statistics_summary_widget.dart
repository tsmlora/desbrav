import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class StatisticsSummaryWidget extends StatelessWidget {
  const StatisticsSummaryWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock statistics data
    final Map<String, dynamic> stats = {
      "totalDistance": "1,182.1 km",
      "totalRides": "5",
      "favoriteRoutes": "3",
      "totalTime": "20h 33min",
      "avgSpeed": "57.5 km/h",
      "achievements": "12",
    };

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary.withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: 'analytics',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 20,
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                'Resumo das Aventuras',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  // Navigate to detailed statistics
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primary.withValues(
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Ver mais',
                        style:
                            AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 1.w),
                      CustomIconWidget(
                        iconName: 'arrow_forward_ios',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 12,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Main stats grid
          Row(
            children: [
              Expanded(
                child: _buildMainStat(
                  context,
                  'straighten',
                  'Distância Total',
                  stats['totalDistance'] as String,
                  AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildMainStat(
                  context,
                  'route',
                  'Viagens',
                  stats['totalRides'] as String,
                  AppTheme.secondaryLight,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildMainStat(
                  context,
                  'favorite',
                  'Favoritas',
                  stats['favoriteRoutes'] as String,
                  AppTheme.accentLight,
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Secondary stats
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline.withValues(
                  alpha: 0.2,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildSecondaryStat(
                    context,
                    'schedule',
                    'Tempo Total',
                    stats['totalTime'] as String,
                  ),
                ),
                Container(
                  width: 1,
                  height: 6.h,
                  color: AppTheme.lightTheme.colorScheme.outline.withValues(
                    alpha: 0.2,
                  ),
                ),
                Expanded(
                  child: _buildSecondaryStat(
                    context,
                    'speed',
                    'Velocidade Média',
                    stats['avgSpeed'] as String,
                  ),
                ),
                Container(
                  width: 1,
                  height: 6.h,
                  color: AppTheme.lightTheme.colorScheme.outline.withValues(
                    alpha: 0.2,
                  ),
                ),
                Expanded(
                  child: _buildSecondaryStat(
                    context,
                    'emoji_events',
                    'Conquistas',
                    stats['achievements'] as String,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainStat(
    BuildContext context,
    String iconName,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(iconName: iconName, color: color, size: 20),
          ),
          SizedBox(height: 1.h),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 0.5.h),
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                alpha: 0.7,
              ),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryStat(
    BuildContext context,
    String iconName,
    String label,
    String value,
  ) {
    return Column(
      children: [
        CustomIconWidget(
          iconName: iconName,
          color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
            alpha: 0.6,
          ),
          size: 18,
        ),
        SizedBox(height: 1.h),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 0.5.h),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
              alpha: 0.6,
            ),
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
