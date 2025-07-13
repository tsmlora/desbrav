import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/business_preview_card.dart';
import './widgets/map_filter_bottom_sheet.dart';
import './widgets/map_search_bar.dart';

class InteractiveMapScreen extends StatefulWidget {
  const InteractiveMapScreen({Key? key}) : super(key: key);

  @override
  State<InteractiveMapScreen> createState() => _InteractiveMapScreenState();
}

class _InteractiveMapScreenState extends State<InteractiveMapScreen>
    with TickerProviderStateMixin {
  late AnimationController _filterAnimationController;
  late AnimationController _markerAnimationController;

  String _selectedMapType = 'standard';
  bool _isRoutePlanningMode = false;
  bool _showBusinessPreview = false;
  Map<String, dynamic>? _selectedBusiness;

  // Filter states
  Map<String, bool> _businessTypeFilters = {
    'gas': true,
    'workshop': true,
    'restaurant': true,
    'hotel': true,
  };
  double _distanceRadius = 10.0;
  double _minimumRating = 0.0;
  RangeValues _priceRange = const RangeValues(0, 500);

  // Mock data for map markers
  final List<Map<String, dynamic>> _mapMarkers = [
    {
      "id": "gas_001",
      "type": "gas",
      "name": "Posto Shell Centro",
      "latitude": -23.5505,
      "longitude": -46.6333,
      "rating": 4.2,
      "distance": 0.8,
      "price": "R\$ 5,89",
      "address": "Av. Paulista, 1000 - Bela Vista, São Paulo",
      "phone": "(11) 3456-7890",
      "hours": "24h",
      "amenities": ["Conveniência", "Banheiro", "Wi-Fi"],
      "lastUpdate": "Há 2 horas",
      "image":
          "https://images.pexels.com/photos/33688/delicate-arch-night-stars-landscape.jpg?auto=compress&cs=tinysrgb&w=800"
    },
    {
      "id": "workshop_001",
      "type": "workshop",
      "name": "Oficina Moto Expert",
      "latitude": -23.5489,
      "longitude": -46.6388,
      "rating": 4.7,
      "distance": 1.2,
      "price": "R\$ 80-150",
      "address": "Rua Augusta, 500 - Consolação, São Paulo",
      "phone": "(11) 2345-6789",
      "hours": "08:00 - 18:00",
      "amenities": ["Revisão", "Pneus", "Elétrica"],
      "lastUpdate": "Há 1 hora",
      "image":
          "https://images.pexels.com/photos/190537/pexels-photo-190537.jpeg?auto=compress&cs=tinysrgb&w=800"
    },
    {
      "id": "restaurant_001",
      "type": "restaurant",
      "name": "Restaurante do Motoqueiro",
      "latitude": -23.5520,
      "longitude": -46.6311,
      "rating": 4.5,
      "distance": 0.5,
      "price": "R\$ 25-45",
      "address": "Rua da Consolação, 200 - Centro, São Paulo",
      "phone": "(11) 1234-5678",
      "hours": "11:00 - 22:00",
      "amenities": ["Estacionamento", "Marmitex", "Delivery"],
      "lastUpdate": "Há 30 min",
      "image":
          "https://images.pexels.com/photos/262978/pexels-photo-262978.jpeg?auto=compress&cs=tinysrgb&w=800"
    },
    {
      "id": "hotel_001",
      "type": "hotel",
      "name": "Pousada Rota das Motos",
      "latitude": -23.5467,
      "longitude": -46.6407,
      "rating": 4.3,
      "distance": 2.1,
      "price": "R\$ 120-200",
      "address": "Rua Haddock Lobo, 300 - Cerqueira César, São Paulo",
      "phone": "(11) 9876-5432",
      "hours": "24h",
      "amenities": ["Garagem", "Wi-Fi", "Café da manhã"],
      "lastUpdate": "Há 15 min",
      "image":
          "https://images.pexels.com/photos/271624/pexels-photo-271624.jpeg?auto=compress&cs=tinysrgb&w=800"
    },
    {
      "id": "gas_002",
      "type": "gas",
      "name": "Petrobras Ipiranga",
      "latitude": -23.5578,
      "longitude": -46.6592,
      "rating": 3.9,
      "distance": 3.2,
      "price": "R\$ 5,95",
      "address": "Av. Faria Lima, 1500 - Itaim Bibi, São Paulo",
      "phone": "(11) 5555-1234",
      "hours": "06:00 - 22:00",
      "amenities": ["Conveniência", "Lavagem", "Calibragem"],
      "lastUpdate": "Há 4 horas",
      "image":
          "https://images.pexels.com/photos/164634/pexels-photo-164634.jpeg?auto=compress&cs=tinysrgb&w=800"
    }
  ];

  @override
  void initState() {
    super.initState();
    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _markerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _markerAnimationController.forward();
  }

  @override
  void dispose() {
    _filterAnimationController.dispose();
    _markerAnimationController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredMarkers {
    return _mapMarkers.where((marker) {
      final type = marker['type'] as String;
      final rating = marker['rating'] as double;
      final distance = marker['distance'] as double;

      if (!_businessTypeFilters[type]!) return false;
      if (rating < _minimumRating) return false;
      if (distance > _distanceRadius) return false;

      return true;
    }).toList();
  }

  Color _getMarkerColor(String type) {
    switch (type) {
      case 'gas':
        return AppTheme.lightTheme.colorScheme.secondary;
      case 'workshop':
        return AppTheme.lightTheme.colorScheme.primary;
      case 'restaurant':
        return AppTheme.successLight;
      case 'hotel':
        return AppTheme.lightTheme.colorScheme.tertiary;
      default:
        return AppTheme.lightTheme.colorScheme.outline;
    }
  }

  String _getMarkerIcon(String type) {
    switch (type) {
      case 'gas':
        return 'local_gas_station';
      case 'workshop':
        return 'build';
      case 'restaurant':
        return 'restaurant';
      case 'hotel':
        return 'hotel';
      default:
        return 'place';
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MapFilterBottomSheet(
        businessTypeFilters: _businessTypeFilters,
        distanceRadius: _distanceRadius,
        minimumRating: _minimumRating,
        priceRange: _priceRange,
        onFiltersChanged: (filters, distance, rating, price) {
          setState(() {
            _businessTypeFilters = filters;
            _distanceRadius = distance;
            _minimumRating = rating;
            _priceRange = price;
          });
        },
      ),
    );
  }

  void _onMarkerTapped(Map<String, dynamic> business) {
    setState(() {
      _selectedBusiness = business;
      _showBusinessPreview = true;
    });
  }

  void _centerOnUserLocation() {
    // Simulate centering on user location
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Centralizando no sua localização...',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        duration: const Duration(seconds: 2),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
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

                  // Map Markers
                  ..._filteredMarkers.map((marker) {
                    final index = _filteredMarkers.indexOf(marker);
                    return AnimatedBuilder(
                      animation: _markerAnimationController,
                      builder: (context, child) {
                        final animationValue = Curves.elasticOut.transform(
                          (_markerAnimationController.value - (index * 0.1))
                              .clamp(0.0, 1.0),
                        );

                        return Positioned(
                          left: ((marker['longitude'] as double) + 46.6333) *
                                  50.w +
                              20.w,
                          top: (23.5505 - marker['latitude']) * 80.h + 10.h,
                          child: Transform.scale(
                            scale: animationValue,
                            child: GestureDetector(
                              onTap: () => _onMarkerTapped(marker),
                              child: Container(
                                width: 12.w,
                                height: 12.w,
                                decoration: BoxDecoration(
                                  color:
                                      _getMarkerColor(marker['type'] as String),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: CustomIconWidget(
                                    iconName: _getMarkerIcon(
                                        marker['type'] as String),
                                    color: Colors.white,
                                    size: 6.w,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),

                  // User Location Marker
                  Positioned(
                    left: 50.w - 6.w,
                    top: 45.h - 6.w,
                    child: Container(
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
                            color: AppTheme.lightTheme.colorScheme.primary
                                .withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
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
              child: MapSearchBar(
                onSearchChanged: (query) {
                  // Handle search functionality
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
                onPressed: _centerOnUserLocation,
                backgroundColor: AppTheme.lightTheme.colorScheme.surface,
                child: CustomIconWidget(
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
                child: BusinessPreviewCard(
                  business: _selectedBusiness!,
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
                          'Abrindo navegação para ${_selectedBusiness!['name']}...',
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
                    Navigator.pushNamed(context, '/business-details');
                  },
                ),
              ),
          ],
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
