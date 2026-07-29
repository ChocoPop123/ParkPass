import 'package:flutter/material.dart';
import '../../services/company_service.dart';
import '../../widgets/glass_widgets.dart';
import 'conductor_routes_screen.dart';
import 'conductor_trips_screen.dart';
import 'conductor_profile_screen.dart';

class ConductorShell extends StatefulWidget {
  const ConductorShell({super.key});

  @override
  State<ConductorShell> createState() => _ConductorShellState();
}

class _ConductorShellState extends State<ConductorShell> {
  int _index = 1;
  String? _companyId;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCompany();
  }

  Future<void> _loadCompany() async {
    try {
      final id = await CompanyService().getMyCompanyId();
      if (mounted) {
        setState(() {
          _companyId = id;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Widget _navItem(IconData icon, String label, int idx, AppColors colors) {
    final selected = _index == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _index = idx),
        child: Container(
          color: Colors.transparent, // Expand tap area
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: selected ? colors.accent : colors.textSecondary, size: 22),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                    color: selected ? colors.accent : colors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    
    if (_isLoading) {
      return Scaffold(
        backgroundColor: colors.background,
        body: Center(
          child: CircularProgressIndicator(color: colors.accent),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: colors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Error loading dashboard:\n$_error',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.textPrimary),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: 150,
                  child: GlassGradientButton(
                    label: "Retry",
                    onTap: () {
                      setState(() {
                        _isLoading = true;
                        _error = null;
                      });
                      _loadCompany();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final screens = [
      ConductorRoutesScreen(companyId: _companyId),
      ConductorTripsScreen(companyId: _companyId),
      const ConductorProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: IndexedStack(index: _index, children: screens)),
            Container(
              margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _navItem(Icons.alt_route, 'Routes', 0, colors),
                  _navItem(Icons.directions_bus, 'Trips', 1, colors),
                  _navItem(Icons.person, 'Profile', 2, colors),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
