import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/glass_widgets.dart';
import '../../widgets/app_logo.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Login failed. Check your email and password.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppLogo(size: 80),
                const SizedBox(height: 32),
                
                GlassCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: Text(
                            'Welcome Back',
                            style: TextStyle(
                              color: colors.textPrimary, 
                              fontSize: 24, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            'Sign in to your account',
                            style: TextStyle(color: colors.textSecondary, fontSize: 14),
                          ),
                        ),
                        const SizedBox(height: 32),

                        const AuthFieldLabel('EMAIL ADDRESS'),
                        const SizedBox(height: 8),
                        GlassTextField(
                          controller: _emailController,
                          hint: 'hello@design.com',
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return 'Email is required';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        const AuthFieldLabel('PASSWORD'),
                        const SizedBox(height: 8),
                        GlassTextField(
                          controller: _passwordController,
                          hint: '••••••',
                          obscureText: _obscurePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Password is required';
                            return null;
                          },
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: colors.textSecondary,
                              size: 20,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        const SizedBox(height: 24),

                        if (_errorMessage != null) AuthErrorText(_errorMessage!),

                        GlassGradientButton(
                          label: 'Sign In',
                          isLoading: _isLoading,
                          onTap: _handleLogin,
                        ),
                        const SizedBox(height: 20),

                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const SignupScreen()),
                              );
                            },
                            child: Text(
                              "Don't have an account? Sign up",
                              style: TextStyle(color: colors.textSecondary),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
