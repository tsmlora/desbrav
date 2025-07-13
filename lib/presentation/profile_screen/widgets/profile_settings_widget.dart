import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../core/models/user_profile.dart';

class ProfileSettingsWidget extends StatelessWidget {
  final UserProfile userProfile;
  final VoidCallback onLogout;

  const ProfileSettingsWidget({
    Key? key,
    required this.userProfile,
    required this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Privacy Settings
          _buildSettingsSection('Privacidade', [
            _buildSettingsItem(
                'Visibilidade do Perfil',
                _getVisibilityDisplayName(userProfile.profileVisibility),
                'visibility',
                () => _showVisibilityDialog(context)),
            _buildSettingsItem(
                'Mostrar Localização',
                userProfile.showLocation ? 'Ativado' : 'Desativado',
                'location_on',
                () => _showLocationDialog(context)),
            _buildSettingsItem(
                'Pedidos de Amizade',
                userProfile.allowFriendRequests ? 'Permitir' : 'Bloquear',
                'person_add',
                () => _showFriendRequestsDialog(context)),
          ]),

          SizedBox(height: 3.h),

          // Notifications Settings
          _buildSettingsSection('Notificações', [
            _buildSettingsItem('Notificações Push', 'Ativadas', 'notifications',
                () => _showNotificationSettings(context)),
            _buildSettingsItem('Notificações de Conquistas', 'Ativadas',
                'emoji_events', () => _showAchievementNotifications(context)),
            _buildSettingsItem('Notificações de Eventos', 'Ativadas', 'event',
                () => _showEventNotifications(context)),
          ]),

          SizedBox(height: 3.h),

          // App Settings
          _buildSettingsSection('Aplicativo', [
            _buildSettingsItem('Modo Escuro', 'Desativado', 'dark_mode',
                () => _showThemeDialog(context)),
            _buildSettingsItem('Idioma', 'Português (Brasil)', 'language',
                () => _showLanguageDialog(context)),
            _buildSettingsItem('Sobre o App', 'Versão 1.0.0', 'info',
                () => _showAboutDialog(context)),
          ]),

          SizedBox(height: 3.h),

          // Account Settings
          _buildSettingsSection('Conta', [
            _buildSettingsItem('Alterar Senha', 'Segurança', 'lock',
                () => _showChangePasswordDialog(context)),
            _buildSettingsItem('Exportar Dados', 'Download', 'download',
                () => _showExportDataDialog(context)),
            _buildSettingsItem('Excluir Conta', 'Permanente', 'delete',
                () => _showDeleteAccountDialog(context),
                isDestructive: true),
          ]),

          SizedBox(height: 3.h),

          // Logout Button
          Container(
              width: double.infinity,
              child: ElevatedButton.icon(
                  onPressed: onLogout,
                  icon: CustomIconWidget(
                      iconName: 'logout', color: Colors.white, size: 20),
                  label: Text('Sair da Conta'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.errorLight,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 2.h)))),
        ]));
  }

  Widget _buildSettingsSection(String title, List<Widget> items) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title,
          style: AppTheme.lightTheme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600)),
      SizedBox(height: 2.h),
      Container(
          decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: AppTheme.shadowLight,
                    blurRadius: 8,
                    offset: const Offset(0, 2)),
              ]),
          child: Column(children: items)),
    ]);
  }

  Widget _buildSettingsItem(
    String title,
    String subtitle,
    String iconName,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
        leading: Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
                color: isDestructive
                    ? AppTheme.errorLight.withValues(alpha: 0.1)
                    : AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8)),
            child: CustomIconWidget(
                iconName: iconName,
                color: isDestructive
                    ? AppTheme.errorLight
                    : AppTheme.lightTheme.colorScheme.primary,
                size: 20)),
        title: Text(title,
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: isDestructive ? AppTheme.errorLight : null)),
        subtitle: Text(subtitle,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant)),
        trailing: CustomIconWidget(
            iconName: 'chevron_right',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 16),
        onTap: onTap);
  }

  String _getVisibilityDisplayName(ProfileVisibility visibility) {
    switch (visibility) {
      case ProfileVisibility.public:
        return 'Público';
      case ProfileVisibility.friends:
        return 'Apenas Amigos';
      case ProfileVisibility.private:
        return 'Privado';
    }
  }

  void _showVisibilityDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: Text('Visibilidade do Perfil'),
                content: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('Escolha quem pode ver seu perfil:'),
                  // Add radio buttons for visibility options
                ]),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancelar')),
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Salvar')),
                ]));
  }

  void _showLocationDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: Text('Mostrar Localização'),
                content:
                    Text('Permitir que outros usuários vejam sua localização?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancelar')),
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Confirmar')),
                ]));
  }

  void _showFriendRequestsDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: Text('Pedidos de Amizade'),
                content: Text(
                    'Permitir que outros usuários enviem pedidos de amizade?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancelar')),
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Confirmar')),
                ]));
  }

  void _showNotificationSettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Configurações de notificação em desenvolvimento')));
  }

  void _showAchievementNotifications(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Configurações de conquistas em desenvolvimento')));
  }

  void _showEventNotifications(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Configurações de eventos em desenvolvimento')));
  }

  void _showThemeDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Modo escuro em desenvolvimento')));
  }

  void _showLanguageDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Seleção de idioma em desenvolvimento')));
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: Text('Sobre o Desbrav'),
                content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Versão: 1.0.0'),
                      SizedBox(height: 1.h),
                      Text(
                          'Desenvolvido para motociclistas apaixonados por aventuras.'),
                      SizedBox(height: 1.h),
                      Text('© 2025 Desbrav Team'),
                    ]),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Fechar')),
                ]));
  }

  void _showChangePasswordDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Alteração de senha em desenvolvimento')));
  }

  void _showExportDataDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exportação de dados em desenvolvimento')));
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: Text('Excluir Conta'),
                content: Text(
                    'Esta ação é irreversível. Tem certeza que deseja excluir sua conta permanentemente?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancelar')),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content:
                                Text('Exclusão de conta em desenvolvimento'),
                            backgroundColor: AppTheme.errorLight));
                      },
                      child: Text('Excluir',
                          style: TextStyle(color: AppTheme.errorLight))),
                ]));
  }
}
