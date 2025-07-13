import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_export.dart';
import '../../core/models/user_profile.dart';
import '../../core/providers/auth_provider.dart';
import './widgets/motorcycle_dropdown_widget.dart';
import './widgets/password_strength_widget.dart';
import './widgets/social_registration_widget.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Form controllers
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _modeloController = TextEditingController();
  final _anoController = TextEditingController();
  final _cilindradaController = TextEditingController();

  // Form state
  String? _selectedMarca;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptTerms = false;
  bool _showLocation = true;
  bool _allowFriendRequests = true;

  // Validation state
  Map<String, bool> _fieldValidation = {
    'nome': false,
    'email': false,
    'senha': false,
    'confirmarSenha': false,
    'phone': false,
    'city': false,
    'state': false,
    'marca': false,
    'modelo': false,
    'ano': false,
    'cilindrada': false,
  };

  // Mock motorcycle brands data
  final List<Map<String, dynamic>> _motorcycleBrands = [
    {
      'id': 1,
      'name': 'Honda',
      'models': [
        'CB 600F Hornet',
        'CBR 1000RR',
        'CG 160 Titan',
        'PCX 150',
        'CB 650R',
      ],
    },
    {
      'id': 2,
      'name': 'Yamaha',
      'models': ['MT-07', 'YZF-R3', 'Factor 150', 'Crosser 150', 'MT-09'],
    },
    {
      'id': 3,
      'name': 'Kawasaki',
      'models': ['Ninja 400', 'Z650', 'Versys 650', 'Ninja ZX-10R', 'Z900'],
    },
    {
      'id': 4,
      'name': 'Suzuki',
      'models': [
        'GSX-R750',
        'V-Strom 650',
        'Hayabusa',
        'GSX-S750',
        'Intruder 150',
      ],
    },
    {
      'id': 5,
      'name': 'BMW',
      'models': ['R 1250 GS', 'S 1000 RR', 'F 850 GS', 'R nineT', 'G 310 R'],
    },
    {
      'id': 6,
      'name': 'Ducati',
      'models': [
        'Panigale V4',
        'Monster 821',
        'Multistrada 1260',
        'Scrambler Icon',
        'Diavel 1260',
      ],
    },
    {
      'id': 7,
      'name': 'Harley-Davidson',
      'models': [
        'Iron 883',
        'Street 750',
        'Fat Boy',
        'Road King',
        'Sportster S',
      ],
    },
  ];

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _modeloController.dispose();
    _anoController.dispose();
    _cilindradaController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _fieldValidation.values.every((isValid) => isValid) && _acceptTerms;
  }

  void _validateField(String field, String value) {
    setState(() {
      switch (field) {
        case 'nome':
          _fieldValidation['nome'] =
              value.trim().length >= 3 && value.trim().split(' ').length >= 2;
          break;
        case 'email':
          _fieldValidation['email'] = RegExp(
            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
          ).hasMatch(value.trim());
          break;
        case 'senha':
          _fieldValidation['senha'] = value.length >= 8 &&
              RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value);
          break;
        case 'confirmarSenha':
          _fieldValidation['confirmarSenha'] =
              value == _senhaController.text && value.isNotEmpty;
          break;
        case 'phone':
          _fieldValidation['phone'] = value.trim().isEmpty ||
              RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(value.trim());
          break;
        case 'city':
          _fieldValidation['city'] = value.trim().length >= 2;
          break;
        case 'state':
          _fieldValidation['state'] = value.trim().length >= 2;
          break;
        case 'marca':
          _fieldValidation['marca'] = _selectedMarca != null;
          break;
        case 'modelo':
          _fieldValidation['modelo'] = value.trim().isNotEmpty;
          break;
        case 'ano':
          final ano = int.tryParse(value);
          _fieldValidation['ano'] =
              ano != null && ano >= 1980 && ano <= DateTime.now().year + 1;
          break;
        case 'cilindrada':
          final cilindrada = int.tryParse(value);
          _fieldValidation['cilindrada'] =
              cilindrada != null && cilindrada >= 50 && cilindrada <= 2000;
          break;
      }
    });
  }

  void _handleContinue() async {
    if (!_isFormValid) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Extract first and last name
    final nameParts = _nomeController.text.trim().split(' ');
    final firstName = nameParts.first;
    final lastName = nameParts.length > 1 ? nameParts.skip(1).join(' ') : '';

    final success = await authProvider.signUp(
      email: _emailController.text.trim(),
      password: _senhaController.text,
      fullName: _nomeController.text.trim(),
      firstName: firstName,
      lastName: lastName,
      role: UserRole.rider,
    );

    if (mounted) {
      if (success) {
        // Update profile with complete information including new fields
        await authProvider.updateUserProfile({
          'phone': _phoneController.text.trim().isNotEmpty
              ? _phoneController.text.trim()
              : null,
          'city': _cityController.text.trim().isNotEmpty
              ? _cityController.text.trim()
              : null,
          'state': _stateController.text.trim().isNotEmpty
              ? _stateController.text.trim()
              : null,
          'motorcycle_brand': _getMotorcycleBrandEnum(_selectedMarca!),
          'motorcycle_model': _modeloController.text.trim(),
          'motorcycle_year': int.parse(_anoController.text),
          'motorcycle_displacement': int.parse(_cilindradaController.text),
          'show_location': _showLocation,
          'allow_friend_requests': _allowFriendRequests,
          'profile_visibility': 'public',
        });

        // Navigate to dashboard
        Navigator.pushReplacementNamed(context, '/main-dashboard');
      } else {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authProvider.errorMessage ?? 'Erro ao criar conta',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
              ),
            ),
            backgroundColor: AppTheme.errorLight,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(4.w),
          ),
        );
      }
    }
  }

  String _getMotorcycleBrandEnum(String brandName) {
    switch (brandName.toLowerCase()) {
      case 'honda':
        return 'honda';
      case 'yamaha':
        return 'yamaha';
      case 'kawasaki':
        return 'kawasaki';
      case 'suzuki':
        return 'suzuki';
      case 'bmw':
        return 'bmw';
      case 'ducati':
        return 'ducati';
      case 'harley-davidson':
        return 'harley_davidson';
      case 'triumph':
        return 'triumph';
      case 'ktm':
        return 'ktm';
      case 'aprilia':
        return 'aprilia';
      default:
        return 'other';
    }
  }

  void _handleSocialRegistration(String provider) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    OAuthProvider? oauthProvider;
    switch (provider.toLowerCase()) {
      case 'google':
        oauthProvider = OAuthProvider.google;
        break;
      case 'facebook':
        oauthProvider = OAuthProvider.facebook;
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Login com $provider não suportado',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
              ),
            ),
            backgroundColor: AppTheme.warningLight,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(4.w),
          ),
        );
        return;
    }

    final success = await authProvider.signInWithOAuth(oauthProvider);

    if (mounted && success) {
      Navigator.pushReplacementNamed(context, '/main-dashboard');
    }
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Termos de Uso',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        content: SingleChildScrollView(
          child: Text(
            'Ao usar o DESBRAV, você concorda com nossos termos de uso e política de privacidade. Seus dados de localização serão utilizados apenas para funcionalidades do aplicativo.',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _handleBackNavigation() {
    if (_nomeController.text.isNotEmpty ||
        _emailController.text.isNotEmpty ||
        _senhaController.text.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Descartar alterações?',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Text(
            'Você tem dados não salvos. Deseja realmente sair?',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/login-screen');
              },
              child: Text(
                'Sair',
                style: TextStyle(color: AppTheme.errorLight),
              ),
            ),
          ],
        ),
      );
    } else {
      Navigator.pushNamed(context, '/login-screen');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return Column(
              children: [
                // Header with back button and progress
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
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
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _handleBackNavigation,
                            child: Container(
                              padding: EdgeInsets.all(2.w),
                              decoration: BoxDecoration(
                                color: AppTheme.lightTheme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppTheme.dividerLight,
                                  width: 1,
                                ),
                              ),
                              child: CustomIconWidget(
                                iconName: 'arrow_back',
                                color:
                                    AppTheme.lightTheme.colorScheme.onSurface,
                                size: 20,
                              ),
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              'Criar Conta',
                              style: AppTheme.lightTheme.textTheme.titleLarge,
                            ),
                          ),
                          Text(
                            'Passo 1 de 2',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                                    color: AppTheme.textMediumEmphasisLight),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      // Progress indicator
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryLight,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppTheme.dividerLight,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Scrollable form content
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      setState(() {
                        _nomeController.clear();
                        _emailController.clear();
                        _senhaController.clear();
                        _confirmarSenhaController.clear();
                        _phoneController.clear();
                        _cityController.clear();
                        _stateController.clear();
                        _modeloController.clear();
                        _anoController.clear();
                        _cilindradaController.clear();
                        _selectedMarca = null;
                        _acceptTerms = false;
                        _fieldValidation = Map.fromIterable(
                          _fieldValidation.keys,
                          value: (_) => false,
                        );
                      });
                    },
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: EdgeInsets.all(4.w),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Welcome text
                            Text(
                              'Bem-vindo ao DESBRAV',
                              style: AppTheme.lightTheme.textTheme.headlineSmall
                                  ?.copyWith(
                                color: AppTheme.primaryLight,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'Crie sua conta e comece sua jornada de aventuras motociclísticas',
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: AppTheme.textMediumEmphasisLight,
                              ),
                            ),
                            SizedBox(height: 4.h),

                            // Personal Information Section
                            Text(
                              'Informações Pessoais',
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 2.h),

                            // Nome completo field
                            _buildTextFormField(
                              controller: _nomeController,
                              label: 'Nome Completo',
                              hint: 'Digite seu nome completo',
                              keyboardType: TextInputType.name,
                              textCapitalization: TextCapitalization.words,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Nome é obrigatório';
                                }
                                if (value.trim().length < 3) {
                                  return 'Nome deve ter pelo menos 3 caracteres';
                                }
                                if (value.trim().split(' ').length < 2) {
                                  return 'Digite nome e sobrenome';
                                }
                                return null;
                              },
                              onChanged: (value) =>
                                  _validateField('nome', value),
                              isValid: _fieldValidation['nome'] ?? false,
                            ),
                            SizedBox(height: 2.h),

                            // Email field
                            _buildTextFormField(
                              controller: _emailController,
                              label: 'Email',
                              hint: 'Digite seu email',
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Email é obrigatório';
                                }
                                if (!RegExp(
                                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                                ).hasMatch(value.trim())) {
                                  return 'Digite um email válido';
                                }
                                return null;
                              },
                              onChanged: (value) =>
                                  _validateField('email', value),
                              isValid: _fieldValidation['email'] ?? false,
                            ),
                            SizedBox(height: 2.h),

                            // Password field
                            _buildTextFormField(
                              controller: _senhaController,
                              label: 'Senha',
                              hint: 'Digite sua senha',
                              obscureText: !_isPasswordVisible,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Senha é obrigatória';
                                }
                                if (value.length < 8) {
                                  return 'Senha deve ter pelo menos 8 caracteres';
                                }
                                if (!RegExp(
                                  r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)',
                                ).hasMatch(value)) {
                                  return 'Senha deve conter maiúscula, minúscula e número';
                                }
                                return null;
                              },
                              onChanged: (value) =>
                                  _validateField('senha', value),
                              isValid: _fieldValidation['senha'] ?? false,
                              suffixIcon: GestureDetector(
                                onTap: () => setState(
                                  () =>
                                      _isPasswordVisible = !_isPasswordVisible,
                                ),
                                child: CustomIconWidget(
                                  iconName: _isPasswordVisible
                                      ? 'visibility_off'
                                      : 'visibility',
                                  color: AppTheme.textSecondaryLight,
                                  size: 20,
                                ),
                              ),
                            ),
                            SizedBox(height: 1.h),

                            // Password strength indicator
                            PasswordStrengthWidget(
                                password: _senhaController.text),
                            SizedBox(height: 2.h),

                            // Confirm password field
                            _buildTextFormField(
                              controller: _confirmarSenhaController,
                              label: 'Confirmar Senha',
                              hint: 'Digite sua senha novamente',
                              obscureText: !_isConfirmPasswordVisible,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Confirmação de senha é obrigatória';
                                }
                                if (value != _senhaController.text) {
                                  return 'Senhas não coincidem';
                                }
                                return null;
                              },
                              onChanged: (value) =>
                                  _validateField('confirmarSenha', value),
                              isValid:
                                  _fieldValidation['confirmarSenha'] ?? false,
                              suffixIcon: GestureDetector(
                                onTap: () => setState(
                                  () => _isConfirmPasswordVisible =
                                      !_isConfirmPasswordVisible,
                                ),
                                child: CustomIconWidget(
                                  iconName: _isConfirmPasswordVisible
                                      ? 'visibility_off'
                                      : 'visibility',
                                  color: AppTheme.textSecondaryLight,
                                  size: 20,
                                ),
                              ),
                            ),
                            SizedBox(height: 4.h),

                            // Phone field
                            _buildTextFormField(
                              controller: _phoneController,
                              label: 'Telefone',
                              hint: 'Ex: (11) 99999-9999',
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value != null && value.trim().isNotEmpty) {
                                  if (!RegExp(r'^\+?[1-9]\d{1,14}$')
                                      .hasMatch(value.trim())) {
                                    return 'Digite um telefone válido';
                                  }
                                }
                                return null;
                              },
                              onChanged: (value) =>
                                  _validateField('phone', value),
                              isValid: _fieldValidation['phone'] ?? false,
                            ),
                            SizedBox(height: 4.h),

                            // Location Section
                            Text(
                              'Localização',
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 2.h),

                            // City field
                            _buildTextFormField(
                              controller: _cityController,
                              label: 'Cidade',
                              hint: 'Ex: São Paulo',
                              textCapitalization: TextCapitalization.words,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Cidade é obrigatória';
                                }
                                if (value.trim().length < 2) {
                                  return 'Cidade deve ter pelo menos 2 caracteres';
                                }
                                return null;
                              },
                              onChanged: (value) =>
                                  _validateField('city', value),
                              isValid: _fieldValidation['city'] ?? false,
                            ),
                            SizedBox(height: 2.h),

                            // State field
                            _buildTextFormField(
                              controller: _stateController,
                              label: 'Estado',
                              hint: 'Ex: SP',
                              textCapitalization: TextCapitalization.characters,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Estado é obrigatório';
                                }
                                if (value.trim().length < 2) {
                                  return 'Estado deve ter pelo menos 2 caracteres';
                                }
                                return null;
                              },
                              onChanged: (value) =>
                                  _validateField('state', value),
                              isValid: _fieldValidation['state'] ?? false,
                            ),
                            SizedBox(height: 4.h),

                            // Privacy Settings Section
                            Text(
                              'Configurações de Privacidade',
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 2.h),

                            // Show location toggle
                            Container(
                              decoration: BoxDecoration(
                                color: AppTheme.lightTheme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.dividerLight,
                                  width: 1,
                                ),
                              ),
                              child: SwitchListTile(
                                title: Text(
                                  'Mostrar Localização',
                                  style: AppTheme
                                      .lightTheme.textTheme.bodyMedium
                                      ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Text(
                                  'Permitir que outros usuários vejam sua localização',
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                    color: AppTheme.textMediumEmphasisLight,
                                  ),
                                ),
                                value: _showLocation,
                                onChanged: (value) =>
                                    setState(() => _showLocation = value),
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 4.w),
                              ),
                            ),
                            SizedBox(height: 2.h),

                            // Allow friend requests toggle
                            Container(
                              decoration: BoxDecoration(
                                color: AppTheme.lightTheme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.dividerLight,
                                  width: 1,
                                ),
                              ),
                              child: SwitchListTile(
                                title: Text(
                                  'Permitir Pedidos de Amizade',
                                  style: AppTheme
                                      .lightTheme.textTheme.bodyMedium
                                      ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Text(
                                  'Outros usuários podem enviar pedidos de amizade',
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                    color: AppTheme.textMediumEmphasisLight,
                                  ),
                                ),
                                value: _allowFriendRequests,
                                onChanged: (value) => setState(
                                    () => _allowFriendRequests = value),
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 4.w),
                              ),
                            ),
                            SizedBox(height: 4.h),

                            // Motorcycle Information Section
                            Text(
                              'Informações da Motocicleta',
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 2.h),

                            // Motorcycle brand dropdown
                            MotorcycleDropdownWidget(
                              brands: _motorcycleBrands,
                              selectedBrand: _selectedMarca,
                              onBrandChanged: (brand) {
                                setState(() {
                                  _selectedMarca = brand;
                                  _modeloController.clear();
                                  _fieldValidation['modelo'] = false;
                                });
                                _validateField('marca', brand ?? '');
                              },
                              modelController: _modeloController,
                              onModelChanged: (value) =>
                                  _validateField('modelo', value),
                              isValid: _fieldValidation['marca'] ?? false,
                            ),
                            SizedBox(height: 2.h),

                            // Year and engine displacement row
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextFormField(
                                    controller: _anoController,
                                    label: 'Ano',
                                    hint: 'Ex: 2020',
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(4),
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Ano é obrigatório';
                                      }
                                      final ano = int.tryParse(value);
                                      if (ano == null ||
                                          ano < 1980 ||
                                          ano > DateTime.now().year + 1) {
                                        return 'Ano inválido';
                                      }
                                      return null;
                                    },
                                    onChanged: (value) =>
                                        _validateField('ano', value),
                                    isValid: _fieldValidation['ano'] ?? false,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: _buildTextFormField(
                                    controller: _cilindradaController,
                                    label: 'Cilindrada (cc)',
                                    hint: 'Ex: 600',
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(4),
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Cilindrada é obrigatória';
                                      }
                                      final cilindrada = int.tryParse(value);
                                      if (cilindrada == null ||
                                          cilindrada < 50 ||
                                          cilindrada > 2000) {
                                        return 'Cilindrada inválida';
                                      }
                                      return null;
                                    },
                                    onChanged: (value) =>
                                        _validateField('cilindrada', value),
                                    isValid:
                                        _fieldValidation['cilindrada'] ?? false,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4.h),

                            // Terms and conditions
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Checkbox(
                                  value: _acceptTerms,
                                  onChanged: (value) => setState(
                                    () => _acceptTerms = value ?? false,
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(
                                      () => _acceptTerms = !_acceptTerms,
                                    ),
                                    child: RichText(
                                      text: TextSpan(
                                        style: AppTheme
                                            .lightTheme.textTheme.bodySmall,
                                        children: [
                                          const TextSpan(text: 'Eu aceito os '),
                                          WidgetSpan(
                                            child: GestureDetector(
                                              onTap: _showTermsDialog,
                                              child: Text(
                                                'Termos de Uso',
                                                style: AppTheme.lightTheme
                                                    .textTheme.bodySmall
                                                    ?.copyWith(
                                                  color: AppTheme.primaryLight,
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const TextSpan(
                                            text: ' e Política de Privacidade',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4.h),

                            // Continue button
                            SizedBox(
                              width: double.infinity,
                              height: 6.h,
                              child: ElevatedButton(
                                onPressed:
                                    (_isFormValid && !authProvider.isLoading)
                                        ? _handleContinue
                                        : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isFormValid
                                      ? AppTheme.primaryLight
                                      : AppTheme.dividerLight,
                                  foregroundColor: Colors.white,
                                ),
                                child: authProvider.isLoading
                                    ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    : Text(
                                        'Continuar',
                                        style: AppTheme
                                            .lightTheme.textTheme.labelLarge
                                            ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                            SizedBox(height: 3.h),

                            // Divider
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(color: AppTheme.dividerLight),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 4.w),
                                  child: Text(
                                    'ou',
                                    style: AppTheme
                                        .lightTheme.textTheme.bodySmall
                                        ?.copyWith(
                                      color: AppTheme.textMediumEmphasisLight,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(color: AppTheme.dividerLight),
                                ),
                              ],
                            ),
                            SizedBox(height: 3.h),

                            // Social registration options
                            SocialRegistrationWidget(
                              onSocialLogin: _handleSocialRegistration,
                              isLoading: authProvider.isLoading,
                            ),
                            SizedBox(height: 4.h),

                            // Login link
                            Center(
                              child: RichText(
                                text: TextSpan(
                                  style:
                                      AppTheme.lightTheme.textTheme.bodyMedium,
                                  children: [
                                    const TextSpan(text: 'Já tem uma conta? '),
                                    WidgetSpan(
                                      child: GestureDetector(
                                        onTap: () => Navigator.pushNamed(
                                          context,
                                          '/login-screen',
                                        ),
                                        child: Text(
                                          'Fazer Login',
                                          style: AppTheme
                                              .lightTheme.textTheme.bodyMedium
                                              ?.copyWith(
                                            color: AppTheme.primaryLight,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 2.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    TextCapitalization? textCapitalization,
    bool obscureText = false,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    bool isValid = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization ?? TextCapitalization.none,
          obscureText: obscureText,
          inputFormatters: inputFormatters,
          validator: validator,
          onChanged: onChanged,
          enabled: true,
          readOnly: false,
          autocorrect: keyboardType != TextInputType.emailAddress,
          enableSuggestions: keyboardType != TextInputType.visiblePassword,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            suffixIcon: isValid
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (suffixIcon != null) suffixIcon,
                      CustomIconWidget(
                        iconName: 'check_circle',
                        color: AppTheme.successLight,
                        size: 20,
                      ),
                      SizedBox(width: 3.w),
                    ],
                  )
                : suffixIcon != null
                    ? Padding(
                        padding: EdgeInsets.only(right: 3.w),
                        child: suffixIcon,
                      )
                    : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isValid ? AppTheme.successLight : AppTheme.dividerLight,
                width: isValid ? 2 : 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isValid ? AppTheme.successLight : AppTheme.dividerLight,
                width: isValid ? 2 : 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isValid ? AppTheme.successLight : AppTheme.primaryLight,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
