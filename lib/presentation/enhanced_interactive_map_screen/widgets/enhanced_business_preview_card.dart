import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../core/models/business.dart';

class EnhancedBusinessPreviewCard extends StatefulWidget {
  final Business business;
  final List<FuelPrice> fuelPrices;
  final VoidCallback onClose;
  final VoidCallback onNavigate;
  final VoidCallback onViewDetails;
  final VoidCallback onToggleFavorite;

  const EnhancedBusinessPreviewCard({
    Key? key,
    required this.business,
    required this.fuelPrices,
    required this.onClose,
    required this.onNavigate,
    required this.onViewDetails,
    required this.onToggleFavorite,
  }) : super(key: key);

  @override
  State<EnhancedBusinessPreviewCard> createState() =>
      _EnhancedBusinessPreviewCardState();
}

class _EnhancedBusinessPreviewCardState
    extends State<EnhancedBusinessPreviewCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color get _businessTypeColor {
    switch (widget.business.businessType) {
      case 'gas_station':
        return AppTheme.lightTheme.colorScheme.secondary;
      case 'workshop':
        return AppTheme.lightTheme.colorScheme.primary;
      case 'restaurant':
        return AppTheme.successLight;
      case 'hotel':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'tourist_spot':
        return AppTheme.accentLight;
      default:
        return AppTheme.lightTheme.colorScheme.outline;
    }
  }

  String get _businessTypeIcon {
    switch (widget.business.businessType) {
      case 'gas_station':
        return 'local_gas_station';
      case 'workshop':
        return 'build';
      case 'restaurant':
        return 'restaurant';
      case 'hotel':
        return 'hotel';
      case 'tourist_spot':
        return 'place';
      default:
        return 'place';
    }
  }

  Widget _buildFuelPrices() {
    if (widget.fuelPrices.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(top: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'local_gas_station',
                color: AppTheme.lightTheme.colorScheme.secondary,
                size: 4.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Preços de Combustível',
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: AppTheme.successLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.fuelPrices.first.lastUpdated,
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.successLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: widget.fuelPrices.take(3).map((fuelPrice) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fuelPrice.fuelTypeDisplay,
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.outline,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 0.2.h),
                    Text(
                      fuelPrice.formattedPrice,
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOperatingHours() {
    if (widget.business.operatingHours == null) return const SizedBox.shrink();

    final now = DateTime.now();
    final weekday = _getWeekdayKey(now.weekday);
    final todayHours = widget.business.operatingHours![weekday];

    if (todayHours == null) return const SizedBox.shrink();

    final isOpen = widget.business.isOpen;

    return Container(
      margin: EdgeInsets.only(top: 1.h),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'access_time',
            color: isOpen ? AppTheme.successLight : AppTheme.errorLight,
            size: 4.w,
          ),
          SizedBox(width: 2.w),
          Text(
            isOpen ? 'Aberto' : 'Fechado',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: isOpen ? AppTheme.successLight : AppTheme.errorLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 2.w),
          Text(
            todayHours == 'closed'
                ? 'Fechado hoje'
                : todayHours == '00:00-23:59'
                    ? '24h'
                    : todayHours,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  String _getWeekdayKey(int weekday) {
    switch (weekday) {
      case 1:
        return 'monday';
      case 2:
        return 'tuesday';
      case 3:
        return 'wednesday';
      case 4:
        return 'thursday';
      case 5:
        return 'friday';
      case 6:
        return 'saturday';
      case 7:
        return 'sunday';
      default:
        return 'monday';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with image and close button
                  Container(
                    height: 20.h,
                    decoration: BoxDecoration(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(20)),
                      color: AppTheme.lightTheme.colorScheme.surface,
                    ),
                    child: Stack(
                      children: [
                        // Business image
                        if (widget.business.primaryImageUrl != null)
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20)),
                            child: CachedNetworkImage(
                              imageUrl: widget.business.primaryImageUrl!,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: AppTheme.lightTheme.colorScheme.surface,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppTheme.lightTheme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color:
                                    _businessTypeColor.withValues(alpha: 0.1),
                                child: Center(
                                  child: CustomIconWidget(
                                    iconName: _businessTypeIcon,
                                    color: _businessTypeColor,
                                    size: 15.w,
                                  ),
                                ),
                              ),
                            ),
                          )
                        else
                          Container(
                            decoration: BoxDecoration(
                              color: _businessTypeColor.withValues(alpha: 0.1),
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(20)),
                            ),
                            child: Center(
                              child: CustomIconWidget(
                                iconName: _businessTypeIcon,
                                color: _businessTypeColor,
                                size: 15.w,
                              ),
                            ),
                          ),

                        // Gradient overlay
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20)),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.3),
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.6),
                              ],
                            ),
                          ),
                        ),

                        // Business type badge
                        Positioned(
                          top: 2.h,
                          left: 4.w,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 3.w, vertical: 1.h),
                            decoration: BoxDecoration(
                              color: _businessTypeColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CustomIconWidget(
                                  iconName: _businessTypeIcon,
                                  color: Colors.white,
                                  size: 3.w,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  widget.business.businessTypeDisplay,
                                  style: AppTheme
                                      .lightTheme.textTheme.labelSmall
                                      ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Close button
                        Positioned(
                          top: 2.h,
                          right: 4.w,
                          child: GestureDetector(
                            onTap: widget.onClose,
                            child: Container(
                              width: 10.w,
                              height: 10.w,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: CustomIconWidget(
                                  iconName: 'close',
                                  color: Colors.white,
                                  size: 5.w,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Verification badge
                        if (widget.business.isVerified)
                          Positioned(
                            bottom: 2.h,
                            left: 4.w,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 2.w, vertical: 0.5.h),
                              decoration: BoxDecoration(
                                color: AppTheme.successLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CustomIconWidget(
                                    iconName: 'verified',
                                    color: Colors.white,
                                    size: 3.w,
                                  ),
                                  SizedBox(width: 1.w),
                                  Text(
                                    'Verificado',
                                    style: AppTheme
                                        .lightTheme.textTheme.labelSmall
                                        ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Rating
                        if (widget.business.averageRating > 0)
                          Positioned(
                            bottom: 2.h,
                            right: 4.w,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 2.w, vertical: 0.5.h),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CustomIconWidget(
                                    iconName: 'star',
                                    color: AppTheme.warningLight,
                                    size: 3.w,
                                  ),
                                  SizedBox(width: 1.w),
                                  Text(
                                    widget.business.averageRating
                                        .toStringAsFixed(1),
                                    style: AppTheme
                                        .lightTheme.textTheme.labelSmall
                                        ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 0.5.w),
                                  Text(
                                    '(${widget.business.totalReviews})',
                                    style: AppTheme
                                        .lightTheme.textTheme.labelSmall
                                        ?.copyWith(
                                      color:
                                          Colors.white.withValues(alpha: 0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Content
                  Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Business name and distance
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.business.name,
                                    style: AppTheme
                                        .lightTheme.textTheme.titleMedium
                                        ?.copyWith(
                                      color: AppTheme
                                          .lightTheme.colorScheme.onSurface,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 0.5.h),
                                  Text(
                                    widget.business.displayAddress,
                                    style: AppTheme
                                        .lightTheme.textTheme.bodySmall
                                        ?.copyWith(
                                      color: AppTheme
                                          .lightTheme.colorScheme.outline,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            if (widget.business.distance != null)
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 2.w, vertical: 0.5.h),
                                decoration: BoxDecoration(
                                  color: AppTheme.lightTheme.colorScheme.primary
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${widget.business.distance!.toStringAsFixed(1)} km',
                                  style: AppTheme
                                      .lightTheme.textTheme.labelSmall
                                      ?.copyWith(
                                    color:
                                        AppTheme.lightTheme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        // Operating hours
                        _buildOperatingHours(),

                        // Fuel prices for gas stations
                        if (widget.business.businessType == 'gas_station')
                          _buildFuelPrices(),

                        // Amenities
                        if (widget.business.amenities.isNotEmpty)
                          Container(
                            margin: EdgeInsets.only(top: 2.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Comodidades',
                                  style: AppTheme
                                      .lightTheme.textTheme.labelMedium
                                      ?.copyWith(
                                    color: AppTheme
                                        .lightTheme.colorScheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Wrap(
                                  spacing: 2.w,
                                  runSpacing: 0.5.h,
                                  children: widget.business.amenities
                                      .take(4)
                                      .map((amenity) {
                                    return Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 2.w, vertical: 0.5.h),
                                      decoration: BoxDecoration(
                                        color: AppTheme
                                            .lightTheme.colorScheme.surface,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color:
                                              AppTheme.lightTheme.dividerColor,
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        amenity
                                            .replaceAll('_', ' ')
                                            .toLowerCase(),
                                        style: AppTheme
                                            .lightTheme.textTheme.labelSmall
                                            ?.copyWith(
                                          color: AppTheme
                                              .lightTheme.colorScheme.outline,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),

                        SizedBox(height: 3.h),

                        // Action buttons
                        Row(
                          children: [
                            // Favorite button
                            Container(
                              width: 12.w,
                              height: 12.w,
                              decoration: BoxDecoration(
                                color: AppTheme.lightTheme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.lightTheme.dividerColor,
                                  width: 1,
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: widget.onToggleFavorite,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Center(
                                    child: CustomIconWidget(
                                      iconName: 'favorite_border',
                                      color: AppTheme.errorLight,
                                      size: 5.w,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 3.w),

                            // Navigation button
                            Expanded(
                              child: ElevatedButton(
                                onPressed: widget.onNavigate,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  padding:
                                      EdgeInsets.symmetric(vertical: 1.5.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomIconWidget(
                                      iconName: 'navigation',
                                      color: Colors.white,
                                      size: 4.w,
                                    ),
                                    SizedBox(width: 2.w),
                                    Text(
                                      'Navegar',
                                      style: AppTheme
                                          .lightTheme.textTheme.bodyMedium
                                          ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 3.w),

                            // Details button
                            Expanded(
                              child: OutlinedButton(
                                onPressed: widget.onViewDetails,
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      EdgeInsets.symmetric(vertical: 1.5.h),
                                  side: BorderSide(
                                    color:
                                        AppTheme.lightTheme.colorScheme.primary,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomIconWidget(
                                      iconName: 'info_outline',
                                      color: AppTheme
                                          .lightTheme.colorScheme.primary,
                                      size: 4.w,
                                    ),
                                    SizedBox(width: 2.w),
                                    Text(
                                      'Detalhes',
                                      style: AppTheme
                                          .lightTheme.textTheme.bodyMedium
                                          ?.copyWith(
                                        color: AppTheme
                                            .lightTheme.colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
