import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ExpandedStatsPanelWidget extends StatelessWidget {
  final double elevationGain;
  final int caloriesBurned;
  final double fuelConsumption;
  final VoidCallback onClose;

  const ExpandedStatsPanelWidget({
    super.key,
    required this.elevationGain,
    required this.caloriesBurned,
    required this.fuelConsumption,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
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
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Estatísticas Detalhadas',
                  style: AppTheme.lightTheme.textTheme.titleLarge,
                ),
                IconButton(
                  onPressed: onClose,
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                children: [
                  // Stats grid
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio: 1.5,
                      crossAxisSpacing: 4.w,
                      mainAxisSpacing: 2.h,
                      children: [
                        _buildStatCard(
                          'Elevação Ganha',
                          '${elevationGain.toStringAsFixed(0)} m',
                          'terrain',
                          AppTheme.successLight,
                        ),
                        _buildStatCard(
                          'Calorias',
                          '$caloriesBurned kcal',
                          'local_fire_department',
                          AppTheme.warningLight,
                        ),
                        _buildStatCard(
                          'Combustível',
                          '${fuelConsumption.toStringAsFixed(1)} L',
                          'local_gas_station',
                          AppTheme.secondaryLight,
                        ),
                        _buildStatCard(
                          'Eficiência',
                          '${(fuelConsumption * 100 / (elevationGain / 1000 + 1)).toStringAsFixed(1)} L/100km',
                          'eco',
                          AppTheme.primaryLight,
                        ),
                      ],
                    ),
                  ),

                  // Additional info
                  Container(
                    padding: EdgeInsets.all(4.w),
                    margin: EdgeInsets.only(bottom: 2.h),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryLight.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'info',
                              color: AppTheme.primaryLight,
                              size: 20,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'Informações Adicionais',
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(color: AppTheme.primaryLight),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          '• Cálculo de calorias baseado em peso médio de 70kg\n'
                          '• Consumo estimado para motocicleta 250cc\n'
                          '• Elevação calculada via GPS barométrico',
                          style: AppTheme.lightTheme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String iconName,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(iconName: iconName, color: color, size: 28),
          SizedBox(height: 1.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 10.sp,
              color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                alpha: 0.7,
              ),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
