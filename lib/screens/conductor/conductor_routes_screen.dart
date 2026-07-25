import 'package:flutter/material.dart';
import '../../models/route_model.dart';
import '../../services/trip_service.dart';
import '../../widgets/glass_widgets.dart';
import 'create_route_screen.dart';

class ConductorRoutesScreen extends StatefulWidget {
  const ConductorRoutesScreen({super.key});

  @override
  State<ConductorRoutesScreen> createState() => _ConductorRoutesScreenState();
}

class _ConductorRoutesScreenState extends State<ConductorRoutesScreen> {
  final _tripService = TripService();
  List<RouteModel> _routes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final routes = await _tripService.getAllRoutes();
      setState(() {
        _routes = routes;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
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
          Text('Routes', style: TextStyle(color: colors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateRouteScreen()));
              _load();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: colors.accent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text('+ New Route', style: TextStyle(color: colors.buttonText, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GlassPanel(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: colors.accent))
                  : _routes.isEmpty
                  ? Center(child: Text('No routes yet.', style: TextStyle(color: colors.textSecondary)))
                  : ListView.builder(
                itemCount: _routes.length,
                itemBuilder: (context, index) {
                  final r = _routes[index];
                  return GlassListRow(
                    icon: Icons.alt_route,
                    title: '${r.origin} \u2192 ${r.destination}',
                    subtitle: 'Fare: UGX ${r.baseFare.toStringAsFixed(0)} \u00b7 Cargo: UGX ${r.cargoPricePerKg.toStringAsFixed(0)}/kg',
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