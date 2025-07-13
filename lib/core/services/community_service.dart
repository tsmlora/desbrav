import 'package:supabase_flutter/supabase_flutter.dart';
import './supabase_service.dart';

enum GroupCategory {
  sport,
  touring,
  adventure,
  cruiser,
  scooter,
  vintage,
  general,
}

enum GroupVisibility {
  public,
  private,
  inviteOnly,
}

enum MemberRole {
  owner,
  admin,
  moderator,
  member,
}

class CommunityGroup {
  final String id;
  final String name;
  final String? description;
  final GroupCategory category;
  final GroupVisibility visibility;
  final String? city;
  final String? state;
  final String? country;
  final double? latitude;
  final double? longitude;
  final int? radiusKm;
  final String? coverImageUrl;
  final String? rules;
  final String? meetingLocation;
  final String? meetingSchedule;
  final int memberCount;
  final bool isVerified;
  final bool isFeatured;
  final List<String> motorcycleTypes;
  final int? minEngineSize;
  final String? experienceLevel;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastActivityAt;

  const CommunityGroup({
    required this.id,
    required this.name,
    this.description,
    required this.category,
    required this.visibility,
    this.city,
    this.state,
    this.country,
    this.latitude,
    this.longitude,
    this.radiusKm,
    this.coverImageUrl,
    this.rules,
    this.meetingLocation,
    this.meetingSchedule,
    required this.memberCount,
    required this.isVerified,
    required this.isFeatured,
    required this.motorcycleTypes,
    this.minEngineSize,
    this.experienceLevel,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.lastActivityAt,
  });

  factory CommunityGroup.fromJson(Map<String, dynamic> json) {
    return CommunityGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      category: _parseCategory(json['category'] as String),
      visibility: _parseVisibility(json['visibility'] as String),
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      radiusKm: json['radius_km'] as int?,
      coverImageUrl: json['cover_image_url'] as String?,
      rules: json['rules'] as String?,
      meetingLocation: json['meeting_location'] as String?,
      meetingSchedule: json['meeting_schedule'] as String?,
      memberCount: json['member_count'] as int? ?? 0,
      isVerified: json['is_verified'] as bool? ?? false,
      isFeatured: json['is_featured'] as bool? ?? false,
      motorcycleTypes:
          List<String>.from(json['motorcycle_types'] as List? ?? []),
      minEngineSize: json['min_engine_size'] as int?,
      experienceLevel: json['experience_level'] as String?,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastActivityAt: DateTime.parse(json['last_activity_at'] as String),
    );
  }

  static GroupCategory _parseCategory(String category) {
    switch (category) {
      case 'sport':
        return GroupCategory.sport;
      case 'touring':
        return GroupCategory.touring;
      case 'adventure':
        return GroupCategory.adventure;
      case 'cruiser':
        return GroupCategory.cruiser;
      case 'scooter':
        return GroupCategory.scooter;
      case 'vintage':
        return GroupCategory.vintage;
      case 'general':
      default:
        return GroupCategory.general;
    }
  }

  static GroupVisibility _parseVisibility(String visibility) {
    switch (visibility) {
      case 'private':
        return GroupVisibility.private;
      case 'invite_only':
        return GroupVisibility.inviteOnly;
      case 'public':
      default:
        return GroupVisibility.public;
    }
  }

  String get categoryDisplayName {
    switch (category) {
      case GroupCategory.sport:
        return 'Esportivas';
      case GroupCategory.touring:
        return 'Touring';
      case GroupCategory.adventure:
        return 'Adventure';
      case GroupCategory.cruiser:
        return 'Cruiser';
      case GroupCategory.scooter:
        return 'Scooter';
      case GroupCategory.vintage:
        return 'Clássicas';
      case GroupCategory.general:
        return 'Geral';
    }
  }

  String get locationDisplay {
    if (city != null && state != null) {
      return '$city, $state';
    } else if (state != null) {
      return state!;
    }
    return 'Localização não informada';
  }
}

