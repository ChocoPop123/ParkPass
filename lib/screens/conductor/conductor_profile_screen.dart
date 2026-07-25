import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/auth_service.dart';
import '../../services/company_service.dart';
import '../../services/profile_service.dart';
import '../../widgets/glass_widgets.dart';

class ConductorProfileScreen extends StatefulWidget {
  const ConductorProfileScreen({super.key});

  @override
  State<ConductorProfileScreen> createState() => _ConductorProfileScreenState();
}

class _ConductorProfileScreenState extends State<ConductorProfileScreen> {
  final _authService = AuthService();
  final _companyService = CompanyService();
  final _profileService = ProfileService();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _companyName;
  String? _email;
  String? _avatarUrl;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingAvatar = false;
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
      _avatarUrl = profile?['avatar_url'] as String?;

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

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked == null) return;

    setState(() => _isUploadingAvatar = true);
    try {
      final url = await _profileService.uploadAvatar(File(picked.path));
      setState(() => _avatarUrl = url);
    } catch (e) {
      setState(() => _message = 'Could not upload photo: $e');
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
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
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Profile', style: TextStyle(color: colors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
              IconButton(
                icon: Icon(Icons.logout, color: colors.textSecondary),
                onPressed: () => Supabase.instance.client.auth.signOut(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GlassPanel(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: colors.accent))
                  : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _isUploadingAvatar ? null : _pickAndUploadAvatar,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 44,
                              backgroundColor: colors.surface,
                              backgroundImage: _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
                              child: _isUploadingAvatar
                                  ? CircularProgressIndicator(color: colors.accent)
                                  : (_avatarUrl == null
                                  ? Icon(Icons.person, color: colors.textSecondary, size: 40)
                                  : null),
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(color: colors.accent, shape: BoxShape.circle),
                              child: Icon(Icons.camera_alt, color: colors.buttonText, size: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const AuthFieldLabel('EMAIL'),
                    const SizedBox(height: 6),
                    Text(_email ?? '\u2014', style: TextStyle(color: colors.textSecondary)),
                    const SizedBox(height: 16),
                    const AuthFieldLabel('COMPANY'),
                    const SizedBox(height: 6),
                    Text(_companyName ?? '\u2014', style: TextStyle(color: colors.textSecondary)),
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
                        child: Text(_message!, style: TextStyle(color: colors.accent)),
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