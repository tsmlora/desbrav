import 'package:supabase_flutter/supabase_flutter.dart';
import './supabase_service.dart';
import 'dart:math' as math;

class DailyStatistics {
  final String userId;
  final DateTime date;
  final double totalDistance;
  final int totalTimeMinutes;
  final double averageSpeed;
  final double maxSpeed;
  final int totalRides;
  final int xpEarned;
  final int citiesVisited;
  final int fuelStops;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DailyStatistics({
    required this.userId,
    required this.date,
    required this.totalDistance,
    required this.totalTimeMinutes,
    required this.averageSpeed,
    required this.maxSpeed,
    required this.totalRides,
    required this.xpEarned,
    required this.citiesVisited,
    required this.fuelStops,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DailyStatistics.fromJson(Map<String, dynamic> json) {
    return DailyStatistics(
      userId: json['user_id'] as String,
      date: DateTime.parse(json['date'] as String),
      totalDistance: (json['total_distance'] as num?)?.toDouble() ?? 0.0,
      totalTimeMinutes: json['total_time_minutes'] as int? ?? 0,
      averageSpeed: (json['average_speed'] as num?)?.toDouble() ?? 0.0,
      maxSpeed: (json['max_speed'] as num?)?.toDouble() ?? 0.0,
      totalRides: json['total_rides'] as int? ?? 0,
      xpEarned: json['xp_earned'] as int? ?? 0,
      citiesVisited: json['cities_visited'] as int? ?? 0,
      fuelStops: json['fuel_stops'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  String get formattedTime {
    final hours = totalTimeMinutes ~/ 60;
    final minutes = totalTimeMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}

class RideSession {
  final String id;
  final String userId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int? durationMinutes;
  final double totalDistance;
  final double averageSpeed;
  final double maxSpeed;
  final double? startLatitude;
  final double? startLongitude;
  final double? endLatitude;
  final double? endLongitude;
  final List<String> citiesVisited;
  final List<String> placesVisited;
  final int fuelStops;
  final int xpEarned;
  final List<String> achievementsUnlocked;
  final bool isCompleted;
  final bool isVerified;

  const RideSession({
    required this.id,
    required this.userId,
    required this.startedAt,
    this.endedAt,
    this.durationMinutes,
    required this.totalDistance,
    required this.averageSpeed,
    required this.maxSpeed,
    this.startLatitude,
    this.startLongitude,
    this.endLatitude,
    this.endLongitude,
    required this.citiesVisited,
    required this.placesVisited,
    required this.fuelStops,
    required this.xpEarned,
    required this.achievementsUnlocked,
    required this.isCompleted,
    required this.isVerified,
  });

  factory RideSession.fromJson(Map<String, dynamic> json) {
    return RideSession(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      startedAt: DateTime.parse(json['started_at'] as String),
      endedAt: json['ended_at'] != null
          ? DateTime.parse(json['ended_at'] as String)
          : null,
      durationMinutes: json['duration_minutes'] as int?,
      totalDistance: (json['total_distance'] as num?)?.toDouble() ?? 0.0,
      averageSpeed: (json['average_speed'] as num?)?.toDouble() ?? 0.0,
      maxSpeed: (json['max_speed'] as num?)?.toDouble() ?? 0.0,
      startLatitude: (json['start_latitude'] as num?)?.toDouble(),
      startLongitude: (json['start_longitude'] as num?)?.toDouble(),
      endLatitude: (json['end_latitude'] as num?)?.toDouble(),
      endLongitude: (json['end_longitude'] as num?)?.toDouble(),
      citiesVisited: List<String>.from(json['cities_visited'] as List? ?? []),
      placesVisited: List<String>.from(json['places_visited'] as List? ?? []),
      fuelStops: json['fuel_stops'] as int? ?? 0,
      xpEarned: json['xp_earned'] as int? ?? 0,
      achievementsUnlocked:
          List<String>.from(json['achievements_unlocked'] as List? ?? []),
      isCompleted: json['is_completed'] as bool? ?? false,
      isVerified: json['is_verified'] as bool? ?? false,
    );
  }
}

class StatisticsService {
  final SupabaseService _supabaseService = SupabaseService();

  Future<SupabaseClient> get _client async => await _supabaseService.client;

  // Get today's statistics for a user
  Future<DailyStatistics?> getTodayStatistics(String userId) async {
    try {
      final client = await _client;
      final today = DateTime.now();
      final todayString =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final response = await client
          .from('user_daily_statistics')
          .select()
          .eq('user_id', userId)
          .eq('date', todayString)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return DailyStatistics.fromJson(response);
    } catch (error) {
      throw Exception('Failed to load today statistics: $error');
    }
  }

  // Get statistics for a specific date
  Future<DailyStatistics?> getStatisticsForDate(
      String userId, DateTime date) async {
    try {
      final client = await _client;
      final dateString =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final response = await client
          .from('user_daily_statistics')
          .select()
          .eq('user_id', userId)
          .eq('date', dateString)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return DailyStatistics.fromJson(response);
    } catch (error) {
      throw Exception('Failed to load statistics for date: $error');
    }
  }

  // Get historical statistics (last N days)
  Future<List<DailyStatistics>> getHistoricalStatistics(
    String userId, {
    int days = 7,
  }) async {
    try {
      final client = await _client;
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));

      final response = await client
          .from('user_daily_statistics')
          .select()
          .eq('user_id', userId)
          .gte('date', startDate.toIso8601String().split('T')[0])
          .lte('date', endDate.toIso8601String().split('T')[0])
          .order('date', ascending: false);

      return response
          .map<DailyStatistics>((json) => DailyStatistics.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Failed to load historical statistics: $error');
    }
  }

  // Get weekly summary
  Future<Map<String, dynamic>> getWeeklyStatistics(String userId) async {
    try {
      final client = await _client;
      final today = DateTime.now();
      final weekStart = today.subtract(Duration(days: today.weekday - 1));
      final weekEnd = weekStart.add(Duration(days: 6));

      final response = await client
          .from('user_daily_statistics')
          .select()
          .eq('user_id', userId)
          .gte('date', weekStart.toIso8601String().split('T')[0])
          .lte('date', weekEnd.toIso8601String().split('T')[0]);

      if (response.isEmpty) {
        return {
          'total_distance': 0.0,
          'total_time': 0,
          'total_rides': 0,
          'total_xp': 0,
          'avg_speed': 0.0,
          'max_speed': 0.0,
          'days_active': 0,
        };
      }

      double totalDistance = 0;
      int totalTime = 0;
      int totalRides = 0;
      int totalXp = 0;
      double maxSpeed = 0;
      List<double> speeds = [];
      int daysActive = 0;

      for (final item in response) {
        final stats = DailyStatistics.fromJson(item);
        totalDistance += stats.totalDistance;
        totalTime += stats.totalTimeMinutes;
        totalRides += stats.totalRides;
        totalXp += stats.xpEarned;
        maxSpeed = math.max(maxSpeed, stats.maxSpeed);
        if (stats.averageSpeed > 0) {
          speeds.add(stats.averageSpeed);
        }
        if (stats.totalRides > 0) {
          daysActive++;
        }
      }

      final avgSpeed = speeds.isNotEmpty
          ? speeds.reduce((a, b) => a + b) / speeds.length
          : 0.0;

      return {
        'total_distance': totalDistance,
        'total_time': totalTime,
        'total_rides': totalRides,
        'total_xp': totalXp,
        'avg_speed': avgSpeed,
        'max_speed': maxSpeed,
        'days_active': daysActive,
      };
    } catch (error) {
      throw Exception('Failed to load weekly statistics: $error');
    }
  }

  // Get monthly summary
  Future<Map<String, dynamic>> getMonthlyStatistics(
      String userId, DateTime month) async {
    try {
      final client = await _client;
      final monthStart = DateTime(month.year, month.month, 1);
      final monthEnd = DateTime(month.year, month.month + 1, 0);

      final response = await client
          .from('user_daily_statistics')
          .select()
          .eq('user_id', userId)
          .gte('date', monthStart.toIso8601String().split('T')[0])
          .lte('date', monthEnd.toIso8601String().split('T')[0]);

      if (response.isEmpty) {
        return {
          'total_distance': 0.0,
          'total_time': 0,
          'total_rides': 0,
          'total_xp': 0,
          'avg_speed': 0.0,
          'max_speed': 0.0,
          'days_active': 0,
          'cities_visited': 0,
          'fuel_stops': 0,
        };
      }

      double totalDistance = 0;
      int totalTime = 0;
      int totalRides = 0;
      int totalXp = 0;
      double maxSpeed = 0;
      List<double> speeds = [];
      int daysActive = 0;
      int citiesVisited = 0;
      int fuelStops = 0;

      for (final item in response) {
        final stats = DailyStatistics.fromJson(item);
        totalDistance += stats.totalDistance;
        totalTime += stats.totalTimeMinutes;
        totalRides += stats.totalRides;
        totalXp += stats.xpEarned;
        citiesVisited += stats.citiesVisited;
        fuelStops += stats.fuelStops;
        maxSpeed = math.max(maxSpeed, stats.maxSpeed);
        if (stats.averageSpeed > 0) {
          speeds.add(stats.averageSpeed);
        }
        if (stats.totalRides > 0) {
          daysActive++;
        }
      }

      final avgSpeed = speeds.isNotEmpty
          ? speeds.reduce((a, b) => a + b) / speeds.length
          : 0.0;

      return {
        'total_distance': totalDistance,
        'total_time': totalTime,
        'total_rides': totalRides,
        'total_xp': totalXp,
        'avg_speed': avgSpeed,
        'max_speed': maxSpeed,
        'days_active': daysActive,
        'cities_visited': citiesVisited,
        'fuel_stops': fuelStops,
      };
    } catch (error) {
      throw Exception('Failed to load monthly statistics: $error');
    }
  }

  // Start a new ride session
  Future<RideSession> startRideSession({
    required double startLatitude,
    required double startLongitude,
    String? motorcycleUsed,
    String? weatherConditions,
    int? temperatureCelsius,
  }) async {
    try {
      final client = await _client;
      final userId = client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await client
          .from('ride_sessions')
          .insert({
            'user_id': userId,
            'started_at': DateTime.now().toIso8601String(),
            'start_latitude': startLatitude,
            'start_longitude': startLongitude,
            'motorcycle_used': motorcycleUsed,
            'weather_conditions': weatherConditions,
            'temperature_celsius': temperatureCelsius,
            'is_completed': false,
          })
          .select()
          .single();

      return RideSession.fromJson(response);
    } catch (error) {
      throw Exception('Failed to start ride session: $error');
    }
  }

  // End a ride session
  Future<RideSession> endRideSession({
    required String sessionId,
    required double endLatitude,
    required double endLongitude,
    required double totalDistance,
    required double averageSpeed,
    required double maxSpeed,
    List<String> citiesVisited = const [],
    List<String> placesVisited = const [],
    int fuelStops = 0,
    int xpEarned = 0,
    List<String> achievementsUnlocked = const [],
  }) async {
    try {
      final client = await _client;
      final endedAt = DateTime.now();
      final response = await client
          .from('ride_sessions')
          .update({
            'ended_at': endedAt.toIso8601String(),
            'end_latitude': endLatitude,
            'end_longitude': endLongitude,
            'total_distance': totalDistance,
            'average_speed': averageSpeed,
            'max_speed': maxSpeed,
            'cities_visited': citiesVisited,
            'places_visited': placesVisited,
            'fuel_stops': fuelStops,
            'xp_earned': xpEarned,
            'achievements_unlocked': achievementsUnlocked,
            'is_completed': true,
          })
          .eq('id', sessionId)
          .select()
          .single();

      return RideSession.fromJson(response);
    } catch (error) {
      throw Exception('Failed to end ride session: $error');
    }
  }

  // Get user's ride sessions with improved filtering
  Future<List<RideSession>> getUserRideSessions(
    String userId, {
    int limit = 10,
    int offset = 0,
    List<String>? sessionIds,
  }) async {
    try {
      final client = await _client;
      var query = client
          .from('ride_sessions')
          .select()
          .eq('user_id', userId)
          .eq('is_completed', true);

      // Apply session ID filter if provided
      if (sessionIds != null && sessionIds.isNotEmpty) {
        // Use filter with 'in' operator instead of deprecated inFilter
        query = query.filter('id', 'in', '(${sessionIds.join(',')})');
      }

      final response = await query
          .order('started_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response
          .map<RideSession>((json) => RideSession.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Failed to load ride sessions: $error');
    }
  }

  // Get statistics using database function for better performance
  Future<Map<String, dynamic>> getTodayStatisticsFromFunction(
      String userId) async {
    try {
      final client = await _client;
      final response =
          await client.rpc('get_user_statistics_for_date', params: {
        'target_user_id': userId,
        'target_date': DateTime.now().toIso8601String().split('T')[0],
      });

      if (response.isEmpty) {
        return {
          'distance': 0.0,
          'time': '0m',
          'avgSpeed': 0.0,
          'maxSpeed': 0.0,
          'rides': 0,
          'xpEarned': 0,
        };
      }

      final data = response[0];
      final timeMinutes = data['time_minutes'] as int;
      final hours = timeMinutes ~/ 60;
      final minutes = timeMinutes % 60;
      final timeFormatted = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';

      return {
        'distance': (data['distance'] as num).toDouble(),
        'time': timeFormatted,
        'avgSpeed': (data['avg_speed'] as num).toDouble(),
        'maxSpeed': (data['max_speed'] as num).toDouble(),
        'rides': data['rides'] as int,
        'xpEarned': data['xp_earned'] as int,
      };
    } catch (error) {
      throw Exception('Failed to load statistics from function: $error');
    }
  }

  // Check if user has any statistics data
  Future<bool> hasStatisticsData(String userId) async {
    try {
      final client = await _client;
      final response = await client
          .from('user_daily_statistics')
          .select('id')
          .eq('user_id', userId)
          .limit(1);

      return response.isNotEmpty;
    } catch (error) {
      return false;
    }
  }

  // Update ride session in real-time
  Future<void> updateRideSession({
    required String sessionId,
    double? currentLatitude,
    double? currentLongitude,
    double? currentSpeed,
    double? totalDistance,
  }) async {
    try {
      final client = await _client;
      final updateData = <String, dynamic>{};

      if (currentLatitude != null)
        updateData['current_latitude'] = currentLatitude;
      if (currentLongitude != null)
        updateData['current_longitude'] = currentLongitude;
      if (currentSpeed != null) updateData['current_speed'] = currentSpeed;
      if (totalDistance != null) updateData['total_distance'] = totalDistance;

      if (updateData.isNotEmpty) {
        await client
            .from('ride_sessions')
            .update(updateData)
            .eq('id', sessionId);
      }
    } catch (error) {
      throw Exception('Failed to update ride session: $error');
    }
  }
}