class GroupMembership {
  final String id;
  final String groupId;
  final String userId;
  final MemberRole role;
  final DateTime joinedAt;
  final bool isActive;
  final bool receiveNotifications;
  final int messagesSent;
  final int eventsAttended;
  final String? invitedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const GroupMembership({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.role,
    required this.joinedAt,
    required this.isActive,
    required this.receiveNotifications,
    required this.messagesSent,
    required this.eventsAttended,
    this.invitedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GroupMembership.fromJson(Map<String, dynamic> json) {
    return GroupMembership(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      userId: json['user_id'] as String,
      role: _parseRole(json['role'] as String),
      joinedAt: DateTime.parse(json['joined_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
      receiveNotifications: json['receive_notifications'] as bool? ?? true,
      messagesSent: json['messages_sent'] as int? ?? 0,
      eventsAttended: json['events_attended'] as int? ?? 0,
      invitedBy: json['invited_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  static MemberRole _parseRole(String role) {
    switch (role) {
      case 'owner':
        return MemberRole.owner;
      case 'admin':
        return MemberRole.admin;
      case 'moderator':
        return MemberRole.moderator;
      case 'member':
      default:
        return MemberRole.member;
    }
  }

  String get roleDisplayName {
    switch (role) {
      case MemberRole.owner:
        return 'Criador';
      case MemberRole.admin:
        return 'Administrador';
      case MemberRole.moderator:
        return 'Moderador';
      case MemberRole.member:
        return 'Membro';
    }
  }
}

class GroupEvent {
  final String id;
  final String groupId;
  final String createdBy;
  final String title;
  final String? description;
  final DateTime eventDate;
  final int durationMinutes;
  final String meetingPoint;
  final double? meetingLatitude;
  final double? meetingLongitude;
  final String? destination;
  final String? routeDescription;
  final double? estimatedDistance;
  final int? maxParticipants;
  final int currentParticipants;
  final bool isPublic;
  final bool requiresRsvp;
  final bool isCancelled;
  final String? cancellationReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  const GroupEvent({
    required this.id,
    required this.groupId,
    required this.createdBy,
    required this.title,
    this.description,
    required this.eventDate,
    required this.durationMinutes,
    required this.meetingPoint,
    this.meetingLatitude,
    this.meetingLongitude,
    this.destination,
    this.routeDescription,
    this.estimatedDistance,
    this.maxParticipants,
    required this.currentParticipants,
    required this.isPublic,
    required this.requiresRsvp,
    required this.isCancelled,
    this.cancellationReason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GroupEvent.fromJson(Map<String, dynamic> json) {
    return GroupEvent(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      createdBy: json['created_by'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      eventDate: DateTime.parse(json['event_date'] as String),
      durationMinutes: json['duration_minutes'] as int? ?? 240,
      meetingPoint: json['meeting_point'] as String,
      meetingLatitude: (json['meeting_latitude'] as num?)?.toDouble(),
      meetingLongitude: (json['meeting_longitude'] as num?)?.toDouble(),
      destination: json['destination'] as String?,
      routeDescription: json['route_description'] as String?,
      estimatedDistance: (json['estimated_distance'] as num?)?.toDouble(),
      maxParticipants: json['max_participants'] as int?,
      currentParticipants: json['current_participants'] as int? ?? 0,
      isPublic: json['is_public'] as bool? ?? true,
      requiresRsvp: json['requires_rsvp'] as bool? ?? true,
      isCancelled: json['is_cancelled'] as bool? ?? false,
      cancellationReason: json['cancellation_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  String get formattedDuration {
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }
}

class CommunityService {
  final SupabaseService _supabaseService = SupabaseService();

  Future<SupabaseClient> get _client async => await _supabaseService.client;

  // Get groups near user's location
  Future<List<CommunityGroup>> getGroupsNearUser(
    String userId, {
    int maxDistanceKm = 100,
  }) async {
    try {
      final client = await _client;
      final response = await client.rpc('get_groups_near_user', params: {
        'target_user_id': userId,
        'max_distance_km': maxDistanceKm,
      });

      // Get full group details for the returned group IDs
      if (response.isEmpty) return [];

      final groupIds =
          response.map((item) => item['group_id'] as String).toList();

      final groupsResponse = await client
          .from('community_groups')
          .select()
          .filter('id', 'in', '(${groupIds.join(',')})')
          .order('member_count', ascending: false);

      return groupsResponse
          .map<CommunityGroup>((json) => CommunityGroup.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Failed to load groups near user: $error');
    }
  }

  // Get user's joined groups
  Future<List<CommunityGroup>> getUserGroups(String userId) async {
    try {
      final client = await _client;
      final response = await client
          .from('group_memberships')
          .select('''
            community_groups (*)
          ''')
          .eq('user_id', userId)
          .eq('is_active', true)
          .order('joined_at', ascending: false);

      return response
          .map<CommunityGroup>(
              (item) => CommunityGroup.fromJson(item['community_groups']))
          .toList();
    } catch (error) {
      throw Exception('Failed to load user groups: $error');
    }
  }

  // Get popular groups
  Future<List<CommunityGroup>> getPopularGroups({int limit = 10}) async {
    try {
      final client = await _client;
      final response = await client
          .from('community_groups')
          .select()
          .eq('visibility', 'public')
          .order('member_count', ascending: false)
          .order('is_verified', ascending: false)
          .limit(limit);

      return response
          .map<CommunityGroup>((json) => CommunityGroup.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Failed to load popular groups: $error');
    }
  }

  // Get recommended groups based on user profile
  Future<List<CommunityGroup>> getRecommendedGroups(String userId) async {
    try {
      final client = await _client;
      // Get user profile to understand their motorcycle preferences
      final userProfile = await client
          .from('user_profiles')
          .select('motorcycle_brand, city, state')
          .eq('id', userId)
          .single();

      var query =
          client.from('community_groups').select().eq('visibility', 'public');

      // Filter by same city/state if available
      if (userProfile['city'] != null) {
        query = query.eq('city', userProfile['city']);
      } else if (userProfile['state'] != null) {
        query = query.eq('state', userProfile['state']);
      }

      final response = await query
          .order('member_count', ascending: false)
          .order('is_verified', ascending: false)
          .limit(10);

      final groups = response
          .map<CommunityGroup>((json) => CommunityGroup.fromJson(json))
          .toList();

      // Filter out groups user is already a member of
      final userGroupIds = await _getUserGroupIds(userId);
      return groups.where((group) => !userGroupIds.contains(group.id)).toList();
    } catch (error) {
      throw Exception('Failed to load recommended groups: $error');
    }
  }

  // Get groups by category
  Future<List<CommunityGroup>> getGroupsByCategory(
    GroupCategory category, {
    String? userId,
    int limit = 20,
  }) async {
    try {
      final client = await _client;
      final response = await client
          .from('community_groups')
          .select()
          .eq('category', category.name)
          .eq('visibility', 'public')
          .order('member_count', ascending: false)
          .limit(limit);

      final groups = response
          .map<CommunityGroup>((json) => CommunityGroup.fromJson(json))
          .toList();

      // If user ID provided, filter out groups they're already in
      if (userId != null) {
        final userGroupIds = await _getUserGroupIds(userId);
        return groups
            .where((group) => !userGroupIds.contains(group.id))
            .toList();
      }

      return groups;
    } catch (error) {
      throw Exception('Failed to load groups by category: $error');
    }
  }

  // Search groups
  Future<List<CommunityGroup>> searchGroups(String query) async {
    try {
      final client = await _client;
      if (query.trim().isEmpty) return [];

      final response = await client
          .from('community_groups')
          .select()
          .eq('visibility', 'public')
          .or('name.ilike.%$query%,description.ilike.%$query%,city.ilike.%$query%')
          .order('member_count', ascending: false)
          .limit(20);

      return response
          .map<CommunityGroup>((json) => CommunityGroup.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Failed to search groups: $error');
    }
  }

  // Join a group
  Future<GroupMembership> joinGroup(String groupId) async {
    try {
      final client = await _client;
      final userId = client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await client
          .from('group_memberships')
          .insert({
            'group_id': groupId,
            'user_id': userId,
            'role': 'member',
            'is_active': true,
          })
          .select()
          .single();

      return GroupMembership.fromJson(response);
    } catch (error) {
      throw Exception('Failed to join group: $error');
    }
  }

  // Leave a group
  Future<void> leaveGroup(String groupId) async {
    try {
      final client = await _client;
      final userId = client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await client
          .from('group_memberships')
          .update({'is_active': false})
          .eq('group_id', groupId)
          .eq('user_id', userId);
    } catch (error) {
      throw Exception('Failed to leave group: $error');
    }
  }

  // Create a new group
  Future<CommunityGroup> createGroup({
    required String name,
    String? description,
    required GroupCategory category,
    required GroupVisibility visibility,
    String? city,
    String? state,
    String? coverImageUrl,
    String? rules,
    String? meetingLocation,
    String? meetingSchedule,
    List<String> motorcycleTypes = const [],
    int? minEngineSize,
    String? experienceLevel,
  }) async {
    try {
      final client = await _client;
      final userId = client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await client
          .from('community_groups')
          .insert({
            'name': name,
            'description': description,
            'category': category.name,
            'visibility': visibility.name,
            'city': city,
            'state': state,
            'cover_image_url': coverImageUrl,
            'rules': rules,
            'meeting_location': meetingLocation,
            'meeting_schedule': meetingSchedule,
            'motorcycle_types': motorcycleTypes,
            'min_engine_size': minEngineSize,
            'experience_level': experienceLevel,
            'created_by': userId,
          })
          .select()
          .single();

      final group = CommunityGroup.fromJson(response);

      // Automatically join the creator as owner
      await client.from('group_memberships').insert({
        'group_id': group.id,
        'user_id': userId,
        'role': 'owner',
        'is_active': true,
      });

      return group;
    } catch (error) {
      throw Exception('Failed to create group: $error');
    }
  }

  // Get group details with membership info
  Future<Map<String, dynamic>?> getGroupDetails(
      String groupId, String? userId) async {
    try {
      final client = await _client;
      final groupResponse = await client
          .from('community_groups')
          .select()
          .eq('id', groupId)
          .single();

      final group = CommunityGroup.fromJson(groupResponse);

      // Get user's membership status if logged in
      GroupMembership? membership;
      if (userId != null) {
        final membershipResponse = await client
            .from('group_memberships')
            .select()
            .eq('group_id', groupId)
            .eq('user_id', userId)
            .eq('is_active', true)
            .maybeSingle();

        if (membershipResponse != null) {
          membership = GroupMembership.fromJson(membershipResponse);
        }
      }

      // Get recent events
      final eventsResponse = await client
          .from('group_events')
          .select()
          .eq('group_id', groupId)
          .eq('is_cancelled', false)
          .gte('event_date', DateTime.now().toIso8601String())
          .order('event_date')
          .limit(5);

      final events = eventsResponse
          .map<GroupEvent>((json) => GroupEvent.fromJson(json))
          .toList();

      return {
        'group': group,
        'membership': membership,
        'events': events,
        'is_member': membership != null,
      };
    } catch (error) {
      throw Exception('Failed to load group details: $error');
    }
  }

  // Get group members
  Future<List<Map<String, dynamic>>> getGroupMembers(String groupId) async {
    try {
      final client = await _client;
      final response = await client.from('group_memberships').select('''
            *,
            user_profiles (
              id, full_name, avatar_url, city, state, motorcycle_brand, 
              motorcycle_model, level, total_rides
            )
          ''').eq('group_id', groupId).eq('is_active', true).order('joined_at');

      return response.cast<Map<String, dynamic>>();
    } catch (error) {
      throw Exception('Failed to load group members: $error');
    }
  }

  // Check if user is member of a group
  Future<bool> isGroupMember(String groupId, String userId) async {
    try {
      final client = await _client;
      final response = await client
          .from('group_memberships')
          .select('id')
          .eq('group_id', groupId)
          .eq('user_id', userId)
          .eq('is_active', true)
          .maybeSingle();

      return response != null;
    } catch (error) {
      return false;
    }
  }

  // Get community feed activity with improved filtering
  Future<List<Map<String, dynamic>>> getCommunityFeed({
    String? userId,
    int limit = 20,
    List<String>? specificUserIds,
  }) async {
    try {
      final client = await _client;
      // Get activities from groups user is part of, or public activities
      final List<String> groupIds = [];

      if (userId != null) {
        final userGroupsResponse = await client
            .from('group_memberships')
            .select('group_id')
            .eq('user_id', userId)
            .eq('is_active', true);

        groupIds.addAll(
          userGroupsResponse.map<String>((item) => item['group_id'] as String),
        );
      }

      // Get recent achievements from community members
      var achievementsQuery = client.from('user_achievements').select('''
            *,
            user_profiles (full_name, avatar_url, city, state),
            achievements (name, description, rarity, category)
          ''').eq('is_unlocked', true);

      // Apply specific user filter if provided
      if (specificUserIds != null && specificUserIds.isNotEmpty) {
        achievementsQuery = achievementsQuery.filter(
            'user_id', 'in', '(${specificUserIds.join(',')})');
      } else if (groupIds.isNotEmpty) {
        // If user has groups, prioritize activities from group members
        final groupMembersResponse = await client
            .from('group_memberships')
            .select('user_id')
            .filter('group_id', 'in', '(${groupIds.join(',')})')
            .eq('is_active', true);

        final memberIds = groupMembersResponse
            .map<String>((item) => item['user_id'] as String)
            .toSet()
            .toList();

        if (memberIds.isNotEmpty) {
          achievementsQuery = achievementsQuery.filter(
              'user_id', 'in', '(${memberIds.join(',')})');
        }
      }

      final achievementsResponse = await achievementsQuery
          .order('unlocked_at', ascending: false)
          .limit(limit);

      // Transform achievements into feed items
      final feedItems = achievementsResponse.map((item) {
        final profile = item['user_profiles'];
        final achievement = item['achievements'];

        return {
          'id': item['id'],
          'type': 'achievement',
          'userName': profile['full_name'] as String,
          'userAvatar': profile['avatar_url'] as String?,
          'action': 'desbloqueou conquista "${achievement['name']}"',
          'details': achievement['description'] as String,
          'timestamp':
              _formatTimestamp(DateTime.parse(item['unlocked_at'] as String)),
          'data': {
            'achievement_name': achievement['name'],
            'achievement_rarity': achievement['rarity'],
            'achievement_category': achievement['category'],
          },
        };
      }).toList();

      return feedItems;
    } catch (error) {
      throw Exception('Failed to load community feed: $error');
    }
  }

  // Helper method to get user's group IDs
  Future<List<String>> _getUserGroupIds(String userId) async {
    try {
      final client = await _client;
      final response = await client
          .from('group_memberships')
          .select('group_id')
          .eq('user_id', userId)
          .eq('is_active', true);

      return response
          .map<String>((item) => item['group_id'] as String)
          .toList();
    } catch (error) {
      return [];
    }
  }

  // Helper method to format timestamp
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return 'há ${difference.inMinutes} minutos';
    } else if (difference.inHours < 24) {
      return 'há ${difference.inHours} horas';
    } else if (difference.inDays < 7) {
      return 'há ${difference.inDays} dias';
    } else {
      return 'há ${(difference.inDays / 7).floor()} semanas';
    }
  }

  // Subscribe to real-time group updates
  RealtimeChannel subscribeToGroupUpdates({
    required Function(CommunityGroup) onGroupUpdate,
    required Function(GroupMembership) onMembershipUpdate,
  }) {
    final client = _supabaseService.clientSync;
    final channel = client
        .channel('community_updates')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'community_groups',
          callback: (payload) {
            try {
              if (payload.newRecord.isNotEmpty) {
                final group = CommunityGroup.fromJson(payload.newRecord);
                onGroupUpdate(group);
              }
            } catch (e) {
              print('Error processing group update: $e');
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'group_memberships',
          callback: (payload) {
            try {
              if (payload.newRecord.isNotEmpty) {
                final membership = GroupMembership.fromJson(payload.newRecord);
                onMembershipUpdate(membership);
              }
            } catch (e) {
              print('Error processing membership update: $e');
            }
          },
        )
        .subscribe();

    return channel;
  }

  // Clean up subscriptions
  void unsubscribeFromUpdates(RealtimeChannel channel) {
    _supabaseService.clientSync.removeChannel(channel);
  }
}
