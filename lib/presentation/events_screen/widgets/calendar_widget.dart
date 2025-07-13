import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CalendarWidget extends StatefulWidget {
  final List<Map<String, dynamic>> events;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const CalendarWidget({
    Key? key,
    required this.events,
    required this.selectedDate,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late DateTime _currentMonth;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
    );
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Calendar header
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          color: AppTheme.lightTheme.colorScheme.surface,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _previousMonth,
                icon: CustomIconWidget(
                  iconName: 'chevron_left',
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  size: 24,
                ),
              ),
              Text(
                _getMonthYearText(_currentMonth),
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                onPressed: _nextMonth,
                icon: CustomIconWidget(
                  iconName: 'chevron_right',
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
        // Weekday headers
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          color: AppTheme.lightTheme.colorScheme.surface,
          child: Row(children: _buildWeekdayHeaders()),
        ),
        // Calendar grid
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentMonth = DateTime(
                  _currentMonth.year,
                  _currentMonth.month + (index - 1),
                );
              });
            },
            itemBuilder: (context, index) {
              final month = DateTime(
                _currentMonth.year,
                _currentMonth.month + (index - 1),
              );
              return _buildCalendarGrid(month);
            },
          ),
        ),
        // Selected date events
        if (_getEventsForDate(widget.selectedDate).isNotEmpty)
          Container(height: 25.h, child: _buildSelectedDateEvents()),
      ],
    );
  }

  List<Widget> _buildWeekdayHeaders() {
    final weekdays = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
    return weekdays.map((day) {
      return Expanded(
        child: Center(
          child: Text(
            day,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildCalendarGrid(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    final firstDayWeekday = firstDayOfMonth.weekday % 7;
    final daysInMonth = lastDayOfMonth.day;

    return GridView.builder(
      padding: EdgeInsets.all(4.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
        crossAxisSpacing: 1.w,
        mainAxisSpacing: 1.h,
      ),
      itemCount: 42, // 6 weeks * 7 days
      itemBuilder: (context, index) {
        final dayIndex = index - firstDayWeekday;

        if (dayIndex < 0 || dayIndex >= daysInMonth) {
          return Container(); // Empty cell
        }

        final day = dayIndex + 1;
        final date = DateTime(month.year, month.month, day);
        final isSelected = _isSameDay(date, widget.selectedDate);
        final isToday = _isSameDay(date, DateTime.now());
        final events = _getEventsForDate(date);

        return GestureDetector(
          onTap: () => widget.onDateSelected(date),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.lightTheme.colorScheme.primary
                  : isToday
                      ? AppTheme.lightTheme.colorScheme.primary.withValues(
                          alpha: 0.1,
                        )
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isToday && !isSelected
                  ? Border.all(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      width: 1,
                    )
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  day.toString(),
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? Colors.white
                        : isToday
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.onSurface,
                    fontWeight: isSelected || isToday
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
                if (events.isNotEmpty)
                  Container(
                    margin: EdgeInsets.only(top: 0.5.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _buildEventDots(events, isSelected),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildEventDots(
    List<Map<String, dynamic>> events,
    bool isSelected,
  ) {
    final maxDots = 3;
    final dotsToShow = events.length > maxDots ? maxDots : events.length;

    return List.generate(dotsToShow, (index) {
      final event = events[index];
      final rsvpStatus = event['rsvpStatus'] as String;

      Color dotColor;
      if (isSelected) {
        dotColor = Colors.white;
      } else {
        switch (rsvpStatus) {
          case 'going':
            dotColor = AppTheme.lightTheme.colorScheme.primary;
            break;
          case 'interested':
            dotColor = AppTheme.lightTheme.colorScheme.secondary;
            break;
          default:
            dotColor = AppTheme.lightTheme.colorScheme.onSurfaceVariant;
        }
      }

      return Container(
        width: 1.w,
        height: 1.w,
        margin: EdgeInsets.symmetric(horizontal: 0.5.w),
        decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
      );
    });
  }

  Widget _buildSelectedDateEvents() {
    final events = _getEventsForDate(widget.selectedDate);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: AppTheme.lightTheme.dividerColor, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Eventos em ${_getFormattedDate(widget.selectedDate)}',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Expanded(
            child: ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 1.h),
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.lightTheme.dividerColor,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 1.w,
                        height: 6.h,
                        decoration: BoxDecoration(
                          color: _getEventStatusColor(
                            event['rsvpStatus'] as String,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event['title'] as String,
                              style: AppTheme.lightTheme.textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 0.5.h),
                            Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'schedule',
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                                  size: 14,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  event['time'] as String,
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                    color: AppTheme.lightTheme.colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                                SizedBox(width: 3.w),
                                CustomIconWidget(
                                  iconName: 'place',
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                                  size: 14,
                                ),
                                SizedBox(width: 1.w),
                                Expanded(
                                  child: Text(
                                    event['location'] as String,
                                    style: AppTheme
                                        .lightTheme.textTheme.bodySmall
                                        ?.copyWith(
                                      color: AppTheme.lightTheme.colorScheme
                                          .onSurfaceVariant,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getEventsForDate(DateTime date) {
    return widget.events.where((event) {
      final eventDate = event['date'] as DateTime;
      return _isSameDay(eventDate, date);
    }).toList();
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _getMonthYearText(DateTime date) {
    final months = [
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
    return '${months[date.month - 1]} ${date.year}';
  }

  String _getFormattedDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Color _getEventStatusColor(String rsvpStatus) {
    switch (rsvpStatus) {
      case 'going':
        return AppTheme.lightTheme.colorScheme.primary;
      case 'interested':
        return AppTheme.lightTheme.colorScheme.secondary;
      case 'not_going':
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
      default:
        return AppTheme.lightTheme.dividerColor;
    }
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }
}
