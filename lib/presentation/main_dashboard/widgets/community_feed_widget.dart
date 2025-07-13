import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/community_service.dart';

class CommunityFeedWidget extends StatefulWidget {
  const CommunityFeedWidget({super.key});

  @override
  State<CommunityFeedWidget> createState() => _CommunityFeedWidgetState();
}

class _CommunityFeedWidgetState extends State<CommunityFeedWidget> {
  final CommunityService _communityService = CommunityService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _feedItems = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCommunityFeed();
  }

  Future<void> _loadCommunityFeed() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id;

      final feedItems = await _communityService.getCommunityFeed(
        userId: userId,
        limit: 10,
      );

      setState(() {
        _feedItems = feedItems;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Feed da Comunidade',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_isLoading)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                )
              else
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/community-groups-screen'),
                  child: Text('Ver mais'),
                ),
            ],
          ),
          SizedBox(height: 2.h),
          if (_isLoading)
            _buildLoadingState()
          else if (_error != null)
            _buildErrorState()
          else if (_feedItems.isEmpty)
            _buildEmptyState()
          else
            _buildFeedContent(),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: List.generate(3, (index) => _buildLoadingFeedItem()),
    );
  }

  Widget _buildLoadingFeedItem() {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 30.w,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: 1.h),
                Container(
                  width: double.infinity,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: 0.5.h),
                Container(
                  width: 20.w,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Column(
      children: [
        CustomIconWidget(
          iconName: 'error_outline',
          color: AppTheme.errorLight,
          size: 32,
        ),
        SizedBox(height: 1.h),
        Text(
          'Erro ao carregar feed',
          style: AppTheme.lightTheme.textTheme.titleMedium,
        ),
        SizedBox(height: 1.h),
        ElevatedButton(
          onPressed: _loadCommunityFeed,
          child: Text('Tentar Novamente'),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        CustomIconWidget(
          iconName: 'people_outline',
          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          size: 48,
        ),
        SizedBox(height: 2.h),
        Text(
          'Feed vazio',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Junte-se a grupos para ver atividades da comunidade',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 2.h),
        ElevatedButton(
          onPressed: () =>
              Navigator.pushNamed(context, '/community-groups-screen'),
          child: Text('Encontrar Grupos'),
        ),
      ],
    );
  }

  Widget _buildFeedContent() {
    return Column(
      children: _feedItems.take(3).map((item) => _buildFeedItem(item)).toList(),
    );
  }

  Widget _buildFeedItem(Map<String, dynamic> item) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserAvatar(
              item['userAvatar'] as String?, item['userName'] as String),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: item['userName'] as String,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      TextSpan(text: ' ${item['action']}'),
                    ],
                  ),
                ),
                if (item['details'] != null) ...[
                  SizedBox(height: 0.5.h),
                  Text(
                    item['details'] as String,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    _buildActivityTypeChip(item),
                    const Spacer(),
                    Text(
                      item['timestamp'] as String,
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar(String? avatarUrl, String userName) {
    return Container(
      width: 10.w,
      height: 10.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.primaryLight.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: ClipOval(
        child: avatarUrl != null
            ? CachedNetworkImage(
                imageUrl: avatarUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppTheme.primaryLight.withValues(alpha: 0.1),
                  child: Center(
                    child: SizedBox(
                      width: 4.w,
                      height: 4.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 1,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryLight,
                        ),
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) =>
                    _buildAvatarFallback(userName),
              )
            : _buildAvatarFallback(userName),
      ),
    );
  }

  Widget _buildAvatarFallback(String userName) {
    final initials = userName
        .split(' ')
        .take(2)
        .map((name) => name.isNotEmpty ? name[0] : '')
        .join()
        .toUpperCase();
    return Container(
      color: AppTheme.primaryLight.withValues(alpha: 0.1),
      child: Center(
        child: Text(
          initials,
          style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
            color: AppTheme.primaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildActivityTypeChip(Map<String, dynamic> item) {
    final type = item['type'] as String;
    Color chipColor;
    String chipLabel;
    String iconName;

    switch (type) {
      case 'achievement':
        final rarity =
            item['data']?['achievement_rarity'] as String? ?? 'common';
        switch (rarity) {
          case 'legendary':
            chipColor = AppTheme.achievementGold;
            break;
          case 'epic':
            chipColor = AppTheme.accentLight;
            break;
          case 'rare':
            chipColor = AppTheme.secondaryLight;
            break;
          default:
            chipColor = Colors.grey;
        }
        chipLabel = 'Conquista';
        iconName = 'military_tech';
        break;
      case 'event':
        chipColor = AppTheme.primaryLight;
        chipLabel = 'Evento';
        iconName = 'event';
        break;
      case 'group':
        chipColor = AppTheme.successLight;
        chipLabel = 'Grupo';
        iconName = 'group';
        break;
      default:
        chipColor = Colors.grey;
        chipLabel = 'Atividade';
        iconName = 'circle';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: iconName,
            color: chipColor,
            size: 12,
          ),
          SizedBox(width: 1.w),
          Text(
            chipLabel,
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: chipColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
