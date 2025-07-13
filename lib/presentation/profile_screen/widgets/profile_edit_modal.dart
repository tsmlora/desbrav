import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../widgets/image_picker_widget.dart';

class ProfileEditModal extends StatefulWidget {
  final VoidCallback onSaved;

  const ProfileEditModal({
    Key? key,
    required this.onSaved,
  }) : super(key: key);

  @override
  State<ProfileEditModal> createState() => _ProfileEditModalState();
}

class _ProfileEditModalState extends State<ProfileEditModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _motorcycleModelController;
  late TextEditingController _motorcycleYearController;
  late TextEditingController _motorcycleDisplacementController;

  MotorcycleBrand? _selectedMotorcycleBrand;
  ProfileVisibility _selectedVisibility = ProfileVisibility.public;
  bool _showLocation = true;
  bool _allowFriendRequests = true;
  bool _isLoading = false;
  File? _selectedImage;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProfile = authProvider.currentUserProfile;

    _fullNameController =
        TextEditingController(text: userProfile?.fullName ?? '');
    _firstNameController =
        TextEditingController(text: userProfile?.firstName ?? '');
    _lastNameController =
        TextEditingController(text: userProfile?.lastName ?? '');
    _phoneController = TextEditingController(text: userProfile?.phone ?? '');
    _cityController = TextEditingController(text: userProfile?.city ?? '');
    _stateController = TextEditingController(text: userProfile?.state ?? '');
    _motorcycleModelController =
        TextEditingController(text: userProfile?.motorcycleModel ?? '');
    _motorcycleYearController = TextEditingController(
        text: userProfile?.motorcycleYear?.toString() ?? '');
    _motorcycleDisplacementController = TextEditingController(
        text: userProfile?.motorcycleDisplacement?.toString() ?? '');

    _selectedMotorcycleBrand = userProfile?.motorcycleBrand;
    _selectedVisibility =
        userProfile?.profileVisibility ?? ProfileVisibility.public;
    _showLocation = userProfile?.showLocation ?? true;
    _allowFriendRequests = userProfile?.allowFriendRequests ?? true;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _motorcycleModelController.dispose();
    _motorcycleYearController.dispose();
    _motorcycleDisplacementController.dispose();
    super.dispose();
  }

  Future<void> _handleImageSelected(File imageFile) async {
    setState(() {
      _selectedImage = imageFile;
      _isUploadingImage = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.uploadAvatar(imageFile);

      if (mounted) {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Foto de perfil atualizada com sucesso!'),
            backgroundColor: AppTheme.successLight,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao enviar foto: $error'),
            backgroundColor: AppTheme.errorLight,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
          _selectedImage = null;
        });
      }
    }
  }

  Future<void> _handleRemoveImage() async {
    setState(() {
      _isUploadingImage = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.deleteAvatar();

      if (mounted) {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Foto de perfil removida com sucesso!'),
            backgroundColor: AppTheme.successLight,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao remover foto: $error'),
            backgroundColor: AppTheme.errorLight,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final updates = {
        'full_name': _fullNameController.text.trim(),
        'first_name': _firstNameController.text.trim().isNotEmpty
            ? _firstNameController.text.trim()
            : null,
        'last_name': _lastNameController.text.trim().isNotEmpty
            ? _lastNameController.text.trim()
            : null,
        'phone': _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
        'city': _cityController.text.trim().isNotEmpty
            ? _cityController.text.trim()
            : null,
        'state': _stateController.text.trim().isNotEmpty
            ? _stateController.text.trim()
            : null,
        'motorcycle_brand': _selectedMotorcycleBrand?.name,
        'motorcycle_model': _motorcycleModelController.text.trim().isNotEmpty
            ? _motorcycleModelController.text.trim()
            : null,
        'motorcycle_year': _motorcycleYearController.text.trim().isNotEmpty
            ? int.tryParse(_motorcycleYearController.text.trim())
            : null,
        'motorcycle_displacement':
            _motorcycleDisplacementController.text.trim().isNotEmpty
                ? int.tryParse(_motorcycleDisplacementController.text.trim())
                : null,
        'profile_visibility': _selectedVisibility.name,
        'show_location': _showLocation,
        'allow_friend_requests': _allowFriendRequests,
      };

      // Actually save the profile data to Supabase
      final success = await authProvider.updateUserProfile(updates);

      if (mounted) {
        if (success) {
          HapticFeedback.mediumImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Perfil atualizado com sucesso!'),
              backgroundColor: AppTheme.successLight,
            ),
          );
          widget.onSaved();
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Erro ao atualizar perfil: ${authProvider.errorMessage ?? 'Erro desconhecido'}'),
              backgroundColor: AppTheme.errorLight,
            ),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar perfil: $error'),
            backgroundColor: AppTheme.errorLight,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentProfile = authProvider.currentUserProfile;

    return Container(
      height: 90.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 12.w,
            height: 0.5.h,
            margin: EdgeInsets.symmetric(vertical: 2.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Editar Perfil',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          // Form
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(6.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Photo Section
                    _buildSectionTitle('Foto de Perfil'),
                    Stack(
                      children: [
                        ImagePickerWidget(
                          onImageSelected: _handleImageSelected,
                          onRemoveImage: currentProfile?.avatarUrl != null
                              ? _handleRemoveImage
                              : null,
                          showRemoveOption: currentProfile?.avatarUrl != null,
                          currentImageUrl: currentProfile?.avatarUrl,
                        ),
                        if (_isUploadingImage)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppTheme.lightTheme.colorScheme.primary,
                                      ),
                                    ),
                                    SizedBox(height: 1.h),
                                    Text(
                                      'Enviando foto...',
                                      style: AppTheme
                                          .lightTheme.textTheme.bodyMedium
                                          ?.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    SizedBox(height: 3.h),

                    // Personal Information
                    _buildSectionTitle('Informações Pessoais'),
                    _buildTextField(
                      controller: _fullNameController,
                      label: 'Nome Completo',
                      required: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nome completo é obrigatório';
                        }
                        return null;
                      },
                    ),
                    _buildTextField(
                      controller: _firstNameController,
                      label: 'Primeiro Nome',
                    ),
                    _buildTextField(
                      controller: _lastNameController,
                      label: 'Sobrenome',
                    ),
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Telefone',
                      keyboardType: TextInputType.phone,
                    ),

                    SizedBox(height: 3.h),

                    // Location
                    _buildSectionTitle('Localização'),
                    _buildTextField(
                      controller: _cityController,
                      label: 'Cidade',
                    ),
                    _buildTextField(
                      controller: _stateController,
                      label: 'Estado',
                    ),

                    SizedBox(height: 3.h),

                    // Motorcycle Information
                    _buildSectionTitle('Informações da Motocicleta'),
                    _buildMotorcycleBrandDropdown(),
                    _buildTextField(
                      controller: _motorcycleModelController,
                      label: 'Modelo da Motocicleta',
                    ),
                    _buildTextField(
                      controller: _motorcycleYearController,
                      label: 'Ano',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          final year = int.tryParse(value.trim());
                          if (year == null ||
                              year < 1980 ||
                              year > DateTime.now().year + 1) {
                            return 'Ano inválido';
                          }
                        }
                        return null;
                      },
                    ),
                    _buildTextField(
                      controller: _motorcycleDisplacementController,
                      label: 'Cilindradas (cc)',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          final displacement = int.tryParse(value.trim());
                          if (displacement == null ||
                              displacement < 50 ||
                              displacement > 3000) {
                            return 'Cilindradas inválidas';
                          }
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 3.h),

                    // Privacy Settings
                    _buildSectionTitle('Configurações de Privacidade'),
                    _buildVisibilityDropdown(),
                    _buildSwitchTile(
                      'Mostrar Localização',
                      'Permitir que outros usuários vejam sua localização',
                      _showLocation,
                      (value) => setState(() => _showLocation = value),
                    ),
                    _buildSwitchTile(
                      'Permitir Pedidos de Amizade',
                      'Outros usuários podem enviar pedidos de amizade',
                      _allowFriendRequests,
                      (value) => setState(() => _allowFriendRequests = value),
                    ),

                    SizedBox(height: 4.h),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (_isLoading || _isUploadingImage)
                            ? null
                            : _saveProfile,
                        child: (_isLoading || _isUploadingImage)
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Text('Salvar Alterações'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppTheme.lightTheme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Text(
        title,
        style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool required = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: AppTheme.lightTheme.colorScheme.surface,
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildMotorcycleBrandDropdown() {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: DropdownButtonFormField<MotorcycleBrand>(
        value: _selectedMotorcycleBrand,
        decoration: InputDecoration(
          labelText: 'Marca da Motocicleta',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: AppTheme.lightTheme.colorScheme.surface,
        ),
        items: MotorcycleBrand.values.map((brand) {
          return DropdownMenuItem(
            value: brand,
            child: Text(_getBrandDisplayName(brand)),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedMotorcycleBrand = value;
          });
        },
      ),
    );
  }

  Widget _buildVisibilityDropdown() {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: DropdownButtonFormField<ProfileVisibility>(
        value: _selectedVisibility,
        decoration: InputDecoration(
          labelText: 'Visibilidade do Perfil',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: AppTheme.lightTheme.colorScheme.surface,
        ),
        items: ProfileVisibility.values.map((visibility) {
          return DropdownMenuItem(
            value: visibility,
            child: Text(_getVisibilityDisplayName(visibility)),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedVisibility = value!;
          });
        },
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
        contentPadding: EdgeInsets.symmetric(horizontal: 2.w),
        tileColor: AppTheme.lightTheme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  String _getBrandDisplayName(MotorcycleBrand brand) {
    switch (brand) {
      case MotorcycleBrand.honda:
        return 'Honda';
      case MotorcycleBrand.yamaha:
        return 'Yamaha';
      case MotorcycleBrand.kawasaki:
        return 'Kawasaki';
      case MotorcycleBrand.suzuki:
        return 'Suzuki';
      case MotorcycleBrand.bmw:
        return 'BMW';
      case MotorcycleBrand.ducati:
        return 'Ducati';
      case MotorcycleBrand.harley_davidson:
        return 'Harley-Davidson';
      case MotorcycleBrand.triumph:
        return 'Triumph';
      case MotorcycleBrand.ktm:
        return 'KTM';
      case MotorcycleBrand.aprilia:
        return 'Aprilia';
      case MotorcycleBrand.other:
        return 'Outra';
    }
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
}
