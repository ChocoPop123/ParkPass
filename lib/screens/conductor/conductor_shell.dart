import 'package:flutter/material.dart';
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

  final _screens = const [
    ConductorRoutesScreen(),
    ConductorTripsScreen(),
    ConductorProfileScreen(),
  ];

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
    return Scaffold(
      body: AuthBackground(
        child: Column(
          children: [
            Expanded(child: IndexedStack(index: _index, children: _screens)),
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
                  _navItem(Icons.alt_route, 'Routes', 0),
                  _navItem(Icons.directions_bus, 'Trips', 1),
                  _navItem(Icons.person, 'Profile', 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}