import 'package:flutter/material.dart';
import '../models/company_model.dart';
import '../services/company_service.dart';
import 'glass_widgets.dart';

Future<CompanyModel?> showCompanyPicker(BuildContext context) {
  return showModalBottomSheet<CompanyModel>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _CompanyPickerContent(),
  );
}

class _CompanyPickerContent extends StatefulWidget {
  const _CompanyPickerContent();

  @override
  State<_CompanyPickerContent> createState() => _CompanyPickerContentState();
}

class _CompanyPickerContentState extends State<_CompanyPickerContent> {
  final _companyService = CompanyService();
  final _searchController = TextEditingController();
  List<CompanyModel> _all = [];
  List<CompanyModel> _filtered = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
    _searchController.addListener(_onSearch);
  }

  Future<void> _load() async {
    final companies = await _companyService.getAllCompanies();
    setState(() {
      _all = companies;
      _filtered = companies;
      _isLoading = false;
    });
  }

  void _onSearch() {
    final q = _searchController.text.toLowerCase();
    setState(() => _filtered = _all.where((c) =>
    c.name.toLowerCase().contains(q) || (c.username?.contains(q) ?? false)).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.65,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        decoration: const BoxDecoration(
          color: Color(0xFF11201F),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Choose a company',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            GlassTextField(controller: _searchController, hint: 'Search companies'),
            const SizedBox(height: 14),
            GlassListRow(
              icon: Icons.apps,
              title: 'All Companies',
              onTap: () => Navigator.pop(context, null),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: kAuthAccentMint))
                  : _filtered.isEmpty
                  ? Center(child: Text('No companies found.', style: TextStyle(color: Colors.white.withValues(alpha: 0.5))))
                  : ListView.builder(
                itemCount: _filtered.length,
                itemBuilder: (context, index) {
                  final company = _filtered[index];
                  return _CompanyLogoRow(
                    company: company,
                    onTap: () => Navigator.pop(context, company),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompanyLogoRow extends StatelessWidget {
  final CompanyModel company;
  final VoidCallback onTap;
  const _CompanyLogoRow({required this.company, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.14)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white.withOpacity(0.1),
              backgroundImage: company.logoUrl != null ? NetworkImage(company.logoUrl!) : null,
              child: company.logoUrl == null
                  ? const Icon(Icons.directions_bus, color: Colors.white54, size: 18)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(company.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  if (company.username != null)
                    Text('@${company.username}',
                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}