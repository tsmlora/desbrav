import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MapFilterBottomSheet extends StatefulWidget {
  final Map<String, bool> businessTypeFilters;
  final double distanceRadius;
  final double minimumRating;
  final RangeValues priceRange;
  final Function(Map<String, bool>, double, double, RangeValues)
      onFiltersChanged;

  const MapFilterBottomSheet({
    Key? key,
    required this.businessTypeFilters,
    required this.distanceRadius,
    required this.minimumRating,
    required this.priceRange,
    required this.onFiltersChanged,
  }) : super(key: key);

  @override
  State<MapFilterBottomSheet> createState() => _MapFilterBottomSheetState();
}

class _MapFilterBottomSheetState extends State<MapFilterBottomSheet> {
  late Map<String, bool> _localBusinessTypeFilters;
  late double _localDistanceRadius;
  late double _localMinimumRating;
  late RangeValues _localPriceRange;

  final Map<String, Map<String, dynamic>> _businessTypeData = {
    'gas': {
      'title': 'Postos de Combustível',
      'icon': 'local_gas_station',
      'color': AppTheme.lightTheme.colorScheme.secondary,
    },
    'workshop': {
      'title': 'Oficinas',
      'icon': 'build',
      'color': AppTheme.lightTheme.colorScheme.primary,
    },
    'restaurant': {
      'title': 'Restaurantes',
      'icon': 'restaurant',
      'color': AppTheme.successLight,
    },
    'hotel': {
      'title': 'Hotéis e Pousadas',
      'icon': 'hotel',
      'color': AppTheme.lightTheme.colorScheme.tertiary,
    },
  };

  @override
  void initState() {
    super.initState();
    _localBusinessTypeFilters = Map.from(widget.businessTypeFilters);
    _localDistanceRadius = widget.distanceRadius;
    _localMinimumRating = widget.minimumRating;
    _localPriceRange = widget.priceRange;
  }

  void _applyFilters() {
    widget.onFiltersChanged(
      _localBusinessTypeFilters,
      _localDistanceRadius,
      _localMinimumRating,
      _localPriceRange,
    );
    Navigator.pop(context);
  }

  void _resetFilters() {
    setState(() {
      _localBusinessTypeFilters = {
        'gas': true,
        'workshop': true,
        'restaurant': true,
        'hotel': true,
      };
      _localDistanceRadius = 10.0;
      _localMinimumRating = 0.0;
      _localPriceRange = const RangeValues(0, 500);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 2.h),
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline.withValues(
                alpha: 0.3,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Filtros do Mapa',
                    style: AppTheme.lightTheme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton(
                  onPressed: _resetFilters,
                  child: Text(
                    'Limpar',
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Business Types Section
                  Text(
                    'Tipos de Estabelecimento',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),

                  ..._businessTypeData.entries.map((entry) {
                    final key = entry.key;
                    final data = entry.value;
                    final isSelected = _localBusinessTypeFilters[key] ?? false;

                    return Container(
                      margin: EdgeInsets.only(bottom: 1.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (data['color'] as Color).withValues(
                                alpha: 0.1,
                              )
                            : AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? data['color'] as Color
                              : AppTheme.lightTheme.colorScheme.outline
                                  .withValues(alpha: 0.2),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _localBusinessTypeFilters[key] = !isSelected;
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 2.h,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 12.w,
                                  height: 12.w,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? data['color'] as Color
                                        : AppTheme
                                            .lightTheme.colorScheme.outline
                                            .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: CustomIconWidget(
                                      iconName: data['icon'] as String,
                                      color: isSelected
                                          ? Colors.white
                                          : AppTheme.lightTheme.colorScheme
                                              .onSurfaceVariant,
                                      size: 6.w,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 3.w),
                                Expanded(
                                  child: Text(
                                    data['title'] as String,
                                    style: AppTheme
                                        .lightTheme.textTheme.bodyLarge
                                        ?.copyWith(
                                      fontWeight: isSelected
                                          ? FontWeight.w500
                                          : FontWeight.w400,
                                      color: isSelected
                                          ? data['color'] as Color
                                          : AppTheme
                                              .lightTheme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  CustomIconWidget(
                                    iconName: 'check_circle',
                                    color: data['color'] as Color,
                                    size: 6.w,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),

                  SizedBox(height: 3.h),

                  // Distance Section
                  Text(
                    'Raio de Distância',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),

                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _localDistanceRadius,
                          min: 1.0,
                          max: 50.0,
                          divisions: 49,
                          label: '${_localDistanceRadius.round()} km',
                          onChanged: (value) {
                            setState(() {
                              _localDistanceRadius = value;
                            });
                          },
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${_localDistanceRadius.round()} km',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 3.h),

                  // Rating Section
                  Text(
                    'Avaliação Mínima',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),

                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _localMinimumRating,
                          min: 0.0,
                          max: 5.0,
                          divisions: 10,
                          label: _localMinimumRating == 0.0
                              ? 'Qualquer'
                              : '${_localMinimumRating.toStringAsFixed(1)} ⭐',
                          onChanged: (value) {
                            setState(() {
                              _localMinimumRating = value;
                            });
                          },
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.successLight.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_localMinimumRating > 0.0) ...[
                              Text(
                                _localMinimumRating.toStringAsFixed(1),
                                style: AppTheme.lightTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                  color: AppTheme.successLight,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: 1.w),
                              CustomIconWidget(
                                iconName: 'star',
                                color: AppTheme.successLight,
                                size: 4.w,
                              ),
                            ] else
                              Text(
                                'Qualquer',
                                style: AppTheme.lightTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                  color: AppTheme.successLight,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 3.h),

                  // Price Range Section
                  Text(
                    'Faixa de Preço (R\$)',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),

                  RangeSlider(
                    values: _localPriceRange,
                    min: 0,
                    max: 500,
                    divisions: 50,
                    labels: RangeLabels(
                      'R\$ ${_localPriceRange.start.round()}',
                      'R\$ ${_localPriceRange.end.round()}',
                    ),
                    onChanged: (values) {
                      setState(() {
                        _localPriceRange = values;
                      });
                    },
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.tertiary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'R\$ ${_localPriceRange.start.round()}',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.tertiary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.tertiary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'R\$ ${_localPriceRange.end.round()}',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.tertiary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),

          // Apply Button
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.outline.withValues(
                    alpha: 0.2,
                  ),
                  width: 1,
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Aplicar Filtros',
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
