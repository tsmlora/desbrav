import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';

class OptimizedBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final int? directMessagesBadgeCount;
  final int? communityBadgeCount;

  const OptimizedBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.directMessagesBadgeCount,
    this.communityBadgeCount,
  });

  @override
  State<OptimizedBottomNavigationBar> createState() =>
      _OptimizedBottomNavigationBarState();
}

class _OptimizedBottomNavigationBarState
    extends State<OptimizedBottomNavigationBar> with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _scaleAnimations;

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: 'speed',
      label: 'Dashboard',
      tooltip: 'Painel Principal',
    ),
    NavigationItem(
      icon: 'location_on',
      label: 'Mapa',
      tooltip: 'Mapa Interativo',
    ),
    NavigationItem(
      icon: 'groups',
      label: 'Comunidade',
      tooltip: 'Comunidade de Motociclistas',
    ),
    NavigationItem(
      icon: 'chat_bubble',
      label: 'Mensagens',
      tooltip: 'Mensagens Diretas',
    ),
    NavigationItem(
      icon: 'single_bed',
      label: 'Descanso',
      tooltip: 'Pontos de Descanso',
    ),
    NavigationItem(
      icon: 'person',
      label: 'Perfil',
      tooltip: 'Meu Perfil',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationControllers = List.generate(
      _navigationItems.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );

    _scaleAnimations = _animationControllers.map((controller) {
      return Tween<double>(begin: 1.0, end: 1.15).animate(
        CurvedAnimation(parent: controller, curve: Curves.elasticOut),
      );
    }).toList();

    // Animate current tab
    if (widget.currentIndex < _animationControllers.length) {
      _animationControllers[widget.currentIndex].forward();
    }
  }

  @override
  void didUpdateWidget(OptimizedBottomNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      // Reset previous animation
      if (oldWidget.currentIndex < _animationControllers.length) {
        _animationControllers[oldWidget.currentIndex].reverse();
      }
      // Start new animation
      if (widget.currentIndex < _animationControllers.length) {
        _animationControllers[widget.currentIndex].forward();
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handleTap(int index) {
    HapticFeedback.selectionClick();
    widget.onTap(index);
  }

  void _showTooltip(int index) {
    final item = _navigationItems[index];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(item.tooltip),
        duration: const Duration(milliseconds: 1000),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: 12.h,
          left: 4.w,
          right: 4.w,
        ),
      ),
    );
  }

  Widget _buildBadge(int? count) {
    if (count == null || count == 0) return const SizedBox.shrink();

    return Positioned(
      right: 0,
      top: 0,
      child: Container(
        padding: EdgeInsets.all(0.5.w),
        decoration: BoxDecoration(
          color: AppTheme.errorLight,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: AppTheme.errorLight.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        constraints: BoxConstraints(
          minWidth: 4.w,
          minHeight: 4.w,
        ),
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 8.sp,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navigationItems.length, (index) {
              final item = _navigationItems[index];
              final isActive = widget.currentIndex == index;

              int? badgeCount;
              if (index == 2) {
                // Community
                badgeCount = widget.communityBadgeCount;
              } else if (index == 3) {
                // Direct Messages
                badgeCount = widget.directMessagesBadgeCount;
              }

              return Expanded(
                child: GestureDetector(
                  onTap: () => _handleTap(index),
                  onLongPress: () => _showTooltip(index),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 65,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _scaleAnimations[index],
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _scaleAnimations[index].value,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding:
                                        EdgeInsets.all(isActive ? 3.w : 2.5.w),
                                    decoration: BoxDecoration(
                                      gradient: isActive
                                          ? LinearGradient(
                                              colors: [
                                                AppTheme.primaryLight,
                                                AppTheme.primaryLight
                                                    .withValues(alpha: 0.8),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            )
                                          : null,
                                      color:
                                          isActive ? null : Colors.transparent,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: isActive
                                          ? [
                                              BoxShadow(
                                                color: AppTheme.primaryLight
                                                    .withValues(alpha: 0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: CustomIconWidget(
                                      iconName: item.icon,
                                      color: isActive
                                          ? Colors.white
                                          : AppTheme.lightTheme.colorScheme
                                              .onSurfaceVariant,
                                      size: isActive ? 24 : 22,
                                    ),
                                  ),
                                  if (isActive) ...[
                                    SizedBox(height: 0.5.h),
                                    Text(
                                      item.label,
                                      style: TextStyle(
                                        color: AppTheme.primaryLight,
                                        fontSize: 9.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
                        _buildBadge(badgeCount),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class NavigationItem {
  final String icon;
  final String label;
  final String tooltip;

  NavigationItem({
    required this.icon,
    required this.label,
    required this.tooltip,
  });
}
