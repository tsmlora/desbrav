import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../rest_points_screen.dart';

class MapViewWidget extends StatefulWidget {
  final List<RestPointAccommodation> accommodations;
  final Position? userPosition;
  final Function(RestPointAccommodation) onAccommodationSelected;
  final Function(RestPointAccommodation) onFavoriteToggle;
  final List<String> favoriteIds;

  const MapViewWidget({
    super.key,
    required this.accommodations,
    this.userPosition,
    required this.onAccommodationSelected,
    required this.onFavoriteToggle,
    required this.favoriteIds,
  });

  @override
  State<MapViewWidget> createState() => _MapViewWidgetState();
}

class _MapViewWidgetState extends State<MapViewWidget> {
  RestPointAccommodation? _selectedAccommodation;
  bool _showUserLocation = true;

  Color _getPriceRangeColor(String priceRange) {
    switch (priceRange) {
      case 'budget':
        return AppTheme.successLight;
      case 'mid':
        return AppTheme.warningLight;
      case 'premium':
        return AppTheme.errorLight;
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }

  void _selectAccommodation(RestPointAccommodation accommodation) {
    setState(() {
      _selectedAccommodation = accommodation;
    });
  }

  void _centerOnUserLocation() {
    if (widget.userPosition != null) {
      setState(() {
        _showUserLocation = true;
        _selectedAccommodation = null;
      });
      // Here you would implement actual map centering logic
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Map placeholder - In a real implementation, use Google Maps or similar
        Container(
          width: double.infinity,
          height: double.infinity,
          color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
          child: Stack(
            children: [
              // Background map style
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.1),
                      AppTheme.lightTheme.colorScheme.secondary
                          .withValues(alpha: 0.1),
                    ],
                  ),
                ),
              ),
              // Map markers simulation
              ...widget.accommodations.map((accommodation) {
                final markerPosition = Offset(
                  (accommodation.longitude + 46.6333) * 300,
                  (accommodation.latitude + 23.5505) * 300,
                );

                return Positioned(
                  left: markerPosition.dx,
                  top: markerPosition.dy,
                  child: GestureDetector(
                    onTap: () => _selectAccommodation(accommodation),
                    child: _buildMapMarker(accommodation),
                  ),
                );
              }).toList(),
              // User location marker
              if (widget.userPosition != null && _showUserLocation)
                Positioned(
                  left: 45.w,
                  top: 45.h,
                  child: _buildUserLocationMarker(),
                ),
            ],
          ),
        ),
        // Map controls
        Positioned(
          top: 2.h,
          right: 4.w,
          child: Column(
            children: [
              _buildMapControlButton(
                'my_location',
                'Minha Localização',
                _centerOnUserLocation,
              ),
              SizedBox(height: 1.h),
              _buildMapControlButton(
                'zoom_in',
                'Zoom In',
                () {},
              ),
              SizedBox(height: 1.h),
              _buildMapControlButton(
                'zoom_out',
                'Zoom Out',
                () {},
              ),
            ],
          ),
        ),
        // Selected accommodation preview
        if (_selectedAccommodation != null)
          Positioned(
            bottom: 2.h,
            left: 4.w,
            right: 4.w,
            child: _buildAccommodationPreview(_selectedAccommodation!),
          ),
        // Legend
        Positioned(
          top: 2.h,
          left: 4.w,
          child: _buildLegend(),
        ),
      ],
    );
  }

  Widget _buildMapMarker(RestPointAccommodation accommodation) {
    final isSelected = _selectedAccommodation?.id == accommodation.id;
    final isFavorite = widget.favoriteIds.contains(accommodation.id);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      transform: Matrix4.identity()..scale(isSelected ? 1.2 : 1.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
        decoration: BoxDecoration(
          color: _getPriceRangeColor(accommodation.priceRange),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isFavorite) ...[
              CustomIconWidget(
                iconName: 'favorite',
                color: Colors.white,
                size: 12,
              ),
              SizedBox(width: 1.w),
            ],
            Text(
              'R\$ ${accommodation.price.toStringAsFixed(0)}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserLocationMarker() {
    return Container(
      width: 4.w,
      height: 4.w,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primary,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            spreadRadius: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildMapControlButton(
      String iconName, String tooltip, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: AppTheme.shadowLight.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: CustomIconWidget(
          iconName: iconName,
          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Legenda',
            style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 0.5.h),
          _buildLegendItem(AppTheme.successLight, 'Econômico'),
          _buildLegendItem(AppTheme.warningLight, 'Médio'),
          _buildLegendItem(AppTheme.errorLight, 'Premium'),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.2.h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 3.w,
            height: 3.w,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 1.w),
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.labelSmall,
          ),
        ],
      ),
    );
  }

  Widget _buildAccommodationPreview(RestPointAccommodation accommodation) {
    final isFavorite = widget.favoriteIds.contains(accommodation.id);

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(accommodation.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        accommodation.title,
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => widget.onFavoriteToggle(accommodation),
                      child: CustomIconWidget(
                        iconName: isFavorite ? 'favorite' : 'favorite_border',
                        color: isFavorite
                            ? AppTheme.errorLight
                            : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'star',
                      color: AppTheme.warningLight,
                      size: 14,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      '${accommodation.rating} (${accommodation.reviewCount})',
                      style: AppTheme.lightTheme.textTheme.bodySmall,
                    ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'R\$ ${accommodation.price.toStringAsFixed(0)}/noite',
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        color: AppTheme.primaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    GestureDetector(
                      onTap: () =>
                          widget.onAccommodationSelected(accommodation),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Ver',
                          style: AppTheme.lightTheme.textTheme.labelMedium
                              ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
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
    );
  }
}
