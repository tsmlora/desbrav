import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/achievements_service.dart';
import '../community_groups_screen/community_groups_screen.dart';
import '../direct_messages_screen/direct_messages_screen.dart';
import '../enhanced_interactive_map_screen/enhanced_interactive_map_screen.dart';
import '../optimized_bottom_navigation_bar/optimized_bottom_navigation_bar.dart';
import '../profile_screen/profile_screen.dart';
import '../rest_points_screen/rest_points_screen.dart';
import './widgets/achievement_card_widget.dart';
import './widgets/community_feed_widget.dart';
import './widgets/level_progress_widget.dart';
import './widgets/statistics_card_widget.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard>
    with TickerProviderStateMixin {
  int _currentTabIndex = 0;
  bool _isRefreshing = false;
  late TabController _tabController;

  final AchievementsService _achievementsService = AchievementsService();
  List<UserAchievement> _recentAchievements = [];
  bool _isLoadingAchievements = true;

  final Map<String, dynamic> weatherData = {
    "temperature": 24,
    "condition": "Ensolarado",
    "icon": "wb_sunny",
    "windSpeed": 12,
    "humidity": 65,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadRecentAchievements();
  }

  Future<void> _loadRecentAchievements() async {
    // Implement achievement loading logic here
    setState(() {
      _isLoadingAchievements = false;
      _recentAchievements = [];
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Get current tab content
  Widget _getCurrentTabContent(AuthProvider authProvider) {
    switch (_currentTabIndex) {
      case 0:
        return _buildDashboardContent(authProvider);
      case 1:
        return const EnhancedInteractiveMapScreen();
      case 2:
        return const CommunityGroupsScreen();
      case 3:
        return const DirectMessagesScreen();
      case 4:
        return const RestPointsScreen();
      case 5:
        return const ProfileScreen();
      default:
        return _buildDashboardContent(authProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            if (!authProvider.isInitialized) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: AppTheme.primaryLight,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Inicializando...',
                      style: AppTheme.lightTheme.textTheme.titleMedium,
                    ),
                  ],
                ),
              );
            }

            if (!authProvider.isAuthenticated) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacementNamed(context, '/login-screen');
              });
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: AppTheme.primaryLight,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Redirecionando para login...',
                      style: AppTheme.lightTheme.textTheme.titleMedium,
                    ),
                  ],
                ),
              );
            }

            return _getCurrentTabContent(authProvider);
          },
        ),
      ),
      bottomNavigationBar: OptimizedBottomNavigationBar(
        currentIndex: _currentTabIndex,
        onTap: (index) {
          setState(() {
            _currentTabIndex = index;
          });
        },
        directMessagesBadgeCount: 3,
        communityBadgeCount: 1,
      ),
      floatingActionButton:
          _currentTabIndex == 0 ? _buildFloatingActionButton() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });
    // Implement refresh logic here
    setState(() {
      _isRefreshing = false;
    });
  }

  Widget _buildDashboardContent(AuthProvider authProvider) {
    final userProfile = authProvider.currentUserProfile;

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppTheme.lightTheme.colorScheme.primary,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildHeader(userProfile),
                SizedBox(height: 2.h),
                LevelProgressWidget(
                  currentLevel: userProfile?.level ?? 1,
                  currentXP: userProfile?.totalXp ?? 0,
                  nextLevelXP: userProfile?.nextLevelXp ?? 1000,
                ),
                SizedBox(height: 2.h),
                _buildAchievementsSection(),
                SizedBox(height: 2.h),
                RealTimeStatisticsWidget(),
                SizedBox(height: 2.h),
                CommunityFeedWidget(),
                SizedBox(height: 10.h), // Space for FAB
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(dynamic userProfile) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Desbrav',
                  style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                    color: AppTheme.primaryLight,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Olá, ${userProfile?.firstName ?? userProfile?.fullName ?? 'Motociclista'}!',
                  style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: weatherData["icon"] as String,
                      color: AppTheme.warningLight,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      '${weatherData["temperature"]}°C • ${weatherData["condition"]}',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                if (userProfile?.hasMotorcycleInfo == true) ...[
                  SizedBox(height: 0.5.h),
                  Text(
                    userProfile!.motorcycleFullName,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Row(
            children: [
              if (userProfile?.avatarUrl != null)
                Container(
                  width: 12.w,
                  height: 12.w,
                  margin: EdgeInsets.only(right: 3.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primaryLight,
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: userProfile!.avatarUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Container(
                        color: AppTheme.primaryLight.withValues(alpha: 0.1),
                        child: Center(
                          child: Text(
                            userProfile.initials,
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              color: AppTheme.primaryLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              GestureDetector(
                onTap: _openSettings,
                child: Container(
                  padding: EdgeInsets.all(2.w),
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
                  child: CustomIconWidget(
                    iconName: 'settings',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openSettings() {
    // Implement settings opening logic here
  }

  Widget _buildAchievementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Conquistas Recentes',
                style: AppTheme.lightTheme.textTheme.titleLarge,
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/achievements-screen'),
                child: Text('Ver todas'),
              ),
            ],
          ),
        ),
        SizedBox(height: 1.h),
        SizedBox(
          height: 20.h,
          child: _isLoadingAchievements
              ? _buildLoadingAchievements()
              : _recentAchievements.isEmpty
                  ? _buildEmptyAchievements()
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      itemCount: _recentAchievements.length,
                      itemBuilder: (context, index) {
                        final achievement = _recentAchievements[index];
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2.w),
                          child: AchievementCardWidget(
                            achievement: _convertToAchievementMap(achievement),
                            onTap: () => _showAchievementDetails(achievement),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildLoadingAchievements() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          AppTheme.lightTheme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildEmptyAchievements() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'military_tech',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 32,
          ),
          SizedBox(height: 1.h),
          Text(
            'Nenhuma conquista ainda',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            'Inicie uma viagem para desbloquear conquistas',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _convertToAchievementMap(
      UserAchievement userAchievement) {
    if (userAchievement.achievement == null) {
      return {
        "id": userAchievement.id,
        "title": "Conquista Desconhecida",
        "description": "Descrição não disponível",
        "category": "Geral",
        "rarity": "Common",
        "icon": "star",
        "progress": 100,
        "unlockedAt": userAchievement.unlockedAt?.toIso8601String() ?? "",
        "xpReward": 0,
      };
    }

    final achievement = userAchievement.achievement!;
    return {
      "id": achievement.id,
      "title": achievement.name,
      "description": achievement.description,
      "category":
          AchievementsService.getCategoryDisplayName(achievement.category),
      "rarity": AchievementsService.getRarityDisplayName(achievement.rarity),
      "icon": achievement.iconName,
      "progress": 100,
      "unlockedAt": userAchievement.unlockedAt?.toIso8601String() ?? "",
      "xpReward": achievement.xpReward,
    };
  }

  void _showAchievementDetails(UserAchievement userAchievement) {
    final achievement = userAchievement.achievement;
    if (achievement == null) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: EdgeInsets.all(6.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: _getRarityColor(achievement.rarity)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CustomIconWidget(
                  iconName: achievement.iconName,
                  color: _getRarityColor(achievement.rarity),
                  size: 48,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                achievement.name,
                style: AppTheme.lightTheme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 1.h),
              Text(
                achievement.description,
                style: AppTheme.lightTheme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 1.h,
                ),
                decoration: BoxDecoration(
                  color: _getRarityColor(achievement.rarity)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${AchievementsService.getRarityDisplayName(achievement.rarity)} • +${achievement.xpReward} XP',
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: _getRarityColor(achievement.rarity),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 3.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Fechar'),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Share achievement logic
                      },
                      child: Text('Compartilhar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRarityColor(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.common:
        return Colors.grey;
      case AchievementRarity.rare:
        return AppTheme.secondaryLight;
      case AchievementRarity.epic:
        return AppTheme.accentLight;
      case AchievementRarity.legendary:
        return AppTheme.achievementGold;
    }
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _startTrip,
      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      foregroundColor: Colors.white,
      elevation: 6,
      icon: CustomIconWidget(
        iconName: 'play_arrow',
        color: Colors.white,
        size: 24,
      ),
      label: Text(
        'Iniciar Viagem',
        style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _startTrip() {
    // Implement trip starting logic here
  }
}
