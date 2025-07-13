import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math' as math;

import '../models/business.dart';
import './supabase_service.dart';

class MapService {
  static final MapService _instance = MapService._internal();
  factory MapService() => _instance;
  MapService._internal();

  late final SupabaseClient _client;
  bool _isInitialized = false;

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      final supabaseService = SupabaseService();
      _client = await supabaseService.client;
      _isInitialized = true;
    }
  }

  // Get businesses with optional filters
  Future<List<Business>> getBusinesses({
    List<String>? businessTypes,
    double? latitude,
    double? longitude,
    double? radiusKm,
    double? minimumRating,
    String? priceRange,
    String? searchQuery,
    int? limit,
    int? offset,
  }) async {
    await _ensureInitialized();

    try {
      var query = _client.from('businesses').select('*').eq('status', 'active');

      // Apply business type filter
      if (businessTypes != null && businessTypes.isNotEmpty) {
        query = query.inFilter('business_type', businessTypes);
      }

      // Apply rating filter
      if (minimumRating != null) {
        query = query.gte('average_rating', minimumRating);
      }

      // Apply price range filter
      if (priceRange != null) {
        query = query.eq('price_range', priceRange);
      }

      // Apply search query filter
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        query = query.or(
            'name.ilike.%$searchQuery%,address.ilike.%$searchQuery%,city.ilike.%$searchQuery%');
      }

      // Apply location-based filtering (simplified - in production use PostGIS)
      if (latitude != null && longitude != null && radiusKm != null) {
        final latRange = radiusKm / 111.0; // Rough degree conversion
        final lngRange =
            radiusKm / (111.0 * math.cos(latitude * math.pi / 180));

        query = query
            .gte('latitude', latitude - latRange)
            .lte('latitude', latitude + latRange)
            .gte('longitude', longitude - lngRange)
            .lte('longitude', longitude + lngRange);
      }

      // Apply ordering and pagination
      var transformedQuery = query.order('average_rating', ascending: false);

      if (limit != null) {
        transformedQuery = transformedQuery.limit(limit);
      }

      if (offset != null && offset > 0) {
        transformedQuery =
            transformedQuery.range(offset, offset + (limit ?? 50) - 1);
      }

      final response = await transformedQuery;

      return response.map((json) => Business.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to fetch businesses: $error');
    }
  }

  // Get business by ID with fuel prices and reviews
  Future<Map<String, dynamic>?> getBusinessDetails(String businessId) async {
    await _ensureInitialized();

    try {
      final results = await Future.wait([
        // Get business details
        _client.from('businesses').select('*').eq('id', businessId).single(),

        // Get fuel prices
        _client
            .from('fuel_prices')
            .select('*')
            .eq('business_id', businessId)
            .order('created_at', ascending: false),

        // Get recent reviews
        _client
            .from('business_reviews')
            .select('*, user_profiles(full_name, avatar_url)')
            .eq('business_id', businessId)
            .order('created_at', ascending: false)
            .limit(10),
      ]);

      final business = Business.fromJson(results[0] as Map<String, dynamic>);
      final fuelPrices =
          (results[1] as List).map((json) => FuelPrice.fromJson(json)).toList();
      final reviews = (results[2] as List)
          .map((json) => BusinessReview.fromJson(json))
          .toList();

      return {
        'business': business,
        'fuel_prices': fuelPrices,
        'reviews': reviews,
      };
    } catch (error) {
      throw Exception('Failed to fetch business details: $error');
    }
  }

  // Search businesses with autocomplete suggestions
  Future<List<Map<String, dynamic>>> searchBusinesses(String query) async {
    await _ensureInitialized();

    try {
      if (query.trim().isEmpty) return [];

      final response = await _client
          .from('businesses')
          .select(
              'id, name, business_type, address, city, state, average_rating')
          .eq('status', 'active')
          .or('name.ilike.%$query%,address.ilike.%$query%,city.ilike.%$query%')
          .order('average_rating', ascending: false)
          .limit(10);

      return response
          .map((json) => {
                'id': json['id'],
                'title': json['name'],
                'subtitle':
                    '${json['address']}, ${json['city']} - ${json['state']}',
                'type': json['business_type'],
                'rating': json['average_rating'],
              })
          .toList();
    } catch (error) {
      throw Exception('Search failed: $error');
    }
  }

  // Get fuel prices for multiple businesses
  Future<Map<String, List<FuelPrice>>> getFuelPrices(
      List<String> businessIds) async {
    await _ensureInitialized();

    try {
      final response = await _client
          .from('fuel_prices')
          .select('*')
          .inFilter('business_id', businessIds)
          .order('created_at', ascending: false);

      final Map<String, List<FuelPrice>> grouped = {};

      for (final json in response) {
        final fuelPrice = FuelPrice.fromJson(json);
        final businessId = fuelPrice.businessId;

        if (!grouped.containsKey(businessId)) {
          grouped[businessId] = [];
        }
        grouped[businessId]!.add(fuelPrice);
      }

      return grouped;
    } catch (error) {
      throw Exception('Failed to fetch fuel prices: $error');
    }
  }

  // Report new fuel price
  Future<FuelPrice> reportFuelPrice({
    required String businessId,
    required String fuelType,
    required double pricePerLiter,
    String currency = 'BRL',
  }) async {
    await _ensureInitialized();

    try {
      final response = await _client
          .from('fuel_prices')
          .insert({
            'business_id': businessId,
            'fuel_type': fuelType,
            'price_per_liter': pricePerLiter,
            'currency': currency,
            'reported_by': _client.auth.currentUser?.id,
          })
          .select()
          .single();

      return FuelPrice.fromJson(response);
    } catch (error) {
      throw Exception('Failed to report fuel price: $error');
    }
  }

  // Add business review
  Future<BusinessReview> addReview({
    required String businessId,
    required int rating,
    String? title,
    String? content,
    String reviewType = 'general',
    DateTime? visitDate,
    bool recommended = true,
    List<String>? photoUrls,
  }) async {
    await _ensureInitialized();

    try {
      final response = await _client
          .from('business_reviews')
          .insert({
            'business_id': businessId,
            'user_id': _client.auth.currentUser?.id,
            'rating': rating,
            'title': title,
            'content': content,
            'review_type': reviewType,
            'visit_date': visitDate?.toIso8601String(),
            'recommended': recommended,
            'photos': photoUrls ?? [],
          })
          .select()
          .single();

      return BusinessReview.fromJson(response);
    } catch (error) {
      throw Exception('Failed to add review: $error');
    }
  }

  // Toggle business favorite
  Future<bool> toggleBusinessFavorite(String businessId) async {
    await _ensureInitialized();

    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Check if already favorited
      final existing = await _client
          .from('user_favorite_businesses')
          .select('id')
          .eq('user_id', userId)
          .eq('business_id', businessId)
          .maybeSingle();

      if (existing != null) {
        // Remove from favorites
        await _client
            .from('user_favorite_businesses')
            .delete()
            .eq('id', existing['id']);
        return false;
      } else {
        // Add to favorites
        await _client.from('user_favorite_businesses').insert({
          'user_id': userId,
          'business_id': businessId,
        });
        return true;
      }
    } catch (error) {
      throw Exception('Failed to toggle favorite: $error');
    }
  }

  // Get user's favorite businesses
  Future<List<Business>> getUserFavorites() async {
    await _ensureInitialized();

    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _client
          .from('user_favorite_businesses')
          .select('businesses(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response
          .map((item) => Business.fromJson(item['businesses']))
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch favorites: $error');
    }
  }

  // Subscribe to real-time business updates
  RealtimeChannel subscribeToBusinessUpdates({
    required Function(Business) onInsert,
    required Function(Business) onUpdate,
    required Function(String) onDelete,
  }) {
    _ensureInitialized();

    final channel = _client
        .channel('businesses_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'businesses',
          callback: (payload) {
            try {
              final business = Business.fromJson(payload.newRecord);
              onInsert(business);
            } catch (e) {
              print('Error processing business insert: $e');
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'businesses',
          callback: (payload) {
            try {
              final business = Business.fromJson(payload.newRecord);
              onUpdate(business);
            } catch (e) {
              print('Error processing business update: $e');
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'businesses',
          callback: (payload) {
            try {
              final businessId = payload.oldRecord['id'] as String;
              onDelete(businessId);
            } catch (e) {
              print('Error processing business delete: $e');
            }
          },
        )
        .subscribe();

    return channel;
  }

  // Subscribe to real-time fuel price updates
  RealtimeChannel subscribeToFuelPriceUpdates({
    required Function(FuelPrice) onUpdate,
  }) {
    _ensureInitialized();

    final channel = _client
        .channel('fuel_prices_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'fuel_prices',
          callback: (payload) {
            try {
              if (payload.newRecord.isNotEmpty) {
                final fuelPrice = FuelPrice.fromJson(payload.newRecord);
                onUpdate(fuelPrice);
              }
            } catch (e) {
              print('Error processing fuel price update: $e');
            }
          },
        )
        .subscribe();

    return channel;
  }

  // Clean up subscriptions
  void unsubscribeFromUpdates(RealtimeChannel channel) {
    _client.removeChannel(channel);
  }

  // Calculate distance between two points (Haversine formula)
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
}
