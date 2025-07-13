import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MonthYearPickerWidget extends StatefulWidget {
  final String selectedMonth;
  final String selectedYear;
  final Function(String, String) onDateSelected;

  const MonthYearPickerWidget({
    Key? key,
    required this.selectedMonth,
    required this.selectedYear,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  State<MonthYearPickerWidget> createState() => _MonthYearPickerWidgetState();
}

class _MonthYearPickerWidgetState extends State<MonthYearPickerWidget> {
  late String _selectedMonth;
  late String _selectedYear;

  final List<String> _months = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  final List<String> _years = ['2025', '2024', '2023', '2022', '2021', '2020'];

  @override
  void initState() {
    super.initState();
    _selectedMonth = widget.selectedMonth;
    _selectedYear = widget.selectedYear;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60.h,
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
                  'Selecionar Período',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
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

          // Content
          Expanded(
            child: Row(
              children: [
                // Months column
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(4.w),
                        child: Text(
                          'Mês',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.lightTheme.colorScheme.primary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _months.length,
                          itemBuilder: (context, index) {
                            final month = _months[index];
                            final isSelected = month == _selectedMonth;

                            return InkWell(
                              onTap: () {
                                setState(() => _selectedMonth = month);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4.w,
                                  vertical: 2.h,
                                ),
                                margin: EdgeInsets.symmetric(
                                  horizontal: 2.w,
                                  vertical: 0.5.h,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.lightTheme.colorScheme.primary
                                          .withValues(alpha: 0.1)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        month,
                                        style: AppTheme
                                            .lightTheme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: isSelected
                                              ? AppTheme.lightTheme.colorScheme
                                                  .primary
                                              : AppTheme.lightTheme.colorScheme
                                                  .onSurface,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      CustomIconWidget(
                                        iconName: 'check',
                                        color: AppTheme
                                            .lightTheme.colorScheme.primary,
                                        size: 20,
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Divider
                Container(
                  width: 1,
                  color: AppTheme.lightTheme.colorScheme.outline.withValues(
                    alpha: 0.2,
                  ),
                ),

                // Years column
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(4.w),
                        child: Text(
                          'Ano',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.lightTheme.colorScheme.primary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _years.length,
                          itemBuilder: (context, index) {
                            final year = _years[index];
                            final isSelected = year == _selectedYear;

                            return InkWell(
                              onTap: () {
                                setState(() => _selectedYear = year);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4.w,
                                  vertical: 2.h,
                                ),
                                margin: EdgeInsets.symmetric(
                                  horizontal: 2.w,
                                  vertical: 0.5.h,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.lightTheme.colorScheme.primary
                                          .withValues(alpha: 0.1)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        year,
                                        style: AppTheme
                                            .lightTheme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: isSelected
                                              ? AppTheme.lightTheme.colorScheme
                                                  .primary
                                              : AppTheme.lightTheme.colorScheme
                                                  .onSurface,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      CustomIconWidget(
                                        iconName: 'check',
                                        color: AppTheme
                                            .lightTheme.colorScheme.primary,
                                        size: 20,
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
                onPressed: () {
                  widget.onDateSelected(_selectedMonth, _selectedYear);
                },
                child: const Text('Aplicar'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
