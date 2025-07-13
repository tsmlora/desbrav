import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/achievements_service.dart';
import './widgets/achievement_card_widget.dart';
import './widgets/achievement_detail_modal.dart';
import './widgets/category_tab_widget.dart';
import './widgets/level_progress_widget.dart';
import './widgets/recent_achievements_widget.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({Key? key}) : super(key: key);

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _progressAnimationController;
  late Animation<double> _progressAnimation;

  String _selectedCategory = 'Todos';
  String _searchQuery = '';
  bool _isLoading = false;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AchievementsService _achievementsService = AchievementsService();

  // Real data from Supabase
  List<UserAchievement> _userAchievements = [];
  List<Achievement> _allAchievements = [];
  AchievementStatistics? _achievementStats;

  final List<String> _categories = [
    'Todos',
    'Distância',
    'Velocidade',
    'Exploração',
    'Social',
    'Tempo',
    'Especiais',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _loadUserAchievements();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _progressAnimationController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserAchievements() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userProfile = authProvider.currentUserProfile;

      if (userProfile != null) {
        final userAchievements =
            await _achievementsService.getUserAchievements(userProfile.id);
        final allAchievements = await _achievementsService.getAllAchievements();
        final stats =
            await _achievementsService.getAchievementStatistics(userProfile.id);

        if (mounted) {
          setState(() {
            _userAchievements = userAchievements;
            _allAchievements = allAchievements;
            _achievementStats = stats;
            _isLoading = false;
          });

          // Setup progress animation
          _progressAnimation = Tween<double>(
            begin: 0.0,
            end: userProfile.levelProgress,
          ).animate(
            CurvedAnimation(
              parent: _progressAnimationController,
              curve: Curves.easeInOut,
            ),
          );
          _progressAnimationController.forward();
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar conquistas: $error'),
            backgroundColor: AppTheme.errorLight,
          ),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _filteredAchievements {
    List<Map<String, dynamic>> combinedAchievements = [];

    // Create a map of user achievements by achievement ID
    final userAchievementMap = <String, UserAchievement>{};
    for (final userAchievement in _userAchievements) {
      userAchievementMap[userAchievement.achievementId] = userAchievement;
    }

    // Combine all achievements with user progress
    for (final achievement in _allAchievements) {
      final userAchievement = userAchievementMap[achievement.id];

      combinedAchievements.add({
        'id': achievement.id,
        'title': achievement.name,
        'description': achievement.description,
        'category':
            AchievementsService.getCategoryDisplayName(achievement.category),
        'rarity': AchievementsService.getRarityDisplayName(achievement.rarity),
        'isUnlocked': userAchievement?.isUnlocked ?? false,
        'progress': userAchievement?.currentProgress ?? 0,
        'maxProgress': achievement.maxProgress,
        'iconName': achievement.iconName,
        'unlockedDate':
            userAchievement?.unlockedAt?.toIso8601String().split('T')[0],
        'xpReward': achievement.xpReward,
        'requirements': achievement.requirements,
        'achievement': achievement,
        'userAchievement': userAchievement,
      });
    }

    // Filter by category
    List<Map<String, dynamic>> filtered = combinedAchievements;
    if (_selectedCategory != 'Todos') {
      filtered = filtered
          .where((achievement) => achievement['category'] == _selectedCategory)
          .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((achievement) =>
              (achievement['title'] as String)
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              (achievement['description'] as String)
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return filtered;
  }

  List<Map<String, dynamic>> get _recentAchievements {
    return _userAchievements
        .where((userAchievement) => userAchievement.isUnlocked)
        .take(3)
        .map((userAchievement) {
      final achievement = userAchievement.achievement;
      return {
        'id': achievement?.id ?? '',
        'title': achievement?.name ?? '',
        'description': achievement?.description ?? '',
        'category': achievement != null
            ? AchievementsService.getCategoryDisplayName(achievement.category)
            : '',
        'rarity': achievement != null
            ? AchievementsService.getRarityDisplayName(achievement.rarity)
            : '',
        'isUnlocked': true,
        'progress': userAchievement.currentProgress,
        'maxProgress': achievement?.maxProgress ?? 1,
        'iconName': achievement?.iconName ?? 'emoji_events',
        'unlockedDate':
            userAchievement.unlockedAt?.toIso8601String().split('T')[0],
        'xpReward': achievement?.xpReward ?? 0,
        'requirements': achievement?.requirements ?? '',
        'achievement': achievement,
        'userAchievement': userAchievement,
      };
    }).toList();
  }

  Color _getRarityColor(String rarity) {
    switch (rarity) {
      case 'Comum':
        return Colors.grey;
      case 'Raro':
        return AppTheme.lightTheme.colorScheme.secondary;
      case 'Épico':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'Lendário':
        return AppTheme.achievementGold;
      default:
        return Colors.grey;
    }
  }

  void _onCategoryChanged(String category) {
    setState(() {
      _selectedCategory = category;
    });
    HapticFeedback.lightImpact();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isLoading = true;
    });

    await _loadUserAchievements();
    HapticFeedback.mediumImpact();
  }

  void _showAchievementDetail(Map<String, dynamic> achievement) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AchievementDetailModal(
        achievement: achievement,
        onShare: () => _shareAchievement(achievement),
      ),
    );
  }

  void _shareAchievement(Map<String, dynamic> achievement) {
    HapticFeedback.mediumImpact();

    // If it's a user achievement, mark it as shared
    final userAchievement = achievement['userAchievement'] as UserAchievement?;
    if (userAchievement != null && userAchievement.isUnlocked) {
      _achievementsService.shareAchievement(userAchievement.id);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Conquista "${achievement["title"]}" compartilhada!'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Conquistas',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/profile-screen');
            },
            icon: CustomIconWidget(
              iconName: 'person',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppTheme.lightTheme.colorScheme.primary,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Level Progress Header
            SliverToBoxAdapter(
              child: Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  final userProfile = authProvider.currentUserProfile;
                  if (userProfile == null) {
                    return SizedBox.shrink();
                  }

                  final userData = {
                    'currentLevel': userProfile.level,
                    'totalXP': userProfile.totalXp,
                    'nextLevelXP': userProfile.nextLevelXp,
                    'currentLevelXP': (userProfile.level - 1) * 1000,
                  };

                  return LevelProgressWidget(
                    userData: userData,
                    progressAnimation: _progressAnimation,
                  );
                },
              ),
            ),

            // Search Bar
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Buscar conquistas...',
                    prefixIcon: CustomIconWidget(
                      iconName: 'search',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                            icon: CustomIconWidget(
                              iconName: 'clear',
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ),

            // Recent Achievements
            if (_recentAchievements.isNotEmpty && _searchQuery.isEmpty)
              SliverToBoxAdapter(
                child: RecentAchievementsWidget(
                  achievements: _recentAchievements,
                  onAchievementTap: _showAchievementDetail,
                ),
              ),

            // Category Tabs
            SliverToBoxAdapter(
              child: Container(
                height: 6.h,
                margin: EdgeInsets.symmetric(vertical: 1.h),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  onTap: (index) => _onCategoryChanged(_categories[index]),
                  tabs: _categories
                      .map((category) => CategoryTabWidget(
                            category: category,
                            isSelected: category == _selectedCategory,
                            count: category == 'Todos'
                                ? _allAchievements.length
                                : _allAchievements
                                    .where((a) =>
                                        AchievementsService
                                            .getCategoryDisplayName(
                                                a.category) ==
                                        category)
                                    .length,
                          ))
                      .toList(),
                ),
              ),
            ),

            // Loading State
            if (_isLoading)
              SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                ),
              ),

            // Achievements Grid
            if (!_isLoading && _filteredAchievements.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'emoji_events',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 64,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'Nenhuma conquista encontrada'
                            : 'Nenhuma conquista nesta categoria',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'Tente buscar por outro termo'
                            : 'Continue pilotando para desbloquear conquistas!',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

            if (!_isLoading && _filteredAchievements.isNotEmpty)
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 3.w,
                    mainAxisSpacing: 2.h,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final achievement = _filteredAchievements[index];
                      return AchievementCardWidget(
                        achievement: achievement,
                        rarityColor: _getRarityColor(achievement['rarity']),
                        onTap: () => _showAchievementDetail(achievement),
                      );
                    },
                    childCount: _filteredAchievements.length,
                  ),
                ),
              ),

            // Bottom spacing
            SliverToBoxAdapter(child: SizedBox(height: 10.h)),
          ],
        ),
      ),
    );
  }
}
