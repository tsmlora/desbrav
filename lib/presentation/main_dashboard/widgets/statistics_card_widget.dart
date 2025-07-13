import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/statistics_service.dart';

class StatisticsCardWidget extends StatelessWidget {
  final Map<String, dynamic>? stats;
  final bool isLoading;

  const StatisticsCardWidget({
    super.key,
    this.stats,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Estatísticas de Hoje',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (isLoading)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                )
              else
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: AppTheme.successLight.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'trending_up',
                        color: AppTheme.successLight,
                        size: 16,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        '+${stats?["xpEarned"] ?? 0} XP',
                        style:
                            AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                          color: AppTheme.successLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 3.h),
          if (isLoading)
            _buildLoadingState()
          else if (stats == null || (stats?["distance"] ?? 0) == 0)
            _buildEmptyState()
          else
            _buildStatisticsContent(),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildLoadingStatItem()),
            SizedBox(width: 4.w),
            Expanded(child: _buildLoadingStatItem()),
          ],
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(child: _buildLoadingStatItem()),
            SizedBox(width: 4.w),
            Expanded(child: _buildLoadingStatItem()),
          ],
        ),
        SizedBox(height: 2.h),
        _buildLoadingRidesItem(),
      ],
    );
  }

  Widget _buildLoadingStatItem() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(width: 2.w),
              Container(
                width: 15.w,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Container(
            width: 12.w,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingRidesItem() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(width: 2.w),
          Container(
            width: 40.w,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        SizedBox(height: 2.h),
        CustomIconWidget(
          iconName: 'motorcycle',
          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          size: 48,
        ),
        SizedBox(height: 2.h),
        Text(
          'Nenhuma viagem hoje',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Inicie uma viagem para ver suas estatísticas aqui',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 2.h),
      ],
    );
  }

  Widget _buildStatisticsContent() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                'Distância',
                '${stats!["distance"]} km',
                'straighten',
                AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: _buildStatItem(
                'Tempo',
                stats!["time"] as String,
                'schedule',
                AppTheme.secondaryLight,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                'Velocidade Média',
                '${stats!["avgSpeed"]} km/h',
                'speed',
                AppTheme.warningLight,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: _buildStatItem(
                'Vel. Máxima',
                '${stats!["maxSpeed"]} km/h',
                'flash_on',
                AppTheme.errorLight,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.primary.withValues(
              alpha: 0.05,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.primary.withValues(
                alpha: 0.1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'motorcycle',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                '${stats!["rides"]} ${(stats!["rides"] as int) == 1 ? "viagem realizada" : "viagens realizadas"} hoje',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, String icon, Color color) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(iconName: icon, color: color, size: 20),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  label,
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// New StatefulWidget to handle real-time statistics
class RealTimeStatisticsWidget extends StatefulWidget {
  const RealTimeStatisticsWidget({super.key});

  @override
  State<RealTimeStatisticsWidget> createState() =>
      _RealTimeStatisticsWidgetState();
}

class _RealTimeStatisticsWidgetState extends State<RealTimeStatisticsWidget> {
  final StatisticsService _statisticsService = StatisticsService();
  bool _isLoading = true;
  Map<String, dynamic>? _todayStats;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTodayStatistics();
  }

  Future<void> _loadTodayStatistics() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id;

      if (userId != null) {
        final stats =
            await _statisticsService.getTodayStatisticsFromFunction(userId);
        setState(() {
          _todayStats = stats;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Usuário não autenticado';
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 6.w),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.shadowLight,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: 'error_outline',
              color: AppTheme.errorLight,
              size: 32,
            ),
            SizedBox(height: 1.h),
            Text(
              'Erro ao carregar estatísticas',
              style: AppTheme.lightTheme.textTheme.titleMedium,
            ),
            SizedBox(height: 1.h),
            ElevatedButton(
              onPressed: _loadTodayStatistics,
              child: Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    return StatisticsCardWidget(
      stats: _todayStats,
      isLoading: _isLoading,
    );
  }
}
