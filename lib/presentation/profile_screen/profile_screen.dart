import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/achievements_service.dart';
import './widgets/profile_achievements_widget.dart';
import './widgets/profile_edit_modal.dart';
import './widgets/profile_header_widget.dart';
import './widgets/profile_settings_widget.dart';
import './widgets/profile_stats_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AchievementsService _achievementsService = AchievementsService();

  bool _isLoading = false;
  List<UserAchievement> _recentAchievements = [];
  AchievementStatistics? _achievementStats;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userProfile = authProvider.currentUserProfile;

      if (userProfile != null) {
        final achievements =
            await _achievementsService.getRecentAchievements(userProfile.id);
        final stats =
            await _achievementsService.getAchievementStatistics(userProfile.id);

        if (mounted) {
          setState(() {
            _recentAchievements = achievements;
            _achievementStats = stats;
            _isLoading = false;
          });
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar dados: $error'),
            backgroundColor: AppTheme.errorLight,
          ),
        );
      }
    }
  }

  Future<void> _handleRefresh() async {
    HapticFeedback.mediumImpact();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.refreshProfile();
    await _loadUserData();
  }

  void _handleEditProfile() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProfileEditModal(
        onSaved: () {
          _handleRefresh();
        },
      ),
    );
  }

  void _handleLogout() async {
    HapticFeedback.mediumImpact();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sair da Conta'),
        content: Text('Tem certeza que deseja sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signOut();

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login-screen');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Perfil',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _handleEditProfile,
            icon: CustomIconWidget(
              iconName: 'edit',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
          IconButton(
            onPressed: _handleLogout,
            icon: CustomIconWidget(
              iconName: 'logout',
              color: AppTheme.errorLight,
              size: 24,
            ),
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final userProfile = authProvider.currentUserProfile;

          if (!authProvider.isAuthenticated || userProfile == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'person_off',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 64,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Usuário não autenticado',
                    style: AppTheme.lightTheme.textTheme.titleLarge,
                  ),
                  SizedBox(height: 1.h),
                  ElevatedButton(
                    onPressed: () => Navigator.pushReplacementNamed(
                        context, '/login-screen'),
                    child: Text('Fazer Login'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _handleRefresh,
            color: AppTheme.lightTheme.colorScheme.primary,
            child: CustomScrollView(
              slivers: [
                // Profile Header
                SliverToBoxAdapter(
                  child: ProfileHeaderWidget(
                    userProfile: userProfile,
                    onEditPressed: _handleEditProfile,
                  ),
                ),

                // Profile Stats
                SliverToBoxAdapter(
                  child: ProfileStatsWidget(
                    userProfile: userProfile,
                    achievementStats: _achievementStats,
                  ),
                ),

                // Tab Bar
                SliverToBoxAdapter(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    child: TabBar(
                      controller: _tabController,
                      tabs: [
                        Tab(text: 'Conquistas'),
                        Tab(text: 'Estatísticas'),
                        Tab(text: 'Configurações'),
                      ],
                    ),
                  ),
                ),

                // Tab Content
                SliverFillRemaining(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Achievements Tab
                      ProfileAchievementsWidget(
                        userProfile: userProfile,
                        recentAchievements: _recentAchievements,
                        achievementStats: _achievementStats,
                        isLoading: _isLoading,
                      ),

                      // Statistics Tab
                      _buildStatisticsTab(userProfile),

                      // Settings Tab
                      ProfileSettingsWidget(
                        userProfile: userProfile,
                        onLogout: _handleLogout,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatisticsTab(userProfile) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Riding Statistics
          _buildStatisticCard(
            'Estatísticas de Pilotagem',
            [
              _buildStatisticRow('Distância Total',
                  '${userProfile.totalDistance.toStringAsFixed(1)} km'),
              _buildStatisticRow(
                  'Viagens Realizadas', '${userProfile.totalRides}'),
              _buildStatisticRow(
                  'Cidades Visitadas', '${userProfile.totalCitiesVisited}'),
              _buildStatisticRow('XP Total', '${userProfile.totalXp}'),
              _buildStatisticRow('Nível Atual', '${userProfile.level}'),
            ],
          ),

          SizedBox(height: 3.h),

          // Achievement Statistics
          if (_achievementStats != null)
            _buildStatisticCard(
              'Estatísticas de Conquistas',
              [
                _buildStatisticRow('Total de Conquistas',
                    '${_achievementStats!.totalAchievements}'),
                _buildStatisticRow('XP de Conquistas',
                    '${_achievementStats!.totalXpFromAchievements}'),
                _buildStatisticRow('Conquistas Lendárias',
                    '${_achievementStats!.legendaryAchievements}'),
                _buildStatisticRow('Conquistas Épicas',
                    '${_achievementStats!.epicAchievements}'),
                _buildStatisticRow('Conquistas Raras',
                    '${_achievementStats!.rareAchievements}'),
                _buildStatisticRow('Conquistas Comuns',
                    '${_achievementStats!.commonAchievements}'),
              ],
            ),

          SizedBox(height: 3.h),

          // Profile Information
          _buildStatisticCard(
            'Informações do Perfil',
            [
              _buildStatisticRow('Nome Completo', userProfile.fullName),
              _buildStatisticRow('Email', userProfile.email),
              if (userProfile.city != null)
                _buildStatisticRow(
                    'Cidade', '${userProfile.city}, ${userProfile.state}'),
              if (userProfile.hasMotorcycleInfo)
                _buildStatisticRow(
                    'Motocicleta', userProfile.motorcycleFullName),
              _buildStatisticRow(
                  'Membro desde', _formatDate(userProfile.createdAt)),
              _buildStatisticRow(
                  'Última atividade', _formatDate(userProfile.lastActiveAt)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticCard(String title, List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
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
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildStatisticRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
