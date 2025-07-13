import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TrackingControlsWidget extends StatelessWidget {
  final bool isTracking;
  final bool isPaused;
  final VoidCallback onToggleTracking;
  final VoidCallback onPauseResume;
  final VoidCallback onAddWaypoint;
  final VoidCallback onEmergencyContact;
  final VoidCallback onOpenSettings;
  final Animation<double> pulseAnimation;

  const TrackingControlsWidget({
    super.key,
    required this.isTracking,
    required this.isPaused,
    required this.onToggleTracking,
    required this.onPauseResume,
    required this.onAddWaypoint,
    required this.onEmergencyContact,
    required this.onOpenSettings,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main tracking button
        AnimatedBuilder(
          animation: pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: isTracking ? pulseAnimation.value : 1.0,
              child: Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  color:
                      isTracking ? AppTheme.errorLight : AppTheme.primaryLight,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isTracking
                              ? AppTheme.errorLight
                              : AppTheme.primaryLight)
                          .withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onToggleTracking,
                    borderRadius: BorderRadius.circular(10.w),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: isTracking ? 'stop' : 'play_arrow',
                            color: Colors.white,
                            size: 32,
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            isTracking ? 'Parar' : 'Iniciar',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        SizedBox(height: 3.h),

        // Control buttons row
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                iconName: isPaused ? 'play_arrow' : 'pause',
                label: isPaused ? 'Continuar' : 'Pausar',
                onTap: isTracking ? onPauseResume : null,
                color: isPaused ? AppTheme.successLight : AppTheme.warningLight,
              ),
              _buildControlButton(
                iconName: 'add_location',
                label: 'Waypoint',
                onTap: isTracking ? onAddWaypoint : null,
                color: AppTheme.secondaryLight,
              ),
              _buildControlButton(
                iconName: 'emergency',
                label: 'Emergência',
                onTap: onEmergencyContact,
                color: AppTheme.errorLight,
              ),
              _buildControlButton(
                iconName: 'settings',
                label: 'Config',
                onTap: onOpenSettings,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required String iconName,
    required String label,
    required VoidCallback? onTap,
    required Color color,
  }) {
    final bool isEnabled = onTap != null;

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: iconName,
                    color: color,
                    size: 20,
                  ),
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
