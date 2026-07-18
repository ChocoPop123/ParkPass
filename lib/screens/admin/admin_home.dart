import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/company_service.dart';
import '../../widgets/glass_widgets.dart';

class AdminHome extends StatefulWidget {
  final String companyId;
  const AdminHome({super.key, required this.companyId});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
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
    return Scaffold(
      body: AuthBackground(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Company Admin',
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white70),
                    onPressed: () => Supabase.instance.client.auth.signOut(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GlassPanel(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: kAuthAccentMint))
                      : _pending.isEmpty
                      ? Center(
                    child: Text('No pending conductor requests.',
                        style: TextStyle(color: Colors.white.withOpacity(0.6))),
                  )
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
        ),
      ),
    );
  }
}