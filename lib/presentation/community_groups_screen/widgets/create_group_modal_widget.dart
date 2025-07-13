import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/community_service.dart';

class CreateGroupModalWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onGroupCreated;

  const CreateGroupModalWidget({
    Key? key,
    required this.onGroupCreated,
  }) : super(key: key);

  @override
  State<CreateGroupModalWidget> createState() => _CreateGroupModalWidgetState();
}

class _CreateGroupModalWidgetState extends State<CreateGroupModalWidget>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  GroupCategory _selectedCategory = GroupCategory.general;
  GroupVisibility _selectedVisibility = GroupVisibility.public;
  bool _isLoading = false;

  final CommunityService _communityService = CommunityService();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateGroup() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      _showErrorSnackBar('Você precisa estar logado para criar um grupo');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      HapticFeedback.mediumImpact();

      final group = await _communityService.createGroup(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        category: _selectedCategory,
        visibility: _selectedVisibility,
        city: _cityController.text.trim().isEmpty
            ? null
            : _cityController.text.trim(),
        state: _stateController.text.trim().isEmpty
            ? null
            : _stateController.text.trim(),
      );

      widget.onGroupCreated({
        'id': group.id,
        'name': group.name,
        'description': group.description ?? '',
        'category': group.categoryDisplayName,
        'memberCount': 1,
        'isJoined': true,
      });

      _showSuccessSnackBar('Grupo "${group.name}" criado com sucesso!');

      await _animationController.reverse();
      Navigator.of(context).pop();
    } catch (error) {
      _showErrorSnackBar('Erro ao criar grupo: ${error.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorLight,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successLight,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
              0, MediaQuery.of(context).size.height * _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: _buildModal(),
          ),
        );
      },
    );
  }

  Widget _buildModal() {
    return Container(
      height: 85.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildForm(),
          ),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.dividerLight,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Criar Novo Grupo',
                      style:
                          AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryLight,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'Conecte-se com motociclistas da sua região',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textMediumEmphasisLight,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  await _animationController.reverse();
                  Navigator.of(context).pop();
                },
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color:
                        AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              controller: _nameController,
              label: 'Nome do Grupo *',
              hint: 'Ex: Motociclistas de São Paulo',
              icon: 'groups',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nome do grupo é obrigatório';
                }
                if (value.trim().length < 3) {
                  return 'Nome deve ter pelo menos 3 caracteres';
                }
                return null;
              },
            ),
            SizedBox(height: 3.h),
            _buildTextField(
              controller: _descriptionController,
              label: 'Descrição',
              hint: 'Descreva o propósito e objetivos do grupo',
              icon: 'description',
              maxLines: 3,
            ),
            SizedBox(height: 3.h),
            _buildCategorySelector(),
            SizedBox(height: 3.h),
            _buildVisibilitySelector(),
            SizedBox(height: 3.h),
            Text(
              'Localização (Opcional)',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _cityController,
                    label: 'Cidade',
                    hint: 'São Paulo',
                    icon: 'location_city',
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: _buildTextField(
                    controller: _stateController,
                    label: 'Estado',
                    hint: 'SP',
                    icon: 'map',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: icon,
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppTheme.dividerLight,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppTheme.dividerLight,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppTheme.primaryLight,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categoria da Motocicleta',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.dividerLight, width: 1.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<GroupCategory>(
              value: _selectedCategory,
              isExpanded: true,
              icon: CustomIconWidget(
                iconName: 'keyboard_arrow_down',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 24,
              ),
              onChanged: (GroupCategory? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                }
              },
              items: GroupCategory.values.map((category) {
                return DropdownMenuItem<GroupCategory>(
                  value: category,
                  child: Text(_getCategoryDisplayName(category)),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVisibilitySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Privacidade do Grupo',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        ...GroupVisibility.values.map((visibility) {
          return RadioListTile<GroupVisibility>(
            title: Text(_getVisibilityDisplayName(visibility)),
            subtitle: Text(_getVisibilityDescription(visibility)),
            value: visibility,
            groupValue: _selectedVisibility,
            onChanged: (GroupVisibility? value) {
              if (value != null) {
                setState(() {
                  _selectedVisibility = value;
                });
              }
            },
            activeColor: AppTheme.primaryLight,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.dividerLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      await _animationController.reverse();
                      Navigator.of(context).pop();
                    },
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text('Cancelar'),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleCreateGroup,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: AppTheme.primaryLight,
              ),
              child: _isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Criar Grupo',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryDisplayName(GroupCategory category) {
    switch (category) {
      case GroupCategory.sport:
        return 'Esportivas';
      case GroupCategory.touring:
        return 'Touring';
      case GroupCategory.adventure:
        return 'Adventure';
      case GroupCategory.cruiser:
        return 'Cruiser';
      case GroupCategory.scooter:
        return 'Scooter';
      case GroupCategory.vintage:
        return 'Clássicas';
      case GroupCategory.general:
        return 'Geral';
    }
  }

  String _getVisibilityDisplayName(GroupVisibility visibility) {
    switch (visibility) {
      case GroupVisibility.public:
        return 'Público';
      case GroupVisibility.private:
        return 'Privado';
      case GroupVisibility.inviteOnly:
        return 'Apenas por Convite';
    }
  }

  String _getVisibilityDescription(GroupVisibility visibility) {
    switch (visibility) {
      case GroupVisibility.public:
        return 'Qualquer pessoa pode encontrar e participar';
      case GroupVisibility.private:
        return 'Apenas membros podem ver o conteúdo';
      case GroupVisibility.inviteOnly:
        return 'Novos membros precisam ser convidados';
    }
  }
}
