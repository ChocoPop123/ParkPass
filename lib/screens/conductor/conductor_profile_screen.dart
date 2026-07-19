import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/auth_service.dart';
import '../../services/company_service.dart';
import '../../widgets/glass_widgets.dart';

class ConductorProfileScreen extends StatefulWidget {
  const ConductorProfileScreen({super.key});

  @override
  State<ConductorProfileScreen> createState() => _ConductorProfileScreenState();
}

class _ConductorProfileScreenState extends State<ConductorProfileScreen> {
  final _authService = AuthService();
  final _companyService = CompanyService();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _companyName;
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
      _phoneController.text = profile?['phone'] ?? '';

      final companyId = profile?['company_id'] as String?;
      if (companyId != null) {
        final company = await _companyService.getCompanyById(companyId);
        _companyName = company.name;
      }
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
        'phone': _phoneController.text.trim(),
      }).eq('id', userId);
      setState(() => _message = 'Saved.');
    } catch (e) {
      setState(() => _message = 'Could not save: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Profile', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white70),
                onPressed: () => Supabase.instance.client.auth.signOut(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GlassPanel(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: kAuthAccentMint))
                  : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AuthFieldLabel('EMAIL'),
                    const SizedBox(height: 6),
                    Text(_email ?? '—', style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 16),
                    const AuthFieldLabel('COMPANY'),
                    const SizedBox(height: 6),
                    Text(_companyName ?? '—', style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 18),
                    const AuthFieldLabel('FULL NAME'),
                    const SizedBox(height: 8),
                    GlassTextField(controller: _nameController, hint: 'Your name'),
                    const SizedBox(height: 16),
                    const AuthFieldLabel('PHONE'),
                    const SizedBox(height: 8),
                    GlassTextField(controller: _phoneController, hint: '+256...', keyboardType: TextInputType.phone),
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
            ),
          ),
        ],
      ),
    );
  }
}