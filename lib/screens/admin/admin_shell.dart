import 'package:flutter/material.dart';
import '../../widgets/glass_widgets.dart';
import 'admin_overview_screen.dart';
import 'admin_requests_screen.dart';
import 'admin_settings_screen.dart';

class AdminShell extends StatefulWidget {
  final String companyId;
  const AdminShell({super.key, required this.companyId});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  Widget _navItem(IconData icon, String label, int idx) {
    final selected = _index == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _index = idx),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: selected ? kAuthAccentMint : Colors.white.withOpacity(0.45), size: 22),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                  color: selected ? kAuthAccentMint : Colors.white.withOpacity(0.45),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      AdminOverviewScreen(companyId: widget.companyId),
      AdminRequestsScreen(companyId: widget.companyId),
      AdminSettingsScreen(companyId: widget.companyId),
    ];

    return Scaffold(
      body: AuthBackground(
        child: Column(
          children: [
            Expanded(child: IndexedStack(index: _index, children: screens)),
            Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.18)),
              ),
              child: Row(
                children: [
                  _navItem(Icons.dashboard_outlined, 'Overview', 0),
                  _navItem(Icons.how_to_reg, 'Requests', 1),
                  _navItem(Icons.settings, 'Settings', 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}