import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/supabase_service.dart';
import './widgets/accommodation_card_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/map_view_widget.dart';
import './widgets/search_bar_widget.dart';

class RestPointsScreen extends StatefulWidget {
  const RestPointsScreen({super.key});

  @override
  State<RestPointsScreen> createState() => _RestPointsScreenState();
}

class _RestPointsScreenState extends State<RestPointsScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final SupabaseService _supabaseService = SupabaseService();
  final Dio _dio = Dio();

  List<RestPointAccommodation> _accommodations = [];
  List<RestPointAccommodation> _filteredAccommodations = [];
  List<RestPointAccommodation> _favoriteAccommodations = [];

  bool _isLoading = true;
  bool _isMapView = true;
  bool _isRefreshing = false;
  String _currentLocation = 'São Paulo, SP';
  Position? _userPosition;

  // Filter variables
  double _minPrice = 50.0;
  double _maxPrice = 500.0;
  bool _needsParking = false;
  bool _needsChargingStation = false;
  bool _allowsGroups = false;
  String _selectedPriceRange = 'all';

  late AnimationController _viewToggleController;
  late Animation<double> _viewToggleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeDio();
    _loadUserLocation();
    _loadAccommodations();
    _loadFavorites();
  }

  void _initializeAnimations() {
    _viewToggleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _viewToggleAnimation = CurvedAnimation(
      parent: _viewToggleController,
      curve: Curves.easeInOut,
    );
  }

  void _initializeDio() {
    final supabaseUrl = const String.fromEnvironment('SUPABASE_URL');
    final anonKey = const String.fromEnvironment('SUPABASE_ANON_KEY');

    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $anonKey',
    };
  }

  Future<void> _loadUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      _userPosition = await Geolocator.getCurrentPosition();
      setState(() {
        _currentLocation = 'Localização Atual';
      });
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  Future<void> _loadAccommodations([String? location]) async {
    try {
      setState(() => _isLoading = true);

      // Simulate Airbnb API call with mock data
      await Future.delayed(const Duration(seconds: 1));

      final mockAccommodations = _generateMockAccommodations();

      // Save to Supabase for caching and offline access
      await _saveAccommodationsToSupabase(mockAccommodations);

      setState(() {
        _accommodations = mockAccommodations;
        _filteredAccommodations = mockAccommodations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Erro ao carregar acomodações: $e');
    }
  }

  List<RestPointAccommodation> _generateMockAccommodations() {
    return [
      RestPointAccommodation(
        id: '1',
        title: 'Pousada do Motociclista',
        description:
            'Acomodação especial para motociclistas com garagem segura',
        price: 120.0,
        currency: 'BRL',
        imageUrl:
            'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
        latitude: -23.5505,
        longitude: -46.6333,
        rating: 4.8,
        reviewCount: 156,
        hostName: 'Carlos Santos',
        hostImageUrl:
            'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
        amenities: [
          'Garagem Segura',
          'Wi-Fi',
          'Café da Manhã',
          'Oficina Básica'
        ],
        hasParking: true,
        hasChargingStation: false,
        allowsGroups: true,
        maxGuests: 4,
        priceRange: 'mid',
      ),
      RestPointAccommodation(
        id: '2',
        title: 'Hostel Adventure Riders',
        description: 'Hostel temático para aventureiros de duas rodas',
        price: 85.0,
        currency: 'BRL',
        imageUrl:
            'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
        latitude: -23.5615,
        longitude: -46.6455,
        rating: 4.5,
        reviewCount: 89,
        hostName: 'Marina Silva',
        hostImageUrl:
            'https://images.unsplash.com/photo-1494790108755-2616b612b601?w=150',
        amenities: [
          'Estacionamento',
          'Cozinha Compartilhada',
          'Área Social',
          'Mapas de Rota'
        ],
        hasParking: true,
        hasChargingStation: true,
        allowsGroups: true,
        maxGuests: 8,
        priceRange: 'budget',
      ),
      RestPointAccommodation(
        id: '3',
        title: 'Villa Premium Bikers',
        description: 'Villa de luxo com amenidades premium para motociclistas',
        price: 350.0,
        currency: 'BRL',
        imageUrl:
            'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800',
        latitude: -23.5405,
        longitude: -46.6255,
        rating: 4.9,
        reviewCount: 234,
        hostName: 'Roberto Lima',
        hostImageUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        amenities: [
          'Garagem Premium',
          'Spa',
          'Piscina',
          'Serviço de Limpeza',
          'Estação de Carga Elétrica'
        ],
        hasParking: true,
        hasChargingStation: true,
        allowsGroups: false,
        maxGuests: 2,
        priceRange: 'premium',
      ),
      RestPointAccommodation(
        id: '4',
        title: 'Camping Rota das Montanhas',
        description: 'Camping especializado em turismo de motocicleta',
        price: 45.0,
        currency: 'BRL',
        imageUrl:
            'https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?w=800',
        latitude: -23.5705,
        longitude: -46.6155,
        rating: 4.3,
        reviewCount: 67,
        hostName: 'Ana Pereira',
        hostImageUrl:
            'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
        amenities: ['Área de Camping', 'Banheiros', 'Fogueira', 'Trilhas'],
        hasParking: true,
        hasChargingStation: false,
        allowsGroups: true,
        maxGuests: 6,
        priceRange: 'budget',
      ),
    ];
  }

  Future<void> _saveAccommodationsToSupabase(
      List<RestPointAccommodation> accommodations) async {
    try {
      final client = await _supabaseService.client;

      for (final accommodation in accommodations) {
        await client.from('rest_point_accommodations').upsert({
          'id': accommodation.id,
          'title': accommodation.title,
          'description': accommodation.description,
          'price': accommodation.price,
          'currency': accommodation.currency,
          'image_url': accommodation.imageUrl,
          'latitude': accommodation.latitude,
          'longitude': accommodation.longitude,
          'rating': accommodation.rating,
          'review_count': accommodation.reviewCount,
          'host_name': accommodation.hostName,
          'host_image_url': accommodation.hostImageUrl,
          'amenities': accommodation.amenities,
          'has_parking': accommodation.hasParking,
          'has_charging_station': accommodation.hasChargingStation,
          'allows_groups': accommodation.allowsGroups,
          'max_guests': accommodation.maxGuests,
          'price_range': accommodation.priceRange,
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      debugPrint('Error saving to Supabase: $e');
    }
  }

  Future<void> _loadFavorites() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id;

      if (userId == null) return;

      final client = await _supabaseService.client;
      final response = await client
          .from('user_favorite_accommodations')
          .select('accommodation_id')
          .eq('user_id', userId);

      final favoriteIds = (response as List)
          .map((item) => item['accommodation_id'] as String)
          .toList();

      setState(() {
        _favoriteAccommodations = _accommodations
            .where((acc) => favoriteIds.contains(acc.id))
            .toList();
      });
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredAccommodations = _accommodations.where((accommodation) {
        bool matchesPrice = accommodation.price >= _minPrice &&
            accommodation.price <= _maxPrice;
        bool matchesParking = !_needsParking || accommodation.hasParking;
        bool matchesCharging =
            !_needsChargingStation || accommodation.hasChargingStation;
        bool matchesGroups = !_allowsGroups || accommodation.allowsGroups;
        bool matchesPriceRange = _selectedPriceRange == 'all' ||
            accommodation.priceRange == _selectedPriceRange;

        return matchesPrice &&
            matchesParking &&
            matchesCharging &&
            matchesGroups &&
            matchesPriceRange;
      }).toList();
    });
  }

  void _openFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheetWidget(
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        needsParking: _needsParking,
        needsChargingStation: _needsChargingStation,
        allowsGroups: _allowsGroups,
        selectedPriceRange: _selectedPriceRange,
        onFiltersChanged: (filters) {
          setState(() {
            _minPrice = filters['minPrice'];
            _maxPrice = filters['maxPrice'];
            _needsParking = filters['needsParking'];
            _needsChargingStation = filters['needsChargingStation'];
            _allowsGroups = filters['allowsGroups'];
            _selectedPriceRange = filters['selectedPriceRange'];
          });
          _applyFilters();
        },
      ),
    );
  }

  Future<void> _toggleFavorite(RestPointAccommodation accommodation) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id;

      if (userId == null) return;

      final client = await _supabaseService.client;
      final isFavorite =
          _favoriteAccommodations.any((fav) => fav.id == accommodation.id);

      if (isFavorite) {
        await client
            .from('user_favorite_accommodations')
            .delete()
            .eq('user_id', userId)
            .eq('accommodation_id', accommodation.id);

        setState(() {
          _favoriteAccommodations
              .removeWhere((fav) => fav.id == accommodation.id);
        });
        _showInfoSnackBar('Removido dos favoritos');
      } else {
        await client.from('user_favorite_accommodations').insert({
          'user_id': userId,
          'accommodation_id': accommodation.id,
          'created_at': DateTime.now().toIso8601String(),
        });

        setState(() {
          _favoriteAccommodations.add(accommodation);
        });
        _showInfoSnackBar('Adicionado aos favoritos');
      }

      HapticFeedback.mediumImpact();
    } catch (e) {
      _showErrorSnackBar('Erro ao atualizar favoritos: $e');
    }
  }

  void _toggleView() {
    setState(() {
      _isMapView = !_isMapView;
      if (_isMapView) {
        _viewToggleController.forward();
      } else {
        _viewToggleController.reverse();
      }
    });
    HapticFeedback.selectionClick();
  }

  Future<void> _refreshAccommodations() async {
    setState(() => _isRefreshing = true);
    await _loadAccommodations(_currentLocation);
    setState(() => _isRefreshing = false);
  }

  void _openAccommodationDetails(RestPointAccommodation accommodation) {
    HapticFeedback.selectionClick();
    // Navigate to detailed view - could be a new screen or modal
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAccommodationDetailModal(accommodation),
    );
  }

  Widget _buildAccommodationDetailModal(RestPointAccommodation accommodation) {
    final isFavorite =
        _favoriteAccommodations.any((fav) => fav.id == accommodation.id);

    return Container(
      height: 85.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 12.w,
            height: 0.5.h,
            margin: EdgeInsets.symmetric(vertical: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  Container(
                    height: 25.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image:
                            CachedNetworkImageProvider(accommodation.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 2.w,
                          right: 2.w,
                          child: GestureDetector(
                            onTap: () => _toggleFavorite(accommodation),
                            child: Container(
                              padding: EdgeInsets.all(2.w),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: CustomIconWidget(
                                iconName:
                                    isFavorite ? 'favorite' : 'favorite_border',
                                color: isFavorite
                                    ? AppTheme.errorLight
                                    : AppTheme.lightTheme.colorScheme
                                        .onSurfaceVariant,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),
                  // Title and price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          accommodation.title,
                          style: AppTheme.lightTheme.textTheme.headlineSmall
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'R\$ ${accommodation.price.toStringAsFixed(0)}',
                            style: AppTheme.lightTheme.textTheme.titleLarge
                                ?.copyWith(
                              color: AppTheme.primaryLight,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'por noite',
                            style: AppTheme.lightTheme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  // Rating and reviews
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'star',
                        color: AppTheme.warningLight,
                        size: 16,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        accommodation.rating.toString(),
                        style:
                            AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        '(${accommodation.reviewCount} avaliações)',
                        style: AppTheme.lightTheme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  // Description
                  Text(
                    'Descrição',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    accommodation.description,
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                  SizedBox(height: 2.h),
                  // Amenities
                  Text(
                    'Comodidades',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Wrap(
                    spacing: 2.w,
                    runSpacing: 1.h,
                    children: accommodation.amenities.map((amenity) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 3.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color:
                              AppTheme.lightTheme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          amenity,
                          style: AppTheme.lightTheme.textTheme.labelMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 2.h),
                  // Host info
                  Text(
                    'Anfitrião',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(
                                accommodation.hostImageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              accommodation.hostName,
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Especialista em turismo de moto',
                              style: AppTheme.lightTheme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
          // Book button
          Container(
            padding: EdgeInsets.all(4.w),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showInfoSnackBar('Redirecionando para reserva...');
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 6.h),
              ),
              child: Text('Reservar Agora'),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorLight,
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successLight,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _viewToggleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      elevation: 0,
      title: Text(
        'Pontos de Descanso',
        style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          onPressed: _toggleView,
          icon: AnimatedBuilder(
            animation: _viewToggleAnimation,
            builder: (context, child) {
              return CustomIconWidget(
                iconName: _isMapView ? 'list' : 'map',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 24,
              );
            },
          ),
        ),
        IconButton(
          onPressed: _openFilterBottomSheet,
          icon: CustomIconWidget(
            iconName: 'tune',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: EdgeInsets.all(4.w),
          child: SearchBarWidget(
            controller: _searchController,
            currentLocation: _currentLocation,
            onLocationChanged: (location) {
              setState(() => _currentLocation = location);
              _loadAccommodations(location);
            },
          ),
        ),
        // Content
        Expanded(
          child: _isLoading
              ? _buildLoadingState()
              : _isMapView
                  ? _buildMapView()
                  : _buildListView(),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
          SizedBox(height: 2.h),
          Text(
            'Buscando acomodações...',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    return MapViewWidget(
      accommodations: _filteredAccommodations,
      userPosition: _userPosition,
      onAccommodationSelected: _openAccommodationDetails,
      onFavoriteToggle: _toggleFavorite,
      favoriteIds: _favoriteAccommodations.map((acc) => acc.id).toList(),
    );
  }

  Widget _buildListView() {
    if (_filteredAccommodations.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refreshAccommodations,
      color: AppTheme.lightTheme.colorScheme.primary,
      child: ListView.builder(
        padding: EdgeInsets.all(4.w),
        itemCount: _filteredAccommodations.length,
        itemBuilder: (context, index) {
          final accommodation = _filteredAccommodations[index];
          final isFavorite =
              _favoriteAccommodations.any((fav) => fav.id == accommodation.id);

          return Padding(
            padding: EdgeInsets.only(bottom: 2.h),
            child: AccommodationCardWidget(
              accommodation: accommodation,
              isFavorite: isFavorite,
              onTap: () => _openAccommodationDetails(accommodation),
              onFavoriteToggle: () => _toggleFavorite(accommodation),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: CustomIconWidget(
              iconName: 'location_off',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 48,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            'Nenhuma acomodação encontrada',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Tente ajustar os filtros ou\nescolher outra localização',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _minPrice = 50.0;
                _maxPrice = 500.0;
                _needsParking = false;
                _needsChargingStation = false;
                _allowsGroups = false;
                _selectedPriceRange = 'all';
              });
              _applyFilters();
            },
            icon: CustomIconWidget(
              iconName: 'refresh',
              color: Colors.white,
              size: 20,
            ),
            label: Text('Limpar Filtros'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: 6.w,
                vertical: 1.5.h,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () async {
        await _loadUserLocation();
        _loadAccommodations();
      },
      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      child: CustomIconWidget(
        iconName: 'my_location',
        color: Colors.white,
        size: 24,
      ),
    );
  }
}

// Data Models
class RestPointAccommodation {
  final String id;
  final String title;
  final String description;
  final double price;
  final String currency;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final double rating;
  final int reviewCount;
  final String hostName;
  final String hostImageUrl;
  final List<String> amenities;
  final bool hasParking;
  final bool hasChargingStation;
  final bool allowsGroups;
  final int maxGuests;
  final String priceRange;

  RestPointAccommodation({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.currency,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.reviewCount,
    required this.hostName,
    required this.hostImageUrl,
    required this.amenities,
    required this.hasParking,
    required this.hasChargingStation,
    required this.allowsGroups,
    required this.maxGuests,
    required this.priceRange,
  });

  factory RestPointAccommodation.fromJson(Map<String, dynamic> json) {
    return RestPointAccommodation(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'BRL',
      imageUrl: json['image_url'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      hostName: json['host_name'] ?? '',
      hostImageUrl: json['host_image_url'] ?? '',
      amenities: List<String>.from(json['amenities'] ?? []),
      hasParking: json['has_parking'] ?? false,
      hasChargingStation: json['has_charging_station'] ?? false,
      allowsGroups: json['allows_groups'] ?? false,
      maxGuests: json['max_guests'] ?? 1,
      priceRange: json['price_range'] ?? 'mid',
    );
  }
}
