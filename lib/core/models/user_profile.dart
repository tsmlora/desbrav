enum UserRole { admin, moderator, rider }

enum MotorcycleBrand {
  honda,
  yamaha,
  kawasaki,
  suzuki,
  bmw,
  ducati,
  harley_davidson,
  triumph,
  ktm,
  aprilia,
  other
}

enum ProfileVisibility { public, friends, private }

class UserProfile {
  final String id;
  final String email;
  final String fullName;
  final String? firstName;
  final String? lastName;
  final String? avatarUrl;
  final String? phone;
  final DateTime? dateOfBirth;

  // User settings
  final UserRole role;
  final bool isVerified;
  final bool isActive;

  // Motorcycle information
  final MotorcycleBrand? motorcycleBrand;
  final String? motorcycleModel;
  final int? motorcycleYear;
  final int? motorcycleDisplacement;

  // Location and preferences
  final String? city;
  final String? state;
  final String? country;
  final String? timezone;

  // Privacy settings
  final ProfileVisibility profileVisibility;
  final bool showLocation;
  final bool allowFriendRequests;

  // Gamification data
  final int level;
  final int totalXp;
  final double totalDistance;
  final int totalRides;
  final int totalCitiesVisited;

  // Metadata
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastActiveAt;

  const UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    this.firstName,
    this.lastName,
    this.avatarUrl,
    this.phone,
    this.dateOfBirth,
    this.role = UserRole.rider,
    this.isVerified = false,
    this.isActive = true,
    this.motorcycleBrand,
    this.motorcycleModel,
    this.motorcycleYear,
    this.motorcycleDisplacement,
    this.city,
    this.state,
    this.country = 'Brasil',
    this.timezone = 'America/Sao_Paulo',
    this.profileVisibility = ProfileVisibility.public,
    this.showLocation = true,
    this.allowFriendRequests = true,
    this.level = 1,
    this.totalXp = 0,
    this.totalDistance = 0.0,
    this.totalRides = 0,
    this.totalCitiesVisited = 0,
    required this.createdAt,
    required this.updatedAt,
    required this.lastActiveAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      phone: json['phone'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      role: _parseUserRole(json['role'] as String?),
      isVerified: json['is_verified'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      motorcycleBrand:
          _parseMotorcycleBrand(json['motorcycle_brand'] as String?),
      motorcycleModel: json['motorcycle_model'] as String?,
      motorcycleYear: json['motorcycle_year'] as int?,
      motorcycleDisplacement: json['motorcycle_displacement'] as int?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String? ?? 'Brasil',
      timezone: json['timezone'] as String? ?? 'America/Sao_Paulo',
      profileVisibility:
          _parseProfileVisibility(json['profile_visibility'] as String?),
      showLocation: json['show_location'] as bool? ?? true,
      allowFriendRequests: json['allow_friend_requests'] as bool? ?? true,
      level: json['level'] as int? ?? 1,
      totalXp: json['total_xp'] as int? ?? 0,
      totalDistance: (json['total_distance'] as num?)?.toDouble() ?? 0.0,
      totalRides: json['total_rides'] as int? ?? 0,
      totalCitiesVisited: json['total_cities_visited'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastActiveAt: DateTime.parse(json['last_active_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'first_name': firstName,
      'last_name': lastName,
      'avatar_url': avatarUrl,
      'phone': phone,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'role': role.name,
      'is_verified': isVerified,
      'is_active': isActive,
      'motorcycle_brand': motorcycleBrand?.name,
      'motorcycle_model': motorcycleModel,
      'motorcycle_year': motorcycleYear,
      'motorcycle_displacement': motorcycleDisplacement,
      'city': city,
      'state': state,
      'country': country,
      'timezone': timezone,
      'profile_visibility': profileVisibility.name,
      'show_location': showLocation,
      'allow_friend_requests': allowFriendRequests,
      'level': level,
      'total_xp': totalXp,
      'total_distance': totalDistance,
      'total_rides': totalRides,
      'total_cities_visited': totalCitiesVisited,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_active_at': lastActiveAt.toIso8601String(),
    };
  }

  static UserRole _parseUserRole(String? role) {
    switch (role) {
      case 'admin':
        return UserRole.admin;
      case 'moderator':
        return UserRole.moderator;
      case 'rider':
      default:
        return UserRole.rider;
    }
  }

  static MotorcycleBrand? _parseMotorcycleBrand(String? brand) {
    if (brand == null) return null;
    switch (brand) {
      case 'honda':
        return MotorcycleBrand.honda;
      case 'yamaha':
        return MotorcycleBrand.yamaha;
      case 'kawasaki':
        return MotorcycleBrand.kawasaki;
      case 'suzuki':
        return MotorcycleBrand.suzuki;
      case 'bmw':
        return MotorcycleBrand.bmw;
      case 'ducati':
        return MotorcycleBrand.ducati;
      case 'harley_davidson':
        return MotorcycleBrand.harley_davidson;
      case 'triumph':
        return MotorcycleBrand.triumph;
      case 'ktm':
        return MotorcycleBrand.ktm;
      case 'aprilia':
        return MotorcycleBrand.aprilia;
      case 'other':
      default:
        return MotorcycleBrand.other;
    }
  }

  static ProfileVisibility _parseProfileVisibility(String? visibility) {
    switch (visibility) {
      case 'friends':
        return ProfileVisibility.friends;
      case 'private':
        return ProfileVisibility.private;
      case 'public':
      default:
        return ProfileVisibility.public;
    }
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? fullName,
    String? firstName,
    String? lastName,
    String? avatarUrl,
    String? phone,
    DateTime? dateOfBirth,
    UserRole? role,
    bool? isVerified,
    bool? isActive,
    MotorcycleBrand? motorcycleBrand,
    String? motorcycleModel,
    int? motorcycleYear,
    int? motorcycleDisplacement,
    String? city,
    String? state,
    String? country,
    String? timezone,
    ProfileVisibility? profileVisibility,
    bool? showLocation,
    bool? allowFriendRequests,
    int? level,
    int? totalXp,
    double? totalDistance,
    int? totalRides,
    int? totalCitiesVisited,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastActiveAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      motorcycleBrand: motorcycleBrand ?? this.motorcycleBrand,
      motorcycleModel: motorcycleModel ?? this.motorcycleModel,
      motorcycleYear: motorcycleYear ?? this.motorcycleYear,
      motorcycleDisplacement:
          motorcycleDisplacement ?? this.motorcycleDisplacement,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      timezone: timezone ?? this.timezone,
      profileVisibility: profileVisibility ?? this.profileVisibility,
      showLocation: showLocation ?? this.showLocation,
      allowFriendRequests: allowFriendRequests ?? this.allowFriendRequests,
      level: level ?? this.level,
      totalXp: totalXp ?? this.totalXp,
      totalDistance: totalDistance ?? this.totalDistance,
      totalRides: totalRides ?? this.totalRides,
      totalCitiesVisited: totalCitiesVisited ?? this.totalCitiesVisited,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }

  // Helper methods
  String get displayName => fullName;

  String get initials {
    final nameParts = fullName.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts.first[0]}${nameParts.last[0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  String get motorcycleFullName {
    if (motorcycleBrand == null || motorcycleModel == null) {
      return 'Motocicleta não informada';
    }
    final brandName = _getBrandDisplayName(motorcycleBrand!);
    final year = motorcycleYear != null ? ' ($motorcycleYear)' : '';
    return '$brandName $motorcycleModel$year';
  }

  String _getBrandDisplayName(MotorcycleBrand brand) {
    switch (brand) {
      case MotorcycleBrand.honda:
        return 'Honda';
      case MotorcycleBrand.yamaha:
        return 'Yamaha';
      case MotorcycleBrand.kawasaki:
        return 'Kawasaki';
      case MotorcycleBrand.suzuki:
        return 'Suzuki';
      case MotorcycleBrand.bmw:
        return 'BMW';
      case MotorcycleBrand.ducati:
        return 'Ducati';
      case MotorcycleBrand.harley_davidson:
        return 'Harley-Davidson';
      case MotorcycleBrand.triumph:
        return 'Triumph';
      case MotorcycleBrand.ktm:
        return 'KTM';
      case MotorcycleBrand.aprilia:
        return 'Aprilia';
      case MotorcycleBrand.other:
        return 'Outra';
    }
  }

  int get nextLevelXp => level * 1000;

  double get levelProgress {
    final currentLevelXp = (level - 1) * 1000;
    final xpInCurrentLevel = totalXp - currentLevelXp;
    return xpInCurrentLevel / 1000;
  }

  bool get hasMotorcycleInfo =>
      motorcycleBrand != null && motorcycleModel != null;

  bool get isProfileComplete =>
      fullName.isNotEmpty && hasMotorcycleInfo && city != null && state != null;
}
