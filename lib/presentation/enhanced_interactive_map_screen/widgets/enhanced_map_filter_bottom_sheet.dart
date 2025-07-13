import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EnhancedMapFilterBottomSheet extends StatefulWidget {
  final Map<String, bool> businessTypeFilters;
  final double distanceRadius;
  final double minimumRating;
  final String? selectedPriceRange;
  final Function(Map<String, bool>, double, double, String?) onFiltersChanged;

  const EnhancedMapFilterBottomSheet({
    Key? key,
    required this.businessTypeFilters,
    required this.distanceRadius,
    required this.minimumRating,
    this.selectedPriceRange,
    required this.onFiltersChanged,
  }) : super(key: key);

  @override
  State<EnhancedMapFilterBottomSheet> createState() =>
      _EnhancedMapFilterBottomSheetState();
}

class _EnhancedMapFilterBottomSheetState
    extends State<EnhancedMapFilterBottomSheet> {
  late Map<String, bool> _businessTypeFilters;
  late double _distanceRadius;
  late double _minimumRating;
  String? _selectedPriceRange;

  final List<Map<String, dynamic>> _businessTypes = [
    {
      'key': 'gas_station',
      'name': 'Postos de Combustível',
      'icon': 'local_gas_station',
      'color': AppTheme.lightTheme.colorScheme.secondary,
    },
    {
      'key': 'workshop',
      'name': 'Oficinas',
      'icon': 'build',
      'color': AppTheme.lightTheme.colorScheme.primary,
    },
    {
      'key': 'restaurant',
      'name': 'Restaurantes',
      'icon': 'restaurant',
      'color': AppTheme.successLight,
    },
    {
      'key': 'hotel',
      'name': 'Hotéis/Pousadas',
      'icon': 'hotel',
      'color': AppTheme.lightTheme.colorScheme.tertiary,
    },
    {
      'key': 'tourist_spot',
      'name': 'Pontos Turísticos',
      'icon': 'place',
      'color': AppTheme.accentLight,
    },
  ];

  final List<Map<String, String>> _priceRanges = [
    {'key': 'budget', 'name': 'Econômico', 'description': 'Até R\$ 50'},
    {'key': 'moderate', 'name': 'Moderado', 'description': 'R\$ 50 - R\$ 150'},
    {'key': 'expensive', 'name': 'Caro', 'description': 'R\$ 150 - R\$ 300'},
    {'key': 'luxury', 'name': 'Luxo', 'description': 'Acima de R\$ 300'},
  ];

  @override
  void initState() {
    super.initState();
    _businessTypeFilters = Map.from(widget.businessTypeFilters);
    _distanceRadius = widget.distanceRadius;
    _minimumRating = widget.minimumRating;
    _selectedPriceRange = widget.selectedPriceRange;
  }

  void _applyFilters() {
    widget.onFiltersChanged(
      _businessTypeFilters,
      _distanceRadius,
      _minimumRating,
      _selectedPriceRange,
    );
    Navigator.pop(context);
  }

  void _resetFilters() {
    setState(() {
      _businessTypeFilters = {
        'gas_station': true,
        'workshop': true,
        'restaurant': true,
        'hotel': true,
        'tourist_spot': false,
      };
      _distanceRadius = 25.0;
      _minimumRating = 0.0;
      _selectedPriceRange = null;
    });
  }

  int get _activeFiltersCount {
    int count = 0;
    if (_businessTypeFilters.values.where((v) => v).length <
        _businessTypeFilters.length) count++;
    if (_distanceRadius != 25.0) count++;
    if (_minimumRating > 0) count++;
    if (_selectedPriceRange != null) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Handle
              Container(
                width: 12.w,
                height: 0.5.h,
                margin: EdgeInsets.only(top: 1.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppTheme.lightTheme.dividerColor,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'tune',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 6.w,
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      'Filtros do Mapa',
                      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (_activeFiltersCount > 0)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$_activeFiltersCount',
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.all(4.w),
                  children: [
                    // Business Types Section
                    _buildSectionHeader(
                      'Tipos de Estabelecimento',
                      'search',
                      'Selecione os tipos que deseja ver no mapa',
                    ),
                    SizedBox(height: 2.h),
                    ..._businessTypes
                        .map((type) => _buildBusinessTypeFilter(type)),

                    SizedBox(height: 3.h),

                    // Distance Section
                    _buildSectionHeader(
                      'Distância Máxima',
                      'my_location',
                      '${_distanceRadius.round()} km do sua localização',
                    ),
                    SizedBox(height: 2.h),
                    _buildDistanceSlider(),

                    SizedBox(height: 3.h),

                    // Rating Section
                    _buildSectionHeader(
                      'Avaliação Mínima',
                      'star',
                      _minimumRating > 0
                          ? '${_minimumRating.toStringAsFixed(1)} estrelas ou mais'
                          : 'Todas as avaliações',
                    ),
                    SizedBox(height: 2.h),
                    _buildRatingSlider(),

                    SizedBox(height: 3.h),

                    // Price Range Section
                    _buildSectionHeader(
                      'Faixa de Preço',
                      'attach_money',
                      _selectedPriceRange != null
                          ? _priceRanges.firstWhere(
                              (p) => p['key'] == _selectedPriceRange)['name']!
                          : 'Todas as faixas',
                    ),
                    SizedBox(height: 2.h),
                    ..._priceRanges
                        .map((range) => _buildPriceRangeOption(range)),

                    SizedBox(height: 4.h),
                  ],
                ),
              ),

              // Action buttons
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: AppTheme.lightTheme.dividerColor,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _resetFilters,
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 1.5.h),
                          side: BorderSide(
                            color: AppTheme.lightTheme.colorScheme.outline,
                          ),
                        ),
                        child: Text(
                          'Limpar Filtros',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.outline,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _applyFilters,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 1.5.h),
                          backgroundColor:
                              AppTheme.lightTheme.colorScheme.primary,
                        ),
                        child: Text(
                          'Aplicar Filtros',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, String icon, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(
            color:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: icon,
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 5.w,
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                subtitle,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessTypeFilter(Map<String, dynamic> type) {
    final isSelected = _businessTypeFilters[type['key']] ?? false;

    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _businessTypeFilters[type['key']] = !isSelected;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: isSelected
                  ? type['color'].withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? type['color']
                    : AppTheme.lightTheme.dividerColor,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? type['color']
                        : AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: type['icon'],
                      color: isSelected
                          ? Colors.white
                          : AppTheme.lightTheme.colorScheme.outline,
                      size: 5.w,
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    type['name'],
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? type['color']
                          : AppTheme.lightTheme.colorScheme.onSurface,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                if (isSelected)
                  CustomIconWidget(
                    iconName: 'check_circle',
                    color: type['color'],
                    size: 5.w,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDistanceSlider() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '5 km',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.outline,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${_distanceRadius.round()} km',
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '100 km',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.outline,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppTheme.lightTheme.colorScheme.primary,
              inactiveTrackColor: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.2),
              thumbColor: AppTheme.lightTheme.colorScheme.primary,
              overlayColor: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.1),
              trackHeight: 4,
            ),
            child: Slider(
              value: _distanceRadius,
              min: 5,
              max: 100,
              divisions: 19,
              onChanged: (value) {
                setState(() {
                  _distanceRadius = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSlider() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Qualquer',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.outline,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: AppTheme.successLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'star',
                      color: AppTheme.successLight,
                      size: 3.w,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      _minimumRating > 0
                          ? _minimumRating.toStringAsFixed(1)
                          : '0.0',
                      style:
                          AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                        color: AppTheme.successLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '5.0',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.outline,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppTheme.successLight,
              inactiveTrackColor: AppTheme.successLight.withValues(alpha: 0.2),
              thumbColor: AppTheme.successLight,
              overlayColor: AppTheme.successLight.withValues(alpha: 0.1),
              trackHeight: 4,
            ),
            child: Slider(
              value: _minimumRating,
              min: 0,
              max: 5,
              divisions: 10,
              onChanged: (value) {
                setState(() {
                  _minimumRating = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRangeOption(Map<String, String> range) {
    final isSelected = _selectedPriceRange == range['key'];

    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedPriceRange = isSelected ? null : range['key'];
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.dividerColor,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'attach_money',
                      color: isSelected
                          ? Colors.white
                          : AppTheme.lightTheme.colorScheme.outline,
                      size: 5.w,
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        range['name']!,
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? AppTheme.lightTheme.colorScheme.primary
                              : AppTheme.lightTheme.colorScheme.onSurface,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      Text(
                        range['description']!,
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  CustomIconWidget(
                    iconName: 'check_circle',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 5.w,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
