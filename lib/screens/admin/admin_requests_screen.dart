import 'package:flutter/material.dart';
import '../../services/company_service.dart';
import '../../widgets/glass_widgets.dart';

class AdminRequestsScreen extends StatefulWidget {
  final String companyId;
  const AdminRequestsScreen({super.key, required this.companyId});

  @override
  State<AdminRequestsScreen> createState() => _AdminRequestsScreenState();
}

class _AdminRequestsScreenState extends State<AdminRequestsScreen> {
  final _companyService = CompanyService();
  List<Map<String, dynamic>> _pending = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final pending = await _companyService.getPendingConductors(widget.companyId);
    setState(() {
      _pending = pending;
      _isLoading = false;
    });
  }

  Future<void> _respond(String conductorId, String status) async {
    await _companyService.setConductorApproval(conductorId, status);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Pending Requests', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Expanded(
            child: GlassPanel(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: kAuthAccentMint))
                  : _pending.isEmpty
                  ? Center(child: Text('No pending conductor requests.', style: TextStyle(color: Colors.white.withOpacity(0.6))))
                  : ListView.builder(
                itemCount: _pending.length,
                itemBuilder: (context, index) {
                  final conductor = _pending[index];
                  return GlassListRow(
                    icon: Icons.person_outline,
                    title: conductor['full_name'] ?? 'Unnamed',
                    subtitle: 'Waiting for approval',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GlassIconAction(
                          icon: Icons.check,
                          color: kAuthAccentGreen,
                          onTap: () => _respond(conductor['id'], 'approved'),
                        ),
                        GlassIconAction(
                          icon: Icons.close,
                          color: const Color(0xFFFF6B81),
                          onTap: () => _respond(conductor['id'], 'rejected'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}