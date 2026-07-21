import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/auth_service.dart';
import '../../services/company_service.dart';
import '../../widgets/glass_widgets.dart';

class AdminSettingsScreen extends StatefulWidget {
  final String companyId;
  const AdminSettingsScreen({super.key, required this.companyId});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final _authService = AuthService();
  final _companyService = CompanyService();

  final _nameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _regController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyEmailController = TextEditingController();

  String? _email;
  String? _logoUrl;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingLogo = false;
  bool _darkModeOn = true; // cosmetic only for now
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
      _logoUrl = company.logoUrl;

      setState(() => _isLoading = false);
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndUploadLogo() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked == null) return;

    setState(() => _isUploadingLogo = true);
    try {
      final url = await _companyService.uploadLogo(widget.companyId, File(picked.path));
      setState(() => _logoUrl = url);
    } catch (e) {
      setState(() => _message = 'Could not upload logo: $e');
    } finally {
      if (mounted) setState(() => _isUploadingLogo = false);
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Settings', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
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
                    Center(
                      child: GestureDetector(
                        onTap: _isUploadingLogo ? null : _pickAndUploadLogo,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 44,
                              backgroundColor: Colors.white.withOpacity(0.1),
                              backgroundImage: _logoUrl != null ? NetworkImage(_logoUrl!) : null,
                              child: _isUploadingLogo
                                  ? const CircularProgressIndicator(color: kAuthAccentMint)
                                  : (_logoUrl == null
                                  ? const Icon(Icons.directions_bus, color: Colors.white54, size: 36)
                                  : null),
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(color: kAuthAccentBlue, shape: BoxShape.circle),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: Text('Company logo', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                    ),
                    const SizedBox(height: 20),

                    const AuthFieldLabel('EMAIL'),
                    const SizedBox(height: 6),
                    Text(_email ?? '—', style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 16),
                    const AuthFieldLabel('YOUR NAME'),
                    const SizedBox(height: 8),
                    GlassTextField(controller: _nameController, hint: 'Your name'),

                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Dark mode', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
                        Switch(
                          value: _darkModeOn,
                          activeColor: kAuthAccentMint,
                          onChanged: (v) => setState(() => _darkModeOn = v),
                        ),
                      ],
                    ),
                    Text(
                      'Note: this toggle is cosmetic for now \u2014 full app-wide theming needs your theme file wired in.',
                      style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11),
                    ),

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
            ),
          ),
        ],
      ),
    );
  }
}