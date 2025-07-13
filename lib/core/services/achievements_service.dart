import 'package:supabase_flutter/supabase_flutter.dart';
import './supabase_service.dart';

enum AchievementCategory {
  distance,
  speed,
  exploration,
  social,
  time,
  special,
}

enum AchievementRarity {
  common,
  rare,
  epic,
  legendary,
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final AchievementCategory category;
  final AchievementRarity rarity;
  final String iconName;
  final int maxProgress;
  final int xpReward;
  final String requirements;
  final bool isActive;
  final bool isHidden;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.rarity,
    required this.iconName,
    required this.maxProgress,
    required this.xpReward,
    required this.requirements,
    this.isActive = true,
    this.isHidden = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: _parseCategory(json['category'] as String),
      rarity: _parseRarity(json['rarity'] as String),
      iconName: json['icon_name'] as String,
      maxProgress: json['max_progress'] as int,
      xpReward: json['xp_reward'] as int,
      requirements: json['requirements'] as String,
      isActive: json['is_active'] as bool? ?? true,
      isHidden: json['is_hidden'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  static AchievementCategory _parseCategory(String category) {
    switch (category) {
      case 'distance':
        return AchievementCategory.distance;
      case 'speed':
        return AchievementCategory.speed;
      case 'exploration':
        return AchievementCategory.exploration;
      case 'social':
        return AchievementCategory.social;
      case 'time':
        return AchievementCategory.time;
      case 'special':
        return AchievementCategory.special;
      default:
        return AchievementCategory.distance;
    }
  }

  static AchievementRarity _parseRarity(String rarity) {
    switch (rarity) {
      case 'common':
        return AchievementRarity.common;
      case 'rare':
        return AchievementRarity.rare;
      case 'epic':
        return AchievementRarity.epic;
      case 'legendary':
        return AchievementRarity.legendary;
      default:
        return AchievementRarity.common;
    }
  }
}

class UserAchievement {
  final String id;
  final String userId;
  final String achievementId;
  final int currentProgress;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final bool isShared;
  final DateTime? sharedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Achievement details (joined data)
  final Achievement? achievement;

  const UserAchievement({
    required this.id,
    required this.userId,
    required this.achievementId,
    required this.currentProgress,
    required this.isUnlocked,
    this.unlockedAt,
    this.isShared = false,
    this.sharedAt,
    required this.createdAt,
    required this.updatedAt,
    this.achievement,
  });

  factory UserAchievement.fromJson(Map<String, dynamic> json) {
    return UserAchievement(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      achievementId: json['achievement_id'] as String,
      currentProgress: json['current_progress'] as int,
      isUnlocked: json['is_unlocked'] as bool,
      unlockedAt: json['unlocked_at'] != null
          ? DateTime.parse(json['unlocked_at'] as String)
          : null,
      isShared: json['is_shared'] as bool? ?? false,
      sharedAt: json['shared_at'] != null
          ? DateTime.parse(json['shared_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      achievement: json['achievements'] != null
          ? Achievement.fromJson(json['achievements'] as Map<String, dynamic>)
          : null,
    );
  }

  double get progressPercentage {
    if (achievement == null) return 0.0;
    return (currentProgress / achievement!.maxProgress).clamp(0.0, 1.0);
  }
}

class AchievementStatistics {
  final String userId;
  final int distanceAchievements;
  final int speedAchievements;
  final int explorationAchievements;
  final int socialAchievements;
  final int timeAchievements;
  final int specialAchievements;
  final int totalAchievements;
  final int totalXpFromAchievements;
  final int commonAchievements;
  final int rareAchievements;
  final int epicAchievements;
  final int legendaryAchievements;

  const AchievementStatistics({
    required this.userId,
    required this.distanceAchievements,
    required this.speedAchievements,
    required this.explorationAchievements,
    required this.socialAchievements,
    required this.timeAchievements,
    required this.specialAchievements,
    required this.totalAchievements,
    required this.totalXpFromAchievements,
    required this.commonAchievements,
    required this.rareAchievements,
    required this.epicAchievements,
    required this.legendaryAchievements,
  });

  factory AchievementStatistics.fromJson(Map<String, dynamic> json) {
    return AchievementStatistics(
      userId: json['user_id'] as String,
      distanceAchievements: json['distance_achievements'] as int? ?? 0,
      speedAchievements: json['speed_achievements'] as int? ?? 0,
      explorationAchievements: json['exploration_achievements'] as int? ?? 0,
      socialAchievements: json['social_achievements'] as int? ?? 0,
      timeAchievements: json['time_achievements'] as int? ?? 0,
      specialAchievements: json['special_achievements'] as int? ?? 0,
      totalAchievements: json['total_achievements'] as int? ?? 0,
      totalXpFromAchievements: json['total_xp_from_achievements'] as int? ?? 0,
      commonAchievements: json['common_achievements'] as int? ?? 0,
      rareAchievements: json['rare_achievements'] as int? ?? 0,
      epicAchievements: json['epic_achievements'] as int? ?? 0,
      legendaryAchievements: json['legendary_achievements'] as int? ?? 0,
    );
  }
}

class AchievementsService {
  final SupabaseService _supabaseService = SupabaseService();

  Future<SupabaseClient> get _client async => await _supabaseService.client;

  // Get all available achievements
  Future<List<Achievement>> getAllAchievements() async {
    try {
      final client = await _client;
      final response = await client
          .from('achievements')
          .select()
          .eq('is_active', true)
          .order('sort_order');

      return response
          .map<Achievement>((json) => Achievement.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Failed to load achievements: $error');
    }
  }

  // Get user's achievements with progress
  Future<List<UserAchievement>> getUserAchievements(String userId) async {
    try {
      final client = await _client;
      final response = await client.from('user_achievements').select('''
            *,
            achievements (
              id, name, description, category, rarity, icon_name, 
              max_progress, xp_reward, requirements, is_active, is_hidden,
              created_at, updated_at
            )
          ''').eq('user_id', userId).order('created_at', ascending: false);

      return response
          .map<UserAchievement>((json) => UserAchievement.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Failed to load user achievements: $error');
    }
  }

  // Get user's achievements by category
  Future<List<UserAchievement>> getUserAchievementsByCategory(
      String userId, AchievementCategory category) async {
    try {
      final client = await _client;
      final response = await client
          .from('user_achievements')
          .select('''
            *,
            achievements!inner (
              id, name, description, category, rarity, icon_name, 
              max_progress, xp_reward, requirements, is_active, is_hidden,
              created_at, updated_at
            )
          ''')
          .eq('user_id', userId)
          .eq('achievements.category', category.name)
          .order('created_at', ascending: false);

      return response
          .map<UserAchievement>((json) => UserAchievement.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Failed to load user achievements by category: $error');
    }
  }

  // Get user's unlocked achievements
  Future<List<UserAchievement>> getUserUnlockedAchievements(
      String userId) async {
    try {
      final client = await _client;
      final response = await client
          .from('user_achievements')
          .select('''
            *,
            achievements (
              id, name, description, category, rarity, icon_name, 
              max_progress, xp_reward, requirements, is_active, is_hidden,
              created_at, updated_at
            )
          ''')
          .eq('user_id', userId)
          .eq('is_unlocked', true)
          .order('unlocked_at', ascending: false);

      return response
          .map<UserAchievement>((json) => UserAchievement.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Failed to load unlocked achievements: $error');
    }
  }

  // Get recent achievements (last 5)
  Future<List<UserAchievement>> getRecentAchievements(String userId) async {
    try {
      final client = await _client;
      final response = await client
          .from('user_achievements')
          .select('''
            *,
            achievements (
              id, name, description, category, rarity, icon_name, 
              max_progress, xp_reward, requirements, is_active, is_hidden,
              created_at, updated_at
            )
          ''')
          .eq('user_id', userId)
          .eq('is_unlocked', true)
          .order('unlocked_at', ascending: false)
          .limit(5);

      return response
          .map<UserAchievement>((json) => UserAchievement.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Failed to load recent achievements: $error');
    }
  }

  // Get achievement statistics for user
  Future<AchievementStatistics?> getAchievementStatistics(String userId) async {
    try {
      final client = await _client;
      final response = await client
          .from('achievement_statistics')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return AchievementStatistics.fromJson(response);
    } catch (error) {
      throw Exception('Failed to load achievement statistics: $error');
    }
  }

  // Update achievement progress
  Future<void> updateAchievementProgress(
    String userId,
    String achievementName,
    int progress,
  ) async {
    try {
      final client = await _client;
      await client.rpc('check_and_unlock_achievement', params: {
        'target_user_id': userId,
        'achievement_name': achievementName,
        'current_progress': progress,
      });
    } catch (error) {
      throw Exception('Failed to update achievement progress: $error');
    }
  }

  // Share achievement
  Future<void> shareAchievement(String userAchievementId) async {
    try {
      final client = await _client;
      await client.from('user_achievements').update({
        'is_shared': true,
        'shared_at': DateTime.now().toIso8601String(),
      }).eq('id', userAchievementId);
    } catch (error) {
      throw Exception('Failed to share achievement: $error');
    }
  }

  // Get achievements leaderboard with improved filtering
  Future<List<Map<String, dynamic>>> getAchievementsLeaderboard(
      {int limit = 10, List<String>? userIds}) async {
    try {
      final client = await _client;
      var query = client.from('achievement_statistics').select('''
            *,
            user_profiles (
              id, full_name, avatar_url, level, total_xp
            )
          ''');

      // Apply user ID filter if provided
      if (userIds != null && userIds.isNotEmpty) {
        query = query.filter('user_id', 'in', '(${userIds.join(',')})');
      }

      final response = await query
          .order('total_achievements', ascending: false)
          .order('total_xp_from_achievements', ascending: false)
          .limit(limit);

      return response.cast<Map<String, dynamic>>();
    } catch (error) {
      throw Exception('Failed to load leaderboard: $error');
    }
  }

  // Get available achievements with user progress
  Future<List<Map<String, dynamic>>> getAchievementsWithProgress(
      String userId) async {
    try {
      final client = await _client;
      final response = await client
          .from('achievements')
          .select('''
            *,
            user_achievements!inner (
              id, current_progress, is_unlocked, unlocked_at
            )
          ''')
          .eq('user_achievements.user_id', userId)
          .eq('is_active', true)
          .order('sort_order');

      return response.cast<Map<String, dynamic>>();
    } catch (error) {
      throw Exception('Failed to load achievements with progress: $error');
    }
  }

  // Check if achievement exists
  Future<bool> achievementExists(String achievementName) async {
    try {
      final client = await _client;
      final response = await client
          .from('achievements')
          .select('id')
          .eq('name', achievementName)
          .eq('is_active', true)
          .maybeSingle();

      return response != null;
    } catch (error) {
      return false;
    }
  }

  // Get category-specific achievements count
  Future<Map<AchievementCategory, int>> getCategoryAchievementCounts(
      String userId) async {
    try {
      final stats = await getAchievementStatistics(userId);
      if (stats == null) {
        return {
          AchievementCategory.distance: 0,
          AchievementCategory.speed: 0,
          AchievementCategory.exploration: 0,
          AchievementCategory.social: 0,
          AchievementCategory.time: 0,
          AchievementCategory.special: 0,
        };
      }

      return {
        AchievementCategory.distance: stats.distanceAchievements,
        AchievementCategory.speed: stats.speedAchievements,
        AchievementCategory.exploration: stats.explorationAchievements,
        AchievementCategory.social: stats.socialAchievements,
        AchievementCategory.time: stats.timeAchievements,
        AchievementCategory.special: stats.specialAchievements,
      };
    } catch (error) {
      throw Exception('Failed to load category counts: $error');
    }
  }

  // Helper method to get category display name
  static String getCategoryDisplayName(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.distance:
        return 'Distância';
      case AchievementCategory.speed:
        return 'Velocidade';
      case AchievementCategory.exploration:
        return 'Exploração';
      case AchievementCategory.social:
        return 'Social';
      case AchievementCategory.time:
        return 'Tempo';
      case AchievementCategory.special:
        return 'Especiais';
    }
  }

  // Helper method to get rarity display name
  static String getRarityDisplayName(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.common:
        return 'Comum';
      case AchievementRarity.rare:
        return 'Raro';
      case AchievementRarity.epic:
        return 'Épico';
      case AchievementRarity.legendary:
        return 'Lendário';
    }
  }
}
