import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/glass_widgets.dart';
import 'login_screen.dart';
import '../../models/company_model.dart';
import '../../services/company_service.dart';
import '../../main.dart';


class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _authService = AuthService();
  final _companyService = CompanyService();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  List<CompanyModel> _companies = [];
  CompanyModel? _selectedCompany;
  bool _isLoadingCompanies = true;

  String _selectedRole = 'passenger';
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCompanies();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadCompanies() async {
    try {
      final companies = await _companyService.getAllCompanies();
      setState(() {
        _companies = companies;
        _isLoadingCompanies = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCompanies = false;
        _errorMessage = 'Could not load companies: $e';
      });
    }
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRole == 'conductor' && _selectedCompany == null) {
      setState(() => _errorMessage = 'Please select a company.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        fullName: _nameController.text.trim(),
        role: _selectedRole,
        companyId: _selectedRole == 'conductor' ? _selectedCompany!.id : null,
      );


      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AuthGate()),
              (route) => false,
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
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
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: AuthBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: GlassCard(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Center(
                      child: Text(
                        'Create Account',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: Text(
                        'Sign up to get started',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    const AuthFieldLabel('FULL NAME'),
                    const SizedBox(height: 8),
                    GlassTextField(
                      controller: _nameController,
                      hint: 'Jane Doe',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Full name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    const AuthFieldLabel('EMAIL ADDRESS'),
                    const SizedBox(height: 8),
                    GlassTextField(
                      controller: _emailController,
                      hint: 'hello@design.com',
                      keyboardType: TextInputType.emailAddress,
                      suffixDot: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email is required';
                        }
                        if (!value.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    const AuthFieldLabel('PASSWORD'),
                    const SizedBox(height: 8),
                    GlassTextField(
                      controller: _passwordController,
                      hint: '••••••',
                      obscureText: _obscurePassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        if (value.length < 6) {
                          return 'Use at least 6 characters';
                        }
                        return null;
                      },
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.white.withValues(alpha: 0.5),
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const AuthFieldLabel('I AM A'),
                    const SizedBox(height: 8),
                    RoleToggle(
                      roles: const ['passenger', 'conductor', 'admin'],
                      labels: const ['Passenger', 'Conductor', 'Admin'],
                      selected: _selectedRole,
                      onChanged: (value) => setState(() => _selectedRole = value),
                    ),

                    if (_selectedRole == 'conductor') ...[
                      const SizedBox(height: 20),
                      const AuthFieldLabel('COMPANY'),
                      const SizedBox(height: 8),
                      _isLoadingCompanies
                          ? const Center(
                        child: CircularProgressIndicator(color: kAuthAccentMint),
                      )
                          : _companies.isEmpty
                          ? Text(
                        'No companies registered yet — ask a company admin to sign up first.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      )
                          : Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.18),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<CompanyModel>(
                            isExpanded: true,
                            dropdownColor: const Color(0xFF17242A),
                            value: _selectedCompany,
                            hint: Text(
                              'Select a company',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4),
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                            items: _companies.map((c) {
                              return DropdownMenuItem(
                                value: c,
                                child: Text(c.name),
                              );
                            }).toList(),
                            onChanged: (value) =>
                                setState(() => _selectedCompany = value),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    if (_errorMessage != null) AuthErrorText(_errorMessage!),

                    GlassGradientButton(
                      label: 'Sign Up',
                      isLoading: _isLoading,
                      onTap: _handleSignup,
                    ),
                    const SizedBox(height: 20),

                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          );
                        },
                        child: Text(
                          'Already have an account? Log in',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}