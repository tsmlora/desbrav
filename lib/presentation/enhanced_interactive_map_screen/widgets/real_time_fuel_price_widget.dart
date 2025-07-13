import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../core/models/business.dart';

class RealTimeFuelPriceWidget extends StatefulWidget {
  final Map<String, List<FuelPrice>> fuelPrices;
  final DateTime lastUpdate;

  const RealTimeFuelPriceWidget({
    Key? key,
    required this.fuelPrices,
    required this.lastUpdate,
  }) : super(key: key);

  @override
  State<RealTimeFuelPriceWidget> createState() =>
      _RealTimeFuelPriceWidgetState();
}

class _RealTimeFuelPriceWidgetState extends State<RealTimeFuelPriceWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<FuelPrice> get _latestFuelPrices {
    final allPrices = <FuelPrice>[];
    for (final prices in widget.fuelPrices.values) {
      allPrices.addAll(prices);
    }

    // Group by fuel type and get the latest for each
    final Map<String, FuelPrice> latestByType = {};
    for (final price in allPrices) {
      if (!latestByType.containsKey(price.fuelType) ||
          price.updatedAt.isAfter(latestByType[price.fuelType]!.updatedAt)) {
        latestByType[price.fuelType] = price;
      }
    }

    return latestByType.values.toList()
      ..sort((a, b) => a.pricePerLiter.compareTo(b.pricePerLiter));
  }

  String get _lastUpdateText {
    final difference = DateTime.now().difference(widget.lastUpdate);
    if (difference.inMinutes < 1) {
      return 'Agora mesmo';
    } else if (difference.inMinutes < 60) {
      return 'Há ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Há ${difference.inHours}h';
    } else {
      return 'Há ${difference.inDays} dias';
    }
  }

  Color _getFuelTypeColor(String fuelType) {
    switch (fuelType) {
      case 'gasoline_common':
        return AppTheme.lightTheme.colorScheme.primary;
      case 'gasoline_premium':
        return AppTheme.accentLight;
      case 'ethanol':
        return AppTheme.successLight;
      case 'diesel':
        return AppTheme.lightTheme.colorScheme.secondary;
      default:
        return AppTheme.lightTheme.colorScheme.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final latestPrices = _latestFuelPrices;

    if (latestPrices.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: _isExpanded ? 60.w : 15.w,
        constraints: BoxConstraints(
          minHeight: 15.w,
          maxHeight: _isExpanded ? 40.h : 15.w,
        ),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: _isExpanded
            ? _buildExpandedView(latestPrices)
            : _buildCollapsedView(),
      ),
    );
  }

  Widget _buildCollapsedView() {
    return Container(
      padding: EdgeInsets.all(3.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: AppTheme.successLight,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'local_gas_station',
                      color: Colors.white,
                      size: 4.w,
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 1.h),
          Text(
            'LIVE',
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: AppTheme.successLight,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedView(List<FuelPrice> latestPrices) {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        color: AppTheme.successLight,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: CustomIconWidget(
                          iconName: 'local_gas_station',
                          color: Colors.white,
                          size: 4.w,
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Preços em Tempo Real',
                      style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Atualizado $_lastUpdateText',
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.successLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = false;
                  });
                },
                child: Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'close',
                      color: AppTheme.lightTheme.colorScheme.outline,
                      size: 4.w,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Fuel prices list
          Expanded(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: latestPrices.length,
              separatorBuilder: (context, index) => SizedBox(height: 1.5.h),
              itemBuilder: (context, index) {
                final fuelPrice = latestPrices[index];
                final color = _getFuelTypeColor(fuelPrice.fuelType);

                return Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: color.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Fuel type indicator
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            fuelPrice.fuelType == 'gasoline_common'
                                ? 'C'
                                : fuelPrice.fuelType == 'gasoline_premium'
                                    ? 'P'
                                    : fuelPrice.fuelType == 'ethanol'
                                        ? 'E'
                                        : 'D',
                            style: AppTheme.lightTheme.textTheme.labelMedium
                                ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 3.w),

                      // Fuel info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fuelPrice.fuelTypeDisplay,
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color:
                                    AppTheme.lightTheme.colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              fuelPrice.lastUpdated,
                              style: AppTheme.lightTheme.textTheme.labelSmall
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Price
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            fuelPrice.formattedPrice,
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              color: color,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (fuelPrice.isVerified)
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 1.5.w, vertical: 0.2.h),
                              decoration: BoxDecoration(
                                color: AppTheme.successLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Verificado',
                                style: AppTheme.lightTheme.textTheme.labelSmall
                                    ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 8.sp,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 2.h),

          // Footer info
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'info_outline',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 4.w,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'Preços reportados por usuários da região',
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
