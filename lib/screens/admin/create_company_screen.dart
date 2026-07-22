import 'package:flutter/material.dart';
import '../../services/company_service.dart';
import '../../widgets/glass_widgets.dart';

class CreateCompanyScreen extends StatefulWidget {
  const CreateCompanyScreen({super.key});

  @override
  State<CreateCompanyScreen> createState() => _CreateCompanyScreenState();
}

class _CreateCompanyScreenState extends State<CreateCompanyScreen> {
  final _companyService = CompanyService();
  final _nameController = TextEditingController();
  final _regController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleCreate() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await _companyService.createCompany(
        name: _nameController.text.trim(),
        registrationNumber: _regController.text.trim(),
        contactPhone: _phoneController.text.trim(),
        contactEmail: _emailController.text.trim(),
      );
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
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