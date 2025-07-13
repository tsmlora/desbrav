import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_export.dart';
import '../../core/models/business.dart';
import '../../core/services/map_service.dart';
import './widgets/enhanced_business_preview_card.dart';
import './widgets/enhanced_map_filter_bottom_sheet.dart';
import './widgets/enhanced_map_search_bar.dart';
import './widgets/map_marker_widget.dart';
import './widgets/real_time_fuel_price_widget.dart';

class EnhancedInteractiveMapScreen extends StatefulWidget {
  const EnhancedInteractiveMapScreen({Key? key}) : super(key: key);

  @override
  State<EnhancedInteractiveMapScreen> createState() =>
      _EnhancedInteractiveMapScreenState();
}

class _EnhancedInteractiveMapScreenState
    extends State<EnhancedInteractiveMapScreen> with TickerProviderStateMixin {
  late AnimationController _filterAnimationController;
  late AnimationController _markerAnimationController;
  late AnimationController _locationAnimationController;

  final MapService _mapService = MapService();

  // UI State
  String _selectedMapType = 'standard';
  bool _isRoutePlanningMode = false;
  bool _showBusinessPreview = false;
  Business? _selectedBusiness;
  bool _isLoading = true;
  String? _errorMessage;

  // User location
  double? _userLatitude;
  double? _userLongitude;
  bool _isLocationLoading = false;

  // Filter states
  Map<String, bool> _businessTypeFilters = {
    'gas_station': true,
    'workshop': true,
    'restaurant': true,
    'hotel': true,
    'tourist_spot': false,
  };
  double _distanceRadius = 25.0; // kilometers
  double _minimumRating = 0.0;
  String? _selectedPriceRange;
  String _searchQuery = '';

  // Data
  List<Business> _businesses = [];
  List<Business> _filteredBusinesses = [];
  Map<String, List<FuelPrice>> _fuelPrices = {};

  // Real-time subscriptions
  RealtimeChannel? _businessChannel;
  RealtimeChannel? _fuelPriceChannel;

  @override
  void initState() {
    super.initState();
    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _markerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _locationAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _initializeMap();
  }

  @override
  void dispose() {
    _filterAnimationController.dispose();
    _markerAnimationController.dispose();
    _locationAnimationController.dispose();
    _cleanupSubscriptions();
    super.dispose();
  }

  Future<void> _initializeMap() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Simulate getting user location (in production, use geolocator package)
      _userLatitude = -23.5505;
      _userLongitude = -46.6333;

      // Load initial business data
      await _loadBusinesses();

      // Setup real-time subscriptions
      _setupRealtimeSubscriptions();

      // Start marker animation
      _markerAnimationController.forward();

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao carregar mapa: $error';
      });
    }
  }

  Future<void> _loadBusinesses() async {
    try {
      final businesses = await _mapService.getBusinesses(
        businessTypes: _getActiveBusinessTypes(),
        latitude: _userLatitude,
        longitude: _userLongitude,
        radiusKm: _distanceRadius,
        minimumRating: _minimumRating > 0 ? _minimumRating : null,
        priceRange: _selectedPriceRange,
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
        limit: 100,
      );

      // Calculate distances
      for (final business in businesses) {
        if (_userLatitude != null && _userLongitude != null) {
          business.distance = _mapService.calculateDistance(
            _userLatitude!,
            _userLongitude!,
            business.latitude,
            business.longitude,
          );
        }
      }

      // Load fuel prices for gas stations
      final gasStationIds = businesses
          .where((b) => b.businessType == 'gas_station')
          .map((b) => b.id)
          .toList();

      if (gasStationIds.isNotEmpty) {
        final fuelPrices = await _mapService.getFuelPrices(gasStationIds);
        _fuelPrices = fuelPrices;
      }

      setState(() {
        _businesses = businesses;
        _applyFilters();
      });
    } catch (error) {
      print('Error loading businesses: $error');
      setState(() {
        _errorMessage = 'Erro ao carregar estabelecimentos';
      });
    }
  }

  void _setupRealtimeSubscriptions() {
    try {
      _businessChannel = _mapService.subscribeToBusinessUpdates(
        onInsert: (business) {
          if (_shouldIncludeBusiness(business)) {
            setState(() {
              _businesses.add(business);
              _applyFilters();
            });
          }
        },
        onUpdate: (business) {
          setState(() {
            final index = _businesses.indexWhere((b) => b.id == business.id);
            if (index != -1) {
              _businesses[index] = business;
              _applyFilters();
            }
          });
        },
        onDelete: (businessId) {
          setState(() {
            _businesses.removeWhere((b) => b.id == businessId);
            _applyFilters();
          });
        },
      );

      _fuelPriceChannel = _mapService.subscribeToFuelPriceUpdates(
        onUpdate: (fuelPrice) {
          setState(() {
            final businessId = fuelPrice.businessId;
            if (!_fuelPrices.containsKey(businessId)) {
              _fuelPrices[businessId] = [];
            }

            // Replace or add the fuel price
            final existingIndex = _fuelPrices[businessId]!
                .indexWhere((fp) => fp.fuelType == fuelPrice.fuelType);

            if (existingIndex != -1) {
              _fuelPrices[businessId]![existingIndex] = fuelPrice;
            } else {
              _fuelPrices[businessId]!.add(fuelPrice);
            }
          });
        },
      );
    } catch (error) {
      print('Error setting up subscriptions: $error');
    }
  }

  void _cleanupSubscriptions() {
    if (_businessChannel != null) {
      _mapService.unsubscribeFromUpdates(_businessChannel!);
    }
    if (_fuelPriceChannel != null) {
      _mapService.unsubscribeFromUpdates(_fuelPriceChannel!);
    }
  }

  List<String> _getActiveBusinessTypes() {
    return _businessTypeFilters.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
  }

  bool _shouldIncludeBusiness(Business business) {
    if (!_businessTypeFilters[business.businessType]!) return false;
    if (_minimumRating > 0 && business.averageRating < _minimumRating)
      return false;
    if (_selectedPriceRange != null &&
        business.priceRange != _selectedPriceRange) return false;

    if (_userLatitude != null && _userLongitude != null) {
      final distance = _mapService.calculateDistance(
        _userLatitude!,
        _userLongitude!,
        business.latitude,
        business.longitude,
      );
      if (distance > _distanceRadius) return false;
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      return business.name.toLowerCase().contains(query) ||
          business.address.toLowerCase().contains(query) ||
          business.city.toLowerCase().contains(query);
    }

    return true;
  }

  void _applyFilters() {
    _filteredBusinesses = _businesses.where(_shouldIncludeBusiness).toList();
  }

  Color _getMarkerColor(String businessType) {
    switch (businessType) {
      case 'gas_station':
        return AppTheme.lightTheme.colorScheme.secondary;
      case 'workshop':
        return AppTheme.lightTheme.colorScheme.primary;
      case 'restaurant':
        return AppTheme.successLight;
      case 'hotel':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'tourist_spot':
        return AppTheme.accentLight;
      default:
        return AppTheme.lightTheme.colorScheme.outline;
    }
  }

  String _getMarkerIcon(String businessType) {
    switch (businessType) {
      case 'gas_station':
        return 'local_gas_station';
      case 'workshop':
        return 'build';
      case 'restaurant':
        return 'restaurant';
      case 'hotel':
        return 'hotel';
      case 'tourist_spot':
        return 'place';
      default:
        return 'place';
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EnhancedMapFilterBottomSheet(
        businessTypeFilters: _businessTypeFilters,
        distanceRadius: _distanceRadius,
        minimumRating: _minimumRating,
        selectedPriceRange: _selectedPriceRange,
        onFiltersChanged: (filters, distance, rating, priceRange) {
          setState(() {
            _businessTypeFilters = filters;
            _distanceRadius = distance;
            _minimumRating = rating;
            _selectedPriceRange = priceRange;
            _applyFilters();
          });
        },
      ),
    );
  }

  void _onMarkerTapped(Business business) {
    setState(() {
      _selectedBusiness = business;
      _showBusinessPreview = true;
    });
  }

  Future<void> _centerOnUserLocation() async {
    setState(() {
      _isLocationLoading = true;
    });

    try {
      // Simulate location refresh (in production, use geolocator)
      await Future.delayed(const Duration(seconds: 1));

      // Update location and reload businesses
      await _loadBusinesses();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Localização atualizada!',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
            ),
          ),
          backgroundColor: AppTheme.lightTheme.colorScheme.primary,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao obter localização',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
            ),
          ),
          backgroundColor: AppTheme.errorLight,
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() {
        _isLocationLoading = false;
      });
    }
  }

  void _toggleMapType() {
    setState(() {
      switch (_selectedMapType) {
        case 'standard':
          _selectedMapType = 'satellite';
          break;
        case 'satellite':
          _selectedMapType = 'terrain';
          break;
        case 'terrain':
          _selectedMapType = 'standard';
          break;
      }
    });
  }

  void _toggleRoutePlanningMode() {
    setState(() {
      _isRoutePlanningMode = !_isRoutePlanningMode;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isRoutePlanningMode
              ? 'Modo de planejamento ativado. Toque longo para adicionar pontos.'
              : 'Modo de planejamento desativado.',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: _isRoutePlanningMode
            ? AppTheme.successLight
            : AppTheme.lightTheme.colorScheme.outline,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  Future<void> _refreshData() async {
    try {
      await _loadBusinesses();
      setState(() {
        _errorMessage = null;
      });
    } catch (error) {
      setState(() {
        _errorMessage = 'Erro ao atualizar dados';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Carregando mapa...',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'error_outline',
                  color: AppTheme.errorLight,
                  size: 15.w,
                ),
                SizedBox(height: 2.h),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.errorLight,
                  ),
                ),
                SizedBox(height: 3.h),
                ElevatedButton(
                  onPressed: _initializeMap,
                  child: const Text('Tentar Novamente'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: Stack(
            children: [
              // Map Container
              Container(
                width: 100.w,
                height: 100.h,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    // Simulated Map Background
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _selectedMapType == 'satellite'
                                ? const Color(0xFF2D5016)
                                : _selectedMapType == 'terrain'
                                    ? const Color(0xFF8B4513)
                                    : const Color(0xFFF0F8FF),
                            _selectedMapType == 'satellite'
                                ? const Color(0xFF4A7C59)
                                : _selectedMapType == 'terrain'
                                    ? const Color(0xFFDEB887)
                                    : const Color(0xFFE6F3FF),
                          ],
                        ),
                      ),
                      child: CustomPaint(
                        painter: _MapGridPainter(
                          mapType: _selectedMapType,
                          theme: AppTheme.lightTheme,
                        ),
                      ),
                    ),

                    // Business Markers
                    ..._filteredBusinesses.map((business) {
                      final index = _filteredBusinesses.indexOf(business);
                      return AnimatedBuilder(
                        animation: _markerAnimationController,
                        builder: (context, child) {
                          final animationValue = Curves.elasticOut.transform(
                            (_markerAnimationController.value - (index * 0.05))
                                .clamp(0.0, 1.0),
                          );

                          return Positioned(
                            left: ((business.longitude + 46.6333) * 50.w + 20.w)
                                .clamp(0.0, 95.w),
                            top: ((23.5505 - business.latitude) * 80.h + 10.h)
                                .clamp(0.0, 95.h),
                            child: Transform.scale(
                              scale: animationValue,
                              child: MapMarkerWidget(
                                business: business,
                                fuelPrices: _fuelPrices[business.id] ?? [],
                                color: _getMarkerColor(business.businessType),
                                icon: _getMarkerIcon(business.businessType),
                                onTap: () => _onMarkerTapped(business),
                                showFuelPrice:
                                    business.businessType == 'gas_station',
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),

                    // User Location Marker
                    if (_userLatitude != null && _userLongitude != null)
                      Positioned(
                        left: 50.w - 6.w,
                        top: 45.h - 6.w,
                        child: AnimatedBuilder(
                          animation: _locationAnimationController,
                          builder: (context, child) {
                            return Container(
                              width: 12.w,
                              height: 12.w,
                              decoration: BoxDecoration(
                                color: AppTheme.lightTheme.colorScheme.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme
                                        .lightTheme.colorScheme.primary
                                        .withValues(
                                            alpha: 0.3 *
                                                _locationAnimationController
                                                    .value),
                                    blurRadius:
                                        20 * _locationAnimationController.value,
                                    spreadRadius:
                                        5 * _locationAnimationController.value,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Container(
                                  width: 4.w,
                                  height: 4.w,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),

              // Search Bar
              Positioned(
                top: 2.h,
                left: 4.w,
                right: 4.w,
                child: EnhancedMapSearchBar(
                  onSearchChanged: _onSearchChanged,
                  mapService: _mapService,
                  onLocationSelected: (business) {
                    _onMarkerTapped(business);
                  },
                ),
              ),

              // Map Type Toggle
              Positioned(
                top: 12.h,
                right: 4.w,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _toggleMapType,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: EdgeInsets.all(3.w),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomIconWidget(
                              iconName: _selectedMapType == 'satellite'
                                  ? 'satellite_alt'
                                  : _selectedMapType == 'terrain'
                                      ? 'terrain'
                                      : 'map',
                              color: AppTheme.lightTheme.colorScheme.primary,
                              size: 6.w,
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              _selectedMapType == 'satellite'
                                  ? 'Satélite'
                                  : _selectedMapType == 'terrain'
                                      ? 'Terreno'
                                      : 'Padrão',
                              style: AppTheme.lightTheme.textTheme.labelSmall
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Route Planning Toggle
              Positioned(
                top: 22.h,
                right: 4.w,
                child: Container(
                  decoration: BoxDecoration(
                    color: _isRoutePlanningMode
                        ? AppTheme.successLight
                        : AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _toggleRoutePlanningMode,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: EdgeInsets.all(3.w),
                        child: CustomIconWidget(
                          iconName: 'route',
                          color: _isRoutePlanningMode
                              ? Colors.white
                              : AppTheme.lightTheme.colorScheme.primary,
                          size: 6.w,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Real-time Fuel Prices Widget
              Positioned(
                top: 32.h,
                right: 4.w,
                child: RealTimeFuelPriceWidget(
                  fuelPrices: _fuelPrices,
                  lastUpdate: DateTime.now(),
                ),
              ),

              // Filter FAB
              Positioned(
                bottom: 12.h,
                left: 4.w,
                child: FloatingActionButton(
                  onPressed: _showFilterBottomSheet,
                  backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                  child: CustomIconWidget(
                    iconName: 'tune',
                    color: Colors.white,
                    size: 6.w,
                  ),
                ),
              ),

              // Current Location FAB
              Positioned(
                bottom: 12.h,
                right: 4.w,
                child: FloatingActionButton(
                  onPressed: _isLocationLoading ? null : _centerOnUserLocation,
                  backgroundColor: AppTheme.lightTheme.colorScheme.surface,
                  child: _isLocationLoading
                      ? SizedBox(
                          width: 6.w,
                          height: 6.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.lightTheme.colorScheme.primary,
                            ),
                          ),
                        )
                      : CustomIconWidget(
                          iconName: 'my_location',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 6.w,
                        ),
                ),
              ),

              // Business Preview Card
              if (_showBusinessPreview && _selectedBusiness != null)
                Positioned(
                  bottom: 2.h,
                  left: 4.w,
                  right: 4.w,
                  child: EnhancedBusinessPreviewCard(
                    business: _selectedBusiness!,
                    fuelPrices: _fuelPrices[_selectedBusiness!.id] ?? [],
                    onClose: () {
                      setState(() {
                        _showBusinessPreview = false;
                        _selectedBusiness = null;
                      });
                    },
                    onNavigate: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Abrindo navegação para ${_selectedBusiness!.name}...',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor:
                              AppTheme.lightTheme.colorScheme.primary,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    onViewDetails: () {
                      // Navigate to business details screen
                      Navigator.pushNamed(
                        context,
                        '/business-details',
                        arguments: _selectedBusiness!.id,
                      );
                    },
                    onToggleFavorite: () async {
                      try {
                        final isFavorited = await _mapService
                            .toggleBusinessFavorite(_selectedBusiness!.id);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isFavorited
                                  ? 'Adicionado aos favoritos'
                                  : 'Removido dos favoritos',
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(color: Colors.white),
                            ),
                            backgroundColor: AppTheme.successLight,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      } catch (error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Erro ao atualizar favoritos',
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(color: Colors.white),
                            ),
                            backgroundColor: AppTheme.errorLight,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                ),

              // Results counter
              Positioned(
                bottom: _showBusinessPreview ? 22.h : 2.h,
                left: 4.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface
                        .withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '${_filteredBusinesses.length} estabelecimentos encontrados',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  final String mapType;
  final ThemeData theme;

  _MapGridPainter({required this.mapType, required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = mapType == 'standard'
          ? theme.colorScheme.outline.withValues(alpha: 0.1)
          : Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = 1;

    // Draw grid lines to simulate map
    for (int i = 0; i < 20; i++) {
      final x = (size.width / 20) * i;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    for (int i = 0; i < 20; i++) {
      final y = (size.height / 20) * i;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Draw some simulated roads
    final roadPaint = Paint()
      ..color = mapType == 'standard'
          ? Colors.grey[400]!
          : Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 3;

    // Horizontal roads
    canvas.drawLine(
      Offset(0, size.height * 0.3),
      Offset(size.width, size.height * 0.3),
      roadPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.7),
      Offset(size.width, size.height * 0.7),
      roadPaint,
    );

    // Vertical roads
    canvas.drawLine(
      Offset(size.width * 0.4, 0),
      Offset(size.width * 0.4, size.height),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.8, 0),
      Offset(size.width * 0.8, size.height),
      roadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
