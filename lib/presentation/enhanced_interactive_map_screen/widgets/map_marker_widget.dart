import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../core/models/business.dart';

class MapMarkerWidget extends StatefulWidget {
  final Business business;
  final List<FuelPrice> fuelPrices;
  final Color color;
  final String icon;
  final VoidCallback onTap;
  final bool showFuelPrice;

  const MapMarkerWidget({
    Key? key,
    required this.business,
    required this.fuelPrices,
    required this.color,
    required this.icon,
    required this.onTap,
    this.showFuelPrice = false,
  }) : super(key: key);

  @override
  State<MapMarkerWidget> createState() => _MapMarkerWidgetState();
}

class _MapMarkerWidgetState extends State<MapMarkerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Start animation if business is featured or has recent fuel updates
    if (widget.business.isFeatured || _hasRecentFuelUpdate) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool get _hasRecentFuelUpdate {
    if (!widget.showFuelPrice || widget.fuelPrices.isEmpty) return false;

    final latestUpdate = widget.fuelPrices
        .map((fp) => fp.updatedAt)
        .reduce((a, b) => a.isAfter(b) ? a : b);

    return DateTime.now().difference(latestUpdate).inHours < 2;
  }

  FuelPrice? get _cheapestFuel {
    if (widget.fuelPrices.isEmpty) return null;
    return widget.fuelPrices
        .reduce((a, b) => a.pricePerLiter < b.pricePerLiter ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) {
        setState(() {
          _isHovered = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isHovered = false;
        });
      },
      onTapCancel: () {
        setState(() {
          _isHovered = false;
        });
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          final shouldAnimate =
              widget.business.isFeatured || _hasRecentFuelUpdate;

          return Transform.scale(
            scale: _isHovered
                ? 1.2
                : (shouldAnimate ? _scaleAnimation.value : 1.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Fuel price tooltip
                if (widget.showFuelPrice && _cheapestFuel != null)
                  AnimatedOpacity(
                    opacity: _isHovered ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      margin: EdgeInsets.only(bottom: 1.h),
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.business.name,
                            style: AppTheme.lightTheme.textTheme.labelSmall
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _cheapestFuel!.formattedPrice,
                            style: AppTheme.lightTheme.textTheme.labelMedium
                                ?.copyWith(
                              color: widget.color,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (_hasRecentFuelUpdate)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 1.5.w,
                                  height: 1.5.w,
                                  decoration: BoxDecoration(
                                    color: AppTheme.successLight,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  'Atualizado',
                                  style: AppTheme
                                      .lightTheme.textTheme.labelSmall
                                      ?.copyWith(
                                    color: AppTheme.successLight,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 7.sp,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),

                // Marker
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glow effect for featured/updated businesses
                    if (shouldAnimate)
                      Container(
                        width: 20.w,
                        height: 20.w,
                        decoration: BoxDecoration(
                          color: widget.color
                              .withValues(alpha: 0.1 * _glowAnimation.value),
                          shape: BoxShape.circle,
                        ),
                      ),

                    // Marker shadow
                    Container(
                      width: 12.w,
                      height: 12.w,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      transform: Matrix4.translationValues(0, 1, 0),
                    ),

                    // Main marker
                    Container(
                      width: 12.w,
                      height: 12.w,
                      decoration: BoxDecoration(
                        color: widget.color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: CustomIconWidget(
                          iconName: widget.icon,
                          color: Colors.white,
                          size: 6.w,
                        ),
                      ),
                    ),

                    // Status indicators
                    if (widget.business.isVerified)
                      Positioned(
                        top: -1.h,
                        right: -1.w,
                        child: Container(
                          width: 5.w,
                          height: 5.w,
                          decoration: BoxDecoration(
                            color: AppTheme.successLight,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: CustomIconWidget(
                              iconName: 'verified',
                              color: Colors.white,
                              size: 2.5.w,
                            ),
                          ),
                        ),
                      ),

                    // Recent update indicator
                    if (_hasRecentFuelUpdate && widget.showFuelPrice)
                      Positioned(
                        bottom: -1.h,
                        right: -1.w,
                        child: AnimatedBuilder(
                          animation: _glowAnimation,
                          builder: (context, child) {
                            return Container(
                              width: 4.w,
                              height: 4.w,
                              decoration: BoxDecoration(
                                color: AppTheme.warningLight,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.warningLight.withValues(
                                        alpha: _glowAnimation.value),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                    // Rating badge
                    if (widget.business.averageRating >= 4.5)
                      Positioned(
                        top: -1.h,
                        left: -1.w,
                        child: Container(
                          width: 5.w,
                          height: 5.w,
                          decoration: BoxDecoration(
                            color: AppTheme.warningLight,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: CustomIconWidget(
                              iconName: 'star',
                              color: Colors.white,
                              size: 2.5.w,
                            ),
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
    );
  }
}
