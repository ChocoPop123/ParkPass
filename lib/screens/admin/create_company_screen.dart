import 'package:flutter/material.dart';
import '../../services/company_service.dart';
import '../../widgets/glass_widgets.dart';
import '../../main.dart';

class CreateCompanyScreen extends StatefulWidget {
  const CreateCompanyScreen({super.key});

  @override
  State<CreateCompanyScreen> createState() => _CreateCompanyScreenState();
}

class _CreateCompanyScreenState extends State<CreateCompanyScreen> {
  final _companyService = CompanyService();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _regController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  bool? _usernameAvailable; // null = not checked yet / invalid format

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_checkUsername);
  }

  @override
  void dispose() {
    _usernameController.removeListener(_checkUsername);
    _nameController.dispose();
    _usernameController.dispose();
    _regController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _checkUsername() async {
    final username = _usernameController.text.trim().toLowerCase();
    if (!RegExp(r'^[a-z0-9_]{3,20}$').hasMatch(username)) {
      setState(() => _usernameAvailable = null);
      return;
    }
    final available = await _companyService.isUsernameAvailable(username);
    if (mounted) setState(() => _usernameAvailable = available);
  }

  Future<void> _handleCreate() async {
    final username = _usernameController.text.trim().toLowerCase();
    if (!RegExp(r'^[a-z0-9_]{3,20}$').hasMatch(username)) {
      setState(() => _errorMessage =
      'Username must be 3-20 characters: lowercase letters, numbers, underscores only.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await _companyService.createCompany(
        name: _nameController.text.trim(),
        username: username,
        registrationNumber: _regController.text.trim(),
        contactPhone: _phoneController.text.trim(),
        contactEmail: _emailController.text.trim(),
      );
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AuthGate()),
              (route) => false,
        );
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: GlassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Register Your Company',
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text('Before you can approve conductors and manage routes, register your bus company.',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13)),
                  const SizedBox(height: 24),
                  const AuthFieldLabel('COMPANY NAME'),
                  const SizedBox(height: 8),
                  GlassTextField(controller: _nameController, hint: 'e.g. Link Bus Company'),
                  const SizedBox(height: 16),
                  const AuthFieldLabel('USERNAME'),
                  const SizedBox(height: 8),
                  GlassTextField(
                    controller: _usernameController,
                    hint: 'e.g. linkbus',
                    suffixIcon: _usernameAvailable == null
                        ? null
                        : Icon(
                      _usernameAvailable! ? Icons.check_circle : Icons.cancel,
                      color: _usernameAvailable! ? kAuthAccentGreen : const Color(0xFFFF6B81),
                      size: 18,
                    ),
                  ),
                  if (_usernameAvailable == false)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text('Already taken.',
                          style: TextStyle(color: const Color(0xFFFF6B81), fontSize: 11)),
                    ),
                  const SizedBox(height: 16),
                  const AuthFieldLabel('REGISTRATION NUMBER'),
                  const SizedBox(height: 8),
                  GlassTextField(controller: _regController, hint: 'e.g. UG-2024-00123'),
                  const SizedBox(height: 16),
                  const AuthFieldLabel('CONTACT PHONE'),
                  const SizedBox(height: 8),
                  GlassTextField(controller: _phoneController, hint: '+256...', keyboardType: TextInputType.phone),
                  const SizedBox(height: 16),
                  const AuthFieldLabel('CONTACT EMAIL'),
                  const SizedBox(height: 8),
                  GlassTextField(controller: _emailController, hint: 'company@email.com', keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 24),
                  if (_errorMessage != null) AuthErrorText(_errorMessage!),
                  GlassGradientButton(label: 'Register Company', isLoading: _isLoading, onTap: _handleCreate),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}