import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/services/achievements_service.dart';

class ProfileStatsWidget extends StatelessWidget {
  final UserProfile userProfile;
  final AchievementStatistics? achievementStats;

  const ProfileStatsWidget({
    Key? key,
    required this.userProfile,
    this.achievementStats,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estatísticas',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),

          // Grid of stats
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisSpacing: 3.w,
            mainAxisSpacing: 2.h,
            childAspectRatio: 1.2,
            children: [
              _buildStatCard(
                'Distância Total',
                '${userProfile.totalDistance.toStringAsFixed(1)} km',
                'route',
                AppTheme.lightTheme.colorScheme.primary,
              ),
              _buildStatCard(
                'Viagens',
                '${userProfile.totalRides}',
                'motorcycle',
                AppTheme.secondaryLight,
              ),
              _buildStatCard(
                'Cidades',
                '${userProfile.totalCitiesVisited}',
                'location_city',
                AppTheme.accentLight,
              ),
              _buildStatCard(
                'Conquistas',
                '${achievementStats?.totalAchievements ?? 0}',
                'emoji_events',
                AppTheme.achievementGold,
              ),
            ],
          ),

          if (achievementStats != null) ...[
            SizedBox(height: 3.h),
            Text(
              'Conquistas por Categoria',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),

            // Achievement categories
            _buildAchievementCategoryList(),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, String iconName, Color color) {
    return Container(
      padding: EdgeInsets.all(3.w),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: iconName,
              color: color,
              size: 28,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCategoryList() {
    final categories = [
      {
        'name': 'Distância',
        'count': achievementStats?.distanceAchievements ?? 0,
        'icon': 'route',
        'color': AppTheme.lightTheme.colorScheme.primary,
      },
      {
        'name': 'Velocidade',
        'count': achievementStats?.speedAchievements ?? 0,
        'icon': 'speed',
        'color': AppTheme.secondaryLight,
      },
      {
        'name': 'Exploração',
        'count': achievementStats?.explorationAchievements ?? 0,
        'icon': 'explore',
        'color': AppTheme.accentLight,
      },
      {
        'name': 'Social',
        'count': achievementStats?.socialAchievements ?? 0,
        'icon': 'group',
        'color': AppTheme.warningLight,
      },
      {
        'name': 'Tempo',
        'count': achievementStats?.timeAchievements ?? 0,
        'icon': 'access_time',
        'color': AppTheme.lightTheme.colorScheme.primary,
      },
      {
        'name': 'Especiais',
        'count': achievementStats?.specialAchievements ?? 0,
        'icon': 'star',
        'color': AppTheme.achievementGold,
      },
    ];

    return Column(
      children: categories.map((category) {
        return Container(
          margin: EdgeInsets.only(bottom: 1.h),
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: AppTheme.shadowLight,
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: (category['color'] as Color).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: category['icon'] as String,
                  color: category['color'] as Color,
                  size: 20,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  category['name'] as String,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: (category['color'] as Color).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${category['count']}',
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: category['color'] as Color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
