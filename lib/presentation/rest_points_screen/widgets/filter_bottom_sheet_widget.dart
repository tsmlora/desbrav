import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FilterBottomSheetWidget extends StatefulWidget {
  final double minPrice;
  final double maxPrice;
  final bool needsParking;
  final bool needsChargingStation;
  final bool allowsGroups;
  final String selectedPriceRange;
  final Function(Map<String, dynamic>) onFiltersChanged;

  const FilterBottomSheetWidget({
    super.key,
    required this.minPrice,
    required this.maxPrice,
    required this.needsParking,
    required this.needsChargingStation,
    required this.allowsGroups,
    required this.selectedPriceRange,
    required this.onFiltersChanged,
  });

  @override
  State<FilterBottomSheetWidget> createState() =>
      _FilterBottomSheetWidgetState();
}

class _FilterBottomSheetWidgetState extends State<FilterBottomSheetWidget> {
  late double _minPrice;
  late double _maxPrice;
  late bool _needsParking;
  late bool _needsChargingStation;
  late bool _allowsGroups;
  late String _selectedPriceRange;

  @override
  void initState() {
    super.initState();
    _minPrice = widget.minPrice;
    _maxPrice = widget.maxPrice;
    _needsParking = widget.needsParking;
    _needsChargingStation = widget.needsChargingStation;
    _allowsGroups = widget.allowsGroups;
    _selectedPriceRange = widget.selectedPriceRange;
  }

  void _applyFilters() {
    widget.onFiltersChanged({
      'minPrice': _minPrice,
      'maxPrice': _maxPrice,
      'needsParking': _needsParking,
      'needsChargingStation': _needsChargingStation,
      'allowsGroups': _allowsGroups,
      'selectedPriceRange': _selectedPriceRange,
    });
    Navigator.pop(context);
  }

  void _resetFilters() {
    setState(() {
      _minPrice = 50.0;
      _maxPrice = 500.0;
      _needsParking = false;
      _needsChargingStation = false;
      _allowsGroups = false;
      _selectedPriceRange = 'all';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75.h,
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
          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filtros',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: _resetFilters,
                      child: Text(
                        'Limpar',
                        style: TextStyle(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: CustomIconWidget(
                        iconName: 'close',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(color: AppTheme.lightTheme.dividerColor),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price range section
                  _buildSectionTitle('Faixa de Preço'),
                  SizedBox(height: 1.h),
                  _buildPriceRangeSelection(),
                  SizedBox(height: 2.h),
                  _buildCustomPriceRange(),
                  SizedBox(height: 3.h),

                  // Motorcycle-specific amenities
                  _buildSectionTitle('Comodidades para Motociclistas'),
                  SizedBox(height: 1.h),
                  _buildMotorcycleAmenities(),
                  SizedBox(height: 3.h),

                  // Group accommodation
                  _buildSectionTitle('Acomodação'),
                  SizedBox(height: 1.h),
                  _buildAccommodationOptions(),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
          // Apply button
          Container(
            padding: EdgeInsets.all(4.w),
            child: ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 6.h),
              ),
              child: Text('Aplicar Filtros'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildPriceRangeSelection() {
    final priceRanges = [
      {
        'key': 'all',
        'label': 'Todos os preços',
        'color': AppTheme.lightTheme.colorScheme.primary
      },
      {
        'key': 'budget',
        'label': 'Econômico (R\$ 30-100)',
        'color': AppTheme.successLight
      },
      {
        'key': 'mid',
        'label': 'Médio (R\$ 100-250)',
        'color': AppTheme.warningLight
      },
      {
        'key': 'premium',
        'label': 'Premium (R\$ 250+)',
        'color': AppTheme.errorLight
      },
    ];

    return Column(
      children: priceRanges.map((range) {
        final isSelected = _selectedPriceRange == range['key'];
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedPriceRange = range['key'] as String;
            });
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 1.h),
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: isSelected
                  ? (range['color'] as Color).withValues(alpha: 0.1)
                  : AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isSelected ? (range['color'] as Color) : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 4.w,
                  height: 4.w,
                  decoration: BoxDecoration(
                    color: range['color'] as Color,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    range['label'] as String,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected
                          ? (range['color'] as Color)
                          : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                if (isSelected)
                  CustomIconWidget(
                    iconName: 'check_circle',
                    color: range['color'] as Color,
                    size: 20,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCustomPriceRange() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Faixa personalizada',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Text(
                'R\$ ${_minPrice.toStringAsFixed(0)}',
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: AppTheme.primaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Expanded(
                child: RangeSlider(
                  values: RangeValues(_minPrice, _maxPrice),
                  min: 30.0,
                  max: 1000.0,
                  divisions: 50,
                  activeColor: AppTheme.primaryLight,
                  onChanged: (RangeValues values) {
                    setState(() {
                      _minPrice = values.start;
                      _maxPrice = values.end;
                      _selectedPriceRange = 'custom';
                    });
                  },
                ),
              ),
              Text(
                'R\$ ${_maxPrice.toStringAsFixed(0)}',
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: AppTheme.primaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMotorcycleAmenities() {
    final amenities = [
      {
        'key': 'parking',
        'label': 'Garagem/Estacionamento Seguro',
        'icon': 'local_parking',
        'value': _needsParking,
        'onChanged': (bool value) => setState(() => _needsParking = value),
      },
      {
        'key': 'charging',
        'label': 'Estação de Carregamento Elétrico',
        'icon': 'electric_bolt',
        'value': _needsChargingStation,
        'onChanged': (bool value) =>
            setState(() => _needsChargingStation = value),
      },
    ];

    return Column(
      children: amenities.map((amenity) {
        return Container(
          margin: EdgeInsets.only(bottom: 1.h),
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: (amenity['value'] as bool)
                      ? AppTheme.primaryLight.withValues(alpha: 0.1)
                      : AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: amenity['icon'] as String,
                  color: (amenity['value'] as bool)
                      ? AppTheme.primaryLight
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  amenity['label'] as String,
                  style: AppTheme.lightTheme.textTheme.bodyMedium,
                ),
              ),
              Switch(
                value: amenity['value'] as bool,
                onChanged: amenity['onChanged'] as Function(bool),
                activeColor: AppTheme.primaryLight,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAccommodationOptions() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: _allowsGroups
                  ? AppTheme.primaryLight.withValues(alpha: 0.1)
                  : AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: 'groups',
              color: _allowsGroups
                  ? AppTheme.primaryLight
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aceita Grupos',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Acomodações para múltiplos motociclistas',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _allowsGroups,
            onChanged: (bool value) => setState(() => _allowsGroups = value),
            activeColor: AppTheme.primaryLight,
          ),
        ],
      ),
    );
  }
}
