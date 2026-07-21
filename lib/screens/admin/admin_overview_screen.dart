import 'package:flutter/material.dart';
import '../../services/company_service.dart';
import '../../services/trip_service.dart';
import '../../widgets/glass_widgets.dart';

class AdminOverviewScreen extends StatefulWidget {
  final String companyId;
  const AdminOverviewScreen({super.key, required this.companyId});

  @override
  State<AdminOverviewScreen> createState() => _AdminOverviewScreenState();
}

class _AdminOverviewScreenState extends State<AdminOverviewScreen> {
  final _companyService = CompanyService();
  final _tripService = TripService();

  int _routeCount = 0;
  int _tripCount = 0;
  int _conductorCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final routeCount = await _tripService.getRouteCountForCompany(widget.companyId);
      final tripCount = await _tripService.getTripCountForCompany(widget.companyId);
      final conductorCount = await _companyService.getApprovedConductorCount(widget.companyId);
      setState(() {
        _routeCount = routeCount;
        _tripCount = tripCount;
        _conductorCount = conductorCount;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Widget _statCard(String label, int value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.14)),
        ),
        child: Column(
          children: [
            Icon(icon, color: kAuthAccentMint, size: 22),
            const SizedBox(height: 8),
            Text('$value', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Overview', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator(color: kAuthAccentMint)))
          else
            Row(
              children: [
                _statCard('Routes', _routeCount, Icons.alt_route),
                const SizedBox(width: 10),
                _statCard('Trips', _tripCount, Icons.directions_bus),
                const SizedBox(width: 10),
                _statCard('Conductors', _conductorCount, Icons.person),
              ],
            ),
        ],
      ),
    );
  }
}