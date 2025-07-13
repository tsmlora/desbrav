import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TypingIndicatorWidget extends StatefulWidget {
  final List<dynamic> participants;

  const TypingIndicatorWidget({Key? key, required this.participants})
      : super(key: key);

  @override
  State<TypingIndicatorWidget> createState() => _TypingIndicatorWidgetState();
}

class _TypingIndicatorWidgetState extends State<TypingIndicatorWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Simulate typing indicator
    _simulateTyping();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _simulateTyping() {
    // Show typing indicator randomly
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && widget.participants.isNotEmpty) {
        setState(() {
          _isVisible = true;
        });
        _animationController.repeat(reverse: true);

        // Hide after some time
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _isVisible = false;
            });
            _animationController.stop();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible || widget.participants.isEmpty) {
      return const SizedBox.shrink();
    }

    final typingUser = widget.participants.first;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4.w),
              child: typingUser["avatar"] != null
                  ? CustomImageWidget(
                      imageUrl: typingUser["avatar"],
                      width: 8.w,
                      height: 8.w,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.1),
                      child: Center(
                        child: CustomIconWidget(
                          iconName: 'person',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 16,
                        ),
                      ),
                    ),
            ),
          ),
          SizedBox(width: 2.w),
          Container(
            constraints: BoxConstraints(maxWidth: 60.w),
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(
                color: AppTheme.lightTheme.dividerColor,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${typingUser["name"]} está digitando',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(width: 2.w),
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Row(
                      children: List.generate(3, (index) {
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 0.5.w),
                          child: Opacity(
                            opacity: _animation.value,
                            child: Container(
                              width: 1.5.w,
                              height: 1.5.w,
                              decoration: BoxDecoration(
                                color: AppTheme.lightTheme.colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
