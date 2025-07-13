import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PasswordStrengthWidget extends StatelessWidget {
  final String password;

  const PasswordStrengthWidget({Key? key, required this.password})
      : super(key: key);

  PasswordStrength _getPasswordStrength() {
    if (password.isEmpty) return PasswordStrength.none;

    int score = 0;

    // Length check
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;

    // Character variety checks
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'\d').hasMatch(password)) score++;
    if (RegExp(r'[!@#\$&*~]').hasMatch(password)) score++;

    if (score <= 2) return PasswordStrength.weak;
    if (score <= 4) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }

  @override
  Widget build(BuildContext context) {
    final strength = _getPasswordStrength();

    if (password.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: strength.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: strength.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: strength.icon,
                color: strength.color,
                size: 16,
              ),
              SizedBox(width: 2.w),
              Text(
                'Força da senha: ${strength.label}',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: strength.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),

          // Strength indicator bars
          Row(
            children: List.generate(3, (index) {
              Color barColor;
              if (strength == PasswordStrength.none) {
                barColor = AppTheme.dividerLight;
              } else if (strength == PasswordStrength.weak) {
                barColor =
                    index == 0 ? AppTheme.errorLight : AppTheme.dividerLight;
              } else if (strength == PasswordStrength.medium) {
                barColor =
                    index <= 1 ? AppTheme.warningLight : AppTheme.dividerLight;
              } else {
                barColor = AppTheme.successLight;
              }

              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: index < 2 ? 1.w : 0),
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 1.h),

          // Requirements checklist
          if (strength != PasswordStrength.strong) ...[
            Text(
              'Requisitos:',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 0.5.h),
            ..._getRequirements().map(
              (requirement) => Padding(
                padding: EdgeInsets.only(bottom: 0.5.h),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: requirement.isMet
                          ? 'check_circle'
                          : 'radio_button_unchecked',
                      color: requirement.isMet
                          ? AppTheme.successLight
                          : AppTheme.textMediumEmphasisLight,
                      size: 14,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        requirement.text,
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: requirement.isMet
                              ? AppTheme.successLight
                              : AppTheme.textMediumEmphasisLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<PasswordRequirement> _getRequirements() {
    return [
      PasswordRequirement(
        text: 'Pelo menos 8 caracteres',
        isMet: password.length >= 8,
      ),
      PasswordRequirement(
        text: 'Uma letra maiúscula',
        isMet: RegExp(r'[A-Z]').hasMatch(password),
      ),
      PasswordRequirement(
        text: 'Uma letra minúscula',
        isMet: RegExp(r'[a-z]').hasMatch(password),
      ),
      PasswordRequirement(
        text: 'Um número',
        isMet: RegExp(r'\d').hasMatch(password),
      ),
    ];
  }
}

enum PasswordStrength { none, weak, medium, strong }

extension PasswordStrengthExtension on PasswordStrength {
  String get label {
    switch (this) {
      case PasswordStrength.none:
        return 'Nenhuma';
      case PasswordStrength.weak:
        return 'Fraca';
      case PasswordStrength.medium:
        return 'Média';
      case PasswordStrength.strong:
        return 'Forte';
    }
  }

  Color get color {
    switch (this) {
      case PasswordStrength.none:
        return AppTheme.textMediumEmphasisLight;
      case PasswordStrength.weak:
        return AppTheme.errorLight;
      case PasswordStrength.medium:
        return AppTheme.warningLight;
      case PasswordStrength.strong:
        return AppTheme.successLight;
    }
  }

  String get icon {
    switch (this) {
      case PasswordStrength.none:
        return 'help_outline';
      case PasswordStrength.weak:
        return 'error_outline';
      case PasswordStrength.medium:
        return 'warning_amber';
      case PasswordStrength.strong:
        return 'check_circle_outline';
    }
  }
}

class PasswordRequirement {
  final String text;
  final bool isMet;

  PasswordRequirement({required this.text, required this.isMet});
}
