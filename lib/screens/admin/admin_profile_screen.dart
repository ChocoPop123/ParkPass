import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/auth_service.dart';
import '../../services/company_service.dart';
import '../../widgets/glass_widgets.dart';

class AdminProfileScreen extends StatefulWidget {
  final String companyId;
  const AdminProfileScreen({super.key, required this.companyId});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final _authService = AuthService();
  final _companyService = CompanyService();

  final _nameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _regController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyEmailController = TextEditingController();

  String? _email;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final profile = await _authService.getCurrentUserProfile();
      _email = Supabase.instance.client.auth.currentUser?.email;
      _nameController.text = profile?['full_name'] ?? '';

      final company = await _companyService.getCompanyById(widget.companyId);
      _companyNameController.text = company.name;
      _regController.text = company.registrationNumber ?? '';
      _phoneController.text = company.contactPhone ?? '';
      _companyEmailController.text = company.contactEmail ?? '';

      setState(() => _isLoading = false);
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    setState(() {
      _isSaving = true;
      _message = null;
    });
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      await Supabase.instance.client.from('profiles').update({
        'full_name': _nameController.text.trim(),
      }).eq('id', userId);

      await _companyService.updateCompany(
        companyId: widget.companyId,
        name: _companyNameController.text.trim(),
        registrationNumber: _regController.text.trim(),
        contactPhone: _phoneController.text.trim(),
        contactEmail: _companyEmailController.text.trim(),
      );

      setState(() => _message = 'Saved.');
    } catch (e) {
      setState(() => _message = 'Could not save: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text('Profile & Company', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 16),
              GlassPanel(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: kAuthAccentMint))
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AuthFieldLabel('EMAIL'),
                    const SizedBox(height: 6),
                    Text(_email ?? '—', style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 16),
                    const AuthFieldLabel('YOUR NAME'),
                    const SizedBox(height: 8),
                    GlassTextField(controller: _nameController, hint: 'Your name'),
                    const SizedBox(height: 22),
                    Text('COMPANY DETAILS', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11, letterSpacing: 1)),
                    const SizedBox(height: 12),
                    const AuthFieldLabel('COMPANY NAME'),
                    const SizedBox(height: 8),
                    GlassTextField(controller: _companyNameController, hint: 'Company name'),
                    const SizedBox(height: 16),
                    const AuthFieldLabel('REGISTRATION NUMBER'),
                    const SizedBox(height: 8),
                    GlassTextField(controller: _regController, hint: 'UG-2024-00123'),
                    const SizedBox(height: 16),
                    const AuthFieldLabel('CONTACT PHONE'),
                    const SizedBox(height: 8),
                    GlassTextField(controller: _phoneController, hint: '+256...', keyboardType: TextInputType.phone),
                    const SizedBox(height: 16),
                    const AuthFieldLabel('CONTACT EMAIL'),
                    const SizedBox(height: 8),
                    GlassTextField(controller: _companyEmailController, hint: 'company@email.com', keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 20),
                    if (_message != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(_message!, style: TextStyle(color: kAuthAccentMint.withOpacity(0.9))),
                      ),
                    GlassGradientButton(label: 'Save', isLoading: _isSaving, onTap: _save),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}