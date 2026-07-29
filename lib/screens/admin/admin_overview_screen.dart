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

  Widget _statCard(String label, int value, IconData icon, AppColors colors) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: colors.accent, size: 22),
            const SizedBox(height: 8),
            Text('$value', style: TextStyle(color: colors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: colors.textSecondary, fontSize: 11), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Overview', style: TextStyle(color: colors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          if (_isLoading)
            Expanded(child: Center(child: CircularProgressIndicator(color: colors.accent)))
          else
            Row(
              children: [
                _statCard('Routes', _routeCount, Icons.alt_route, colors),
                const SizedBox(width: 10),
                _statCard('Trips', _tripCount, Icons.directions_bus, colors),
                const SizedBox(width: 10),
                _statCard('Conductors', _conductorCount, Icons.person, colors),
              ],
            ),
        ],
      ),
    );
  }
}
