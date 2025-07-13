import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FilterBottomSheetWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onApplyFilters;

  const FilterBottomSheetWidget({Key? key, required this.onApplyFilters})
      : super(key: key);

  @override
  State<FilterBottomSheetWidget> createState() =>
      _FilterBottomSheetWidgetState();
}

class _FilterBottomSheetWidgetState extends State<FilterBottomSheetWidget> {
  RangeValues _distanceRange = const RangeValues(0, 500);
  RangeValues _durationRange = const RangeValues(0, 8);
  String? _selectedMotorcycle;
  List<String> _selectedAchievements = [];

  final List<String> _motorcycles = [
    'Honda CB 600F Hornet',
    'Yamaha MT-07',
    'BMW F 850 GS',
    'Kawasaki Versys 650',
    'Triumph Tiger 800',
  ];

  final List<String> _achievements = [
    'Explorador',
    'Velocista',
    'Montanhista',
    'Costeiro',
    'Aventureiro',
    'Resistência',
    'Histórico',
    'Peregrino',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 12.w,
            height: 0.5.h,
            margin: EdgeInsets.only(top: 2.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                alpha: 0.3,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                Text(
                  'Filtros',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _resetFilters,
                  child: Text(
                    'Limpar',
                    style: TextStyle(
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(
            color: AppTheme.lightTheme.colorScheme.outline.withValues(
              alpha: 0.2,
            ),
            height: 1,
          ),

          // Filter content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Distance range
                  _buildSectionTitle('Distância (km)'),
                  SizedBox(height: 2.h),
                  _buildRangeSlider(
                    'Distância',
                    _distanceRange,
                    0,
                    500,
                    (values) => setState(() => _distanceRange = values),
                    (value) => '${value.round()} km',
                  ),

                  SizedBox(height: 4.h),

                  // Duration range
                  _buildSectionTitle('Duração (horas)'),
                  SizedBox(height: 2.h),
                  _buildRangeSlider(
                    'Duração',
                    _durationRange,
                    0,
                    8,
                    (values) => setState(() => _durationRange = values),
                    (value) => '${value.round()}h',
                  ),

                  SizedBox(height: 4.h),

                  // Motorcycle selection
                  _buildSectionTitle('Motocicleta'),
                  SizedBox(height: 2.h),
                  _buildMotorcycleSelection(),

                  SizedBox(height: 4.h),

                  // Achievement selection
                  _buildSectionTitle('Conquistas'),
                  SizedBox(height: 2.h),
                  _buildAchievementSelection(),

                  SizedBox(height: 6.h),
                ],
              ),
            ),
          ),

          // Apply button
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.outline.withValues(
                    alpha: 0.2,
                  ),
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilters,
                child: const Text('Aplicar Filtros'),
              ),
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
        color: AppTheme.lightTheme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildRangeSlider(
    String label,
    RangeValues values,
    double min,
    double max,
    Function(RangeValues) onChanged,
    String Function(double) formatter,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              formatter(values.start),
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
            Text(
              formatter(values.end),
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
          ],
        ),
        RangeSlider(
          values: values,
          min: min,
          max: max,
          divisions: (max - min).round(),
          activeColor: AppTheme.lightTheme.colorScheme.primary,
          inactiveColor: AppTheme.lightTheme.colorScheme.primary.withValues(
            alpha: 0.3,
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildMotorcycleSelection() {
    return Column(
      children: _motorcycles.map((motorcycle) {
        final isSelected = _selectedMotorcycle == motorcycle;
        return Container(
          margin: EdgeInsets.only(bottom: 1.h),
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedMotorcycle = isSelected ? null : motorcycle;
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'motorcycle',
                    color: isSelected
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                    size: 20,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      motorcycle,
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                  if (isSelected)
                    CustomIconWidget(
                      iconName: 'check_circle',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAchievementSelection() {
    return Wrap(
      spacing: 2.w,
      runSpacing: 1.h,
      children: _achievements.map((achievement) {
        final isSelected = _selectedAchievements.contains(achievement);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedAchievements.remove(achievement);
              } else {
                _selectedAchievements.add(achievement);
              }
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.lightTheme.colorScheme.primary
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'emoji_events',
                  color: isSelected
                      ? Colors.white
                      : AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                  size: 16,
                ),
                SizedBox(width: 2.w),
                Text(
                  achievement,
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: isSelected
                        ? Colors.white
                        : AppTheme.lightTheme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _resetFilters() {
    setState(() {
      _distanceRange = const RangeValues(0, 500);
      _durationRange = const RangeValues(0, 8);
      _selectedMotorcycle = null;
      _selectedAchievements.clear();
    });
  }

  void _applyFilters() {
    final filters = {
      'distanceRange': _distanceRange,
      'durationRange': _durationRange,
      'motorcycle': _selectedMotorcycle,
      'achievements': _selectedAchievements,
    };
    widget.onApplyFilters(filters);
  }
}
