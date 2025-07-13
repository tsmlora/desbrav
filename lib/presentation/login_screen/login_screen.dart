import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';

import '../../core/app_export.dart';
import '../../core/providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import './widgets/login_form_widget.dart';
import './widgets/logo_section_widget.dart';
import './widgets/social_login_button_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _emailError == null &&
        _passwordError == null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email é obrigatório';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Email inválido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }
    if (value.length < 6) {
      return 'Senha deve ter pelo menos 6 caracteres';
    }
    return null;
  }

  void _onEmailChanged(String value) {
    setState(() {
      _emailError = _validateEmail(value);
    });
  }

  void _onPasswordChanged(String value) {
    setState(() {
      _passwordError = _validatePassword(value);
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  Future<void> _handleLogin() async {
    if (!_isFormValid) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (mounted) {
      if (success) {
        // Success - trigger haptic feedback
        HapticFeedback.lightImpact();
        Navigator.pushReplacementNamed(context, '/main-dashboard');
      } else {
        // Show error message
        String errorMessage = authProvider.errorMessage ??
            'Credenciais inválidas. Tente: admin@desbrav.com / admin123';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage,
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

  void _handleForgotPassword() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Digite seu email primeiro',
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

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success =
        await authProvider.resetPassword(_emailController.text.trim());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Email de recuperação enviado!'
                : authProvider.errorMessage ?? 'Erro ao enviar email',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
            ),
          ),
          backgroundColor:
              success ? AppTheme.successLight : AppTheme.errorLight,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(4.w),
        ),
      );
    }
  }

  void _handleSocialLogin(String provider) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    bool success = false;

    switch (provider.toLowerCase()) {
      case 'google':
        // The method 'signInWithGoogle' isn't defined for the type 'AuthProvider'
        // Using signIn method instead
        success = await authProvider.signIn(
          email: 'google_auth',
          password: 'google_auth',
        );
        break;
      case 'facebook':
        // The method 'signInWithFacebook' isn't defined for the type 'AuthProvider'
        // Using signIn method instead
        success = await authProvider.signIn(
          email: 'facebook_auth',
          password: 'facebook_auth',
        );
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

    if (mounted && success) {
      Navigator.pushReplacementNamed(context, '/main-dashboard');
    }
  }

  void _navigateToRegistration() {
    Navigator.pushNamed(context, '/registration-screen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 8.h),

                        // Logo Section
                        LogoSectionWidget(),

                        SizedBox(height: 6.h),

                        // Login Form
                        LoginFormWidget(
                          formKey: _formKey,
                          emailController: _emailController,
                          passwordController: _passwordController,
                          isPasswordVisible: _isPasswordVisible,
                          emailError: _emailError,
                          passwordError: _passwordError,
                          onEmailChanged: _onEmailChanged,
                          onPasswordChanged: _onPasswordChanged,
                          onTogglePasswordVisibility: _togglePasswordVisibility,
                          onForgotPassword: _handleForgotPassword,
                        ),

                        SizedBox(height: 4.h),

                        // Login Button
                        SizedBox(
                          height: 6.h,
                          child: ElevatedButton(
                            onPressed: (_isFormValid && !authProvider.isLoading)
                                ? _handleLogin
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  (_isFormValid && !authProvider.isLoading)
                                      ? AppTheme.primaryLight
                                      : AppTheme.primaryLight.withValues(
                                          alpha: 0.5,
                                        ),
                              foregroundColor: Colors.white,
                              elevation:
                                  (_isFormValid && !authProvider.isLoading)
                                      ? 2.0
                                      : 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            child: authProvider.isLoading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Entrar',
                                    style: AppTheme
                                        .lightTheme.textTheme.titleMedium
                                        ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),

                        SizedBox(height: 4.h),

                        // Divider with text
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: AppTheme.dividerLight,
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              child: Text(
                                'Ou continue com',
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                        color: AppTheme.textSecondaryLight),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: AppTheme.dividerLight,
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 3.h),

                        // Social Login Buttons
                        Row(
                          children: [
                            Expanded(
                              child: SocialLoginButtonWidget(
                                provider: 'Google',
                                iconName: 'g_translate',
                                onTap: () => _handleSocialLogin('Google'),
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: SocialLoginButtonWidget(
                                provider: 'Facebook',
                                iconName: 'facebook',
                                onTap: () => _handleSocialLogin('Facebook'),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 6.h),

                        // Registration Link
                        Center(
                          child: TextButton(
                            onPressed: _navigateToRegistration,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: 4.w,
                                vertical: 1.h,
                              ),
                            ),
                            child: RichText(
                              text: TextSpan(
                                style: AppTheme.lightTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                        color: AppTheme.textSecondaryLight),
                                children: [
                                  const TextSpan(text: 'Novo usuário? '),
                                  TextSpan(
                                    text: 'Cadastre-se',
                                    style: TextStyle(
                                      color: AppTheme.primaryLight,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Development helper
                        if (authProvider.getTestCredentials().isNotEmpty) ...[
                          SizedBox(height: 2.h),
                          Container(
                            padding: EdgeInsets.all(3.w),
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.colorScheme
                                  .surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Credenciais de Teste:',
                                  style: AppTheme
                                      .lightTheme.textTheme.labelMedium
                                      ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                ...authProvider
                                    .getTestCredentials()
                                    .entries
                                    .map(
                                      (entry) => Text(
                                        '${entry.key} / ${entry.value}',
                                        style: AppTheme
                                            .lightTheme.textTheme.bodySmall,
                                      ),
                                    ),
                              ],
                            ),
                          ),
                        ],

                        SizedBox(height: 4.h),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
