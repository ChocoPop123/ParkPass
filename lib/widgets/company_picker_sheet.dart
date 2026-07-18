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
    setState(() => _filtered = _all.where((c) => c.name.toLowerCase().contains(q)).toList());
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
                  ? Center(child: Text('No companies found.', style: TextStyle(color: Colors.white.withOpacity(0.5))))
                  : ListView.builder(
                itemCount: _filtered.length,
                itemBuilder: (context, index) {
                  final company = _filtered[index];
                  return GlassListRow(
                    icon: Icons.directions_bus,
                    title: company.name,
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