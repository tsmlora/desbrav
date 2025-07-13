import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class LogoSectionWidget extends StatelessWidget {
  const LogoSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo Container with motorcycle icon
        Container(
          width: 20.w,
          height: 20.w,
          decoration: BoxDecoration(
            color: AppTheme.primaryLight,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryLight.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: 'motorcycle',
              color: Colors.white,
              size: 10.w,
            ),
          ),
        ),

        SizedBox(height: 3.h),

        // App Name
        Text(
          'DESBRAV',
          style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
            color: AppTheme.primaryLight,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
          ),
        ),

        SizedBox(height: 1.h),

        // Welcome Message
        Text(
          'Bem-vindo de volta!',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.textSecondaryLight,
            fontWeight: FontWeight.w400,
          ),
        ),

        SizedBox(height: 0.5.h),

        Text(
          'Entre para continuar sua aventura',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}
