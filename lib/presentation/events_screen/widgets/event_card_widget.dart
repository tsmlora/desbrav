import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EventCardWidget extends StatelessWidget {
  final Map<String, dynamic> event;
  final VoidCallback onTap;
  final Function(String) onRSVPChanged;

  const EventCardWidget({
    Key? key,
    required this.event,
    required this.onTap,
    required this.onRSVPChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DateTime eventDate = event['date'] as DateTime;
    final String formattedDate =
        '${eventDate.day.toString().padLeft(2, '0')}/${eventDate.month.toString().padLeft(2, '0')}/${eventDate.year}';
    final String rsvpStatus = event['rsvpStatus'] as String;

    return Container(
      margin: EdgeInsets.only(bottom: 3.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event cover image
          GestureDetector(
            onTap: onTap,
            child: Container(
              height: 20.h,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  children: [
                    CustomImageWidget(
                      imageUrl: event['coverImage'] as String,
                      width: double.infinity,
                      height: 20.h,
                      fit: BoxFit.cover,
                    ),
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.3),
                          ],
                        ),
                      ),
                    ),
                    // Event type badge
                    Positioned(
                      top: 2.h,
                      left: 4.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 0.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: _getEventTypeColor(
                            event['eventType'] as String,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomIconWidget(
                              iconName: _getEventTypeIcon(
                                event['eventType'] as String,
                              ),
                              color: Colors.white,
                              size: 16,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              _getEventTypeLabel(event['eventType'] as String),
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
                    // Distance badge
                    Positioned(
                      top: 2.h,
                      right: 4.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 0.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomIconWidget(
                              iconName: 'location_on',
                              color: Colors.white,
                              size: 14,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              event['distance'] as String,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Event details
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and date
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event['title'] as String,
                            style: AppTheme.lightTheme.textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 0.5.h),
                          Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'schedule',
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                                size: 16,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                '$formattedDate • ${event['time']}',
                                style: AppTheme.lightTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Price
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 0.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        event['price'] as String,
                        style: TextStyle(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.5.h),
                // Location
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'place',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 16,
                    ),
                    SizedBox(width: 1.w),
                    Expanded(
                      child: Text(
                        event['location'] as String,
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.5.h),
                // Participants and organizer
                Row(
                  children: [
                    // Organizer avatar
                    CircleAvatar(
                      radius: 2.5.w,
                      backgroundImage: NetworkImage(
                        event['organizerAvatar'] as String,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Organizado por ${event['organizerName']}',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            '${event['participantCount']} de ${event['maxParticipants']} participantes',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Difficulty badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 0.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(
                          event['difficulty'] as String,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        event['difficulty'] as String,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                // RSVP buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildRSVPButton(
                        'Vou',
                        'going',
                        rsvpStatus == 'going',
                        AppTheme.lightTheme.colorScheme.primary,
                        'check_circle',
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: _buildRSVPButton(
                        'Interessado',
                        'interested',
                        rsvpStatus == 'interested',
                        AppTheme.lightTheme.colorScheme.secondary,
                        'star',
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: _buildRSVPButton(
                        'Não Vou',
                        'not_going',
                        rsvpStatus == 'not_going',
                        AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        'cancel',
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

  Widget _buildRSVPButton(
    String label,
    String status,
    bool isSelected,
    Color color,
    String iconName,
  ) {
    return GestureDetector(
      onTap: () => onRSVPChanged(status),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          border: Border.all(color: color, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: isSelected ? Colors.white : color,
              size: 16,
            ),
            SizedBox(width: 1.w),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getEventTypeColor(String eventType) {
    switch (eventType) {
      case 'group_ride':
        return AppTheme.lightTheme.colorScheme.primary;
      case 'meetup':
        return AppTheme.lightTheme.colorScheme.secondary;
      case 'rally':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'workshop':
        return AppTheme.successLight;
      default:
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }
  }

  String _getEventTypeIcon(String eventType) {
    switch (eventType) {
      case 'group_ride':
        return 'directions_bike';
      case 'meetup':
        return 'groups';
      case 'rally':
        return 'flag';
      case 'workshop':
        return 'build';
      default:
        return 'event';
    }
  }

  String _getEventTypeLabel(String eventType) {
    switch (eventType) {
      case 'group_ride':
        return 'Passeio';
      case 'meetup':
        return 'Encontro';
      case 'rally':
        return 'Rally';
      case 'workshop':
        return 'Workshop';
      default:
        return 'Evento';
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Iniciante':
        return AppTheme.successLight;
      case 'Intermediário':
        return AppTheme.warningLight;
      case 'Avançado':
        return AppTheme.errorLight;
      default:
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }
  }
}
