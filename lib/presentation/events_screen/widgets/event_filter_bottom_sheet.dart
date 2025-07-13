import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EventFilterBottomSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onApplyFilters;

  const EventFilterBottomSheet({Key? key, required this.onApplyFilters})
      : super(key: key);

  @override
  State<EventFilterBottomSheet> createState() => _EventFilterBottomSheetState();
}

class _EventFilterBottomSheetState extends State<EventFilterBottomSheet> {
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedEventType = 'all';
  double _distanceRadius = 50.0;
  String _selectedGroup = 'all';
  String _selectedDifficulty = 'all';
  bool _onlyFreeEvents = false;

  final List<Map<String, String>> _eventTypes = [
    {'value': 'all', 'label': 'Todos os tipos'},
    {'value': 'group_ride', 'label': 'Passeios em grupo'},
    {'value': 'meetup', 'label': 'Encontros'},
    {'value': 'rally', 'label': 'Rallys'},
    {'value': 'workshop', 'label': 'Workshops'},
  ];

  final List<Map<String, String>> _difficulties = [
    {'value': 'all', 'label': 'Todas as dificuldades'},
    {'value': 'Iniciante', 'label': 'Iniciante'},
    {'value': 'Intermediário', 'label': 'Intermediário'},
    {'value': 'Avançado', 'label': 'Avançado'},
  ];

  final List<Map<String, String>> _groups = [
    {'value': 'all', 'label': 'Todos os grupos'},
    {'value': 'moto_clube_sp', 'label': 'Moto Clube SP'},
    {'value': 'adventure_nordeste', 'label': 'Adventure Nordeste'},
    {'value': 'litoral_riders', 'label': 'Litoral Riders'},
  ];

  @override
  Widget build(BuildContext context) {
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
            margin: EdgeInsets.only(top: 1.h),
            width: 10.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Container(
            padding: EdgeInsets.all(4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filtros',
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton(
                  onPressed: _resetFilters,
                  child: Text(
                    'Limpar',
                    style: TextStyle(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: AppTheme.lightTheme.dividerColor),
          // Filter content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date range
                  _buildSectionTitle('Período'),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateSelector(
                          'Data inicial',
                          _startDate,
                          (date) => setState(() => _startDate = date),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: _buildDateSelector(
                          'Data final',
                          _endDate,
                          (date) => setState(() => _endDate = date),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),

                  // Event type
                  _buildSectionTitle('Tipo de evento'),
                  SizedBox(height: 1.h),
                  _buildDropdown(
                    _selectedEventType,
                    _eventTypes,
                    (value) => setState(() => _selectedEventType = value!),
                  ),
                  SizedBox(height: 3.h),

                  // Distance radius
                  _buildSectionTitle('Distância máxima'),
                  SizedBox(height: 1.h),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_distanceRadius.round()} km',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Slider(
                        value: _distanceRadius,
                        min: 5.0,
                        max: 1000.0,
                        divisions: 199,
                        onChanged: (value) =>
                            setState(() => _distanceRadius = value),
                        activeColor: AppTheme.lightTheme.colorScheme.primary,
                        inactiveColor: AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.3),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),

                  // Group affiliation
                  _buildSectionTitle('Grupo'),
                  SizedBox(height: 1.h),
                  _buildDropdown(
                    _selectedGroup,
                    _groups,
                    (value) => setState(() => _selectedGroup = value!),
                  ),
                  SizedBox(height: 3.h),

                  // Difficulty
                  _buildSectionTitle('Dificuldade'),
                  SizedBox(height: 1.h),
                  _buildDropdown(
                    _selectedDifficulty,
                    _difficulties,
                    (value) => setState(() => _selectedDifficulty = value!),
                  ),
                  SizedBox(height: 3.h),

                  // Free events only
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Apenas eventos gratuitos',
                        style: AppTheme.lightTheme.textTheme.titleMedium,
                      ),
                      Switch(
                        value: _onlyFreeEvents,
                        onChanged: (value) =>
                            setState(() => _onlyFreeEvents = value),
                        activeColor: AppTheme.lightTheme.colorScheme.primary,
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
          // Apply button
          Container(
            padding: EdgeInsets.all(4.w),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Aplicar Filtros',
                  style: TextStyle(
                    fontSize: 16.sp,
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildDateSelector(
    String label,
    DateTime? selectedDate,
    Function(DateTime) onDateSelected,
  ) {
    return GestureDetector(
      onTap: () => _selectDate(onDateSelected),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.lightTheme.dividerColor, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 0.5.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate != null
                      ? '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}'
                      : 'Selecionar',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: selectedDate != null
                        ? AppTheme.lightTheme.colorScheme.onSurface
                        : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
                CustomIconWidget(
                  iconName: 'calendar_today',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String selectedValue,
    List<Map<String, String>> options,
    Function(String?) onChanged,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.lightTheme.dividerColor, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          isExpanded: true,
          onChanged: onChanged,
          items: options.map((option) {
            return DropdownMenuItem<String>(
              value: option['value'],
              child: Text(
                option['label']!,
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
            );
          }).toList(),
          icon: CustomIconWidget(
            iconName: 'keyboard_arrow_down',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 24,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(Function(DateTime) onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return DatePickerTheme(
          data: DatePickerThemeData(
            backgroundColor: AppTheme.lightTheme.colorScheme.surface,
            headerBackgroundColor: AppTheme.lightTheme.colorScheme.primary,
            headerForegroundColor: Colors.white,
            dayForegroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.white;
              }
              return AppTheme.lightTheme.colorScheme.onSurface;
            }),
            dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppTheme.lightTheme.colorScheme.primary;
              }
              return Colors.transparent;
            }),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateSelected(picked);
    }
  }

  void _resetFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _selectedEventType = 'all';
      _distanceRadius = 50.0;
      _selectedGroup = 'all';
      _selectedDifficulty = 'all';
      _onlyFreeEvents = false;
    });
  }

  void _applyFilters() {
    final filters = {
      'startDate': _startDate,
      'endDate': _endDate,
      'eventType': _selectedEventType,
      'distanceRadius': _distanceRadius,
      'group': _selectedGroup,
      'difficulty': _selectedDifficulty,
      'onlyFreeEvents': _onlyFreeEvents,
    };

    widget.onApplyFilters(filters);
  }
}
