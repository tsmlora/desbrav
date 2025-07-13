class Business {
  final String id;
  final String name;
  final String businessType;
  final String status;
  final double latitude;
  final double longitude;
  final String address;
  final String city;
  final String state;
  final String? postalCode;
  final String country;
  final String? phone;
  final String? email;
  final String? website;
  final String? description;
  final List<String> amenities;
  final Map<String, String>? operatingHours;
  final String? priceRange;
  final double averageRating;
  final int totalReviews;
  final String? primaryImageUrl;
  final List<String> imageUrls;
  final bool isVerified;
  final bool isFeatured;
  final String? addedBy;
  final String? verifiedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? verifiedAt;

  // Additional computed property for distance
  double? distance;

  Business({
    required this.id,
    required this.name,
    required this.businessType,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.city,
    required this.state,
    this.postalCode,
    required this.country,
    this.phone,
    this.email,
    this.website,
    this.description,
    required this.amenities,
    this.operatingHours,
    this.priceRange,
    required this.averageRating,
    required this.totalReviews,
    this.primaryImageUrl,
    required this.imageUrls,
    required this.isVerified,
    required this.isFeatured,
    this.addedBy,
    this.verifiedBy,
    required this.createdAt,
    required this.updatedAt,
    this.verifiedAt,
    this.distance,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id'] as String,
      name: json['name'] as String,
      businessType: json['business_type'] as String,
      status: json['status'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      postalCode: json['postal_code'] as String?,
      country: json['country'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      description: json['description'] as String?,
      amenities: List<String>.from(json['amenities'] ?? []),
      operatingHours: json['operating_hours'] != null
          ? Map<String, String>.from(json['operating_hours'])
          : null,
      priceRange: json['price_range'] as String?,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: (json['total_reviews'] as num?)?.toInt() ?? 0,
      primaryImageUrl: json['primary_image_url'] as String?,
      imageUrls: List<String>.from(json['image_urls'] ?? []),
      isVerified: json['is_verified'] as bool? ?? false,
      isFeatured: json['is_featured'] as bool? ?? false,
      addedBy: json['added_by'] as String?,
      verifiedBy: json['verified_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'business_type': businessType,
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'country': country,
      'phone': phone,
      'email': email,
      'website': website,
      'description': description,
      'amenities': amenities,
      'operating_hours': operatingHours,
      'price_range': priceRange,
      'average_rating': averageRating,
      'total_reviews': totalReviews,
      'primary_image_url': primaryImageUrl,
      'image_urls': imageUrls,
      'is_verified': isVerified,
      'is_featured': isFeatured,
      'added_by': addedBy,
      'verified_by': verifiedBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'verified_at': verifiedAt?.toIso8601String(),
    };
  }

  Business copyWith({
    String? id,
    String? name,
    String? businessType,
    String? status,
    double? latitude,
    double? longitude,
    String? address,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    String? phone,
    String? email,
    String? website,
    String? description,
    List<String>? amenities,
    Map<String, String>? operatingHours,
    String? priceRange,
    double? averageRating,
    int? totalReviews,
    String? primaryImageUrl,
    List<String>? imageUrls,
    bool? isVerified,
    bool? isFeatured,
    String? addedBy,
    String? verifiedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? verifiedAt,
    double? distance,
  }) {
    return Business(
      id: id ?? this.id,
      name: name ?? this.name,
      businessType: businessType ?? this.businessType,
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      description: description ?? this.description,
      amenities: amenities ?? this.amenities,
      operatingHours: operatingHours ?? this.operatingHours,
      priceRange: priceRange ?? this.priceRange,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      primaryImageUrl: primaryImageUrl ?? this.primaryImageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      isVerified: isVerified ?? this.isVerified,
      isFeatured: isFeatured ?? this.isFeatured,
      addedBy: addedBy ?? this.addedBy,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      distance: distance ?? this.distance,
    );
  }

  // Helper methods
  String get displayAddress => '$address, $city - $state';

  String get businessTypeDisplay {
    switch (businessType) {
      case 'gas_station':
        return 'Posto de Combustível';
      case 'workshop':
        return 'Oficina';
      case 'restaurant':
        return 'Restaurante';
      case 'hotel':
        return 'Hotel/Pousada';
      case 'tourist_spot':
        return 'Ponto Turístico';
      default:
        return businessType;
    }
  }

  String get priceRangeDisplay {
    switch (priceRange) {
      case 'budget':
        return 'Econômico';
      case 'moderate':
        return 'Moderado';
      case 'expensive':
        return 'Caro';
      case 'luxury':
        return 'Luxo';
      default:
        return 'Não informado';
    }
  }

  bool get isOpen {
    if (operatingHours == null) return true;

    final now = DateTime.now();
    final weekday = _getWeekdayKey(now.weekday);
    final hours = operatingHours![weekday];

    if (hours == null || hours == 'closed') return false;
    if (hours == '00:00-23:59') return true;

    try {
      final parts = hours.split('-');
      if (parts.length != 2) return true;

      final openTime = _parseTime(parts[0]);
      final closeTime = _parseTime(parts[1]);
      final currentTime = now.hour * 60 + now.minute;

      return currentTime >= openTime && currentTime <= closeTime;
    } catch (e) {
      return true; // Default to open if parsing fails
    }
  }

  String _getWeekdayKey(int weekday) {
    switch (weekday) {
      case 1:
        return 'monday';
      case 2:
        return 'tuesday';
      case 3:
        return 'wednesday';
      case 4:
        return 'thursday';
      case 5:
        return 'friday';
      case 6:
        return 'saturday';
      case 7:
        return 'sunday';
      default:
        return 'monday';
    }
  }

  int _parseTime(String time) {
    final parts = time.split(':');
    if (parts.length != 2) return 0;

    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;

    return hour * 60 + minute;
  }

  @override
  String toString() {
    return 'Business(id: $id, name: $name, type: $businessType, rating: $averageRating)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Business && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Fuel Price Model
class FuelPrice {
  final String id;
  final String businessId;
  final String fuelType;
  final double pricePerLiter;
  final String currency;
  final String? reportedBy;
  final String? verifiedBy;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? verifiedAt;

  FuelPrice({
    required this.id,
    required this.businessId,
    required this.fuelType,
    required this.pricePerLiter,
    required this.currency,
    this.reportedBy,
    this.verifiedBy,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
    this.verifiedAt,
  });

  factory FuelPrice.fromJson(Map<String, dynamic> json) {
    return FuelPrice(
      id: json['id'] as String,
      businessId: json['business_id'] as String,
      fuelType: json['fuel_type'] as String,
      pricePerLiter: (json['price_per_liter'] as num).toDouble(),
      currency: json['currency'] as String,
      reportedBy: json['reported_by'] as String?,
      verifiedBy: json['verified_by'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'] as String)
          : null,
    );
  }

  String get fuelTypeDisplay {
    switch (fuelType) {
      case 'gasoline_common':
        return 'Gasolina Comum';
      case 'gasoline_premium':
        return 'Gasolina Premium';
      case 'ethanol':
        return 'Etanol';
      case 'diesel':
        return 'Diesel';
      default:
        return fuelType;
    }
  }

  String get formattedPrice => 'R\$ ${pricePerLiter.toStringAsFixed(3)}';

  String get lastUpdated {
    final difference = DateTime.now().difference(updatedAt);
    if (difference.inMinutes < 60) {
      return 'Há ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Há ${difference.inHours}h';
    } else {
      return 'Há ${difference.inDays} dias';
    }
  }
}

// Business Review Model
class BusinessReview {
  final String id;
  final String businessId;
  final String userId;
  final int rating;
  final String? title;
  final String? content;
  final String reviewType;
  final DateTime? visitDate;
  final bool recommended;
  final List<String> photos;
  final bool isVerified;
  final bool isFeatured;
  final DateTime createdAt;
  final DateTime updatedAt;

  BusinessReview({
    required this.id,
    required this.businessId,
    required this.userId,
    required this.rating,
    this.title,
    this.content,
    required this.reviewType,
    this.visitDate,
    required this.recommended,
    required this.photos,
    required this.isVerified,
    required this.isFeatured,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BusinessReview.fromJson(Map<String, dynamic> json) {
    return BusinessReview(
      id: json['id'] as String,
      businessId: json['business_id'] as String,
      userId: json['user_id'] as String,
      rating: json['rating'] as int,
      title: json['title'] as String?,
      content: json['content'] as String?,
      reviewType: json['review_type'] as String,
      visitDate: json['visit_date'] != null
          ? DateTime.parse(json['visit_date'] as String)
          : null,
      recommended: json['recommended'] as bool? ?? true,
      photos: List<String>.from(json['photos'] ?? []),
      isVerified: json['is_verified'] as bool? ?? false,
      isFeatured: json['is_featured'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  String get timeAgo {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inMinutes < 60) {
      return 'Há ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Há ${difference.inHours}h';
    } else if (difference.inDays < 30) {
      return 'Há ${difference.inDays} dias';
    } else {
      return 'Há ${(difference.inDays / 30).floor()} meses';
    }
  }
}
