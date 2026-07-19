import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/trip_model.dart';
import '../../services/trip_service.dart';
import '../../widgets/glass_widgets.dart';
import 'create_route_screen.dart';
import 'create_trip_screen.dart';

class ConductorHome extends StatefulWidget {
  const ConductorHome({super.key});

  @override
  State<ConductorHome> createState() => _ConductorHomeState();
}

class _ConductorHomeState extends State<ConductorHome> {
  final _tripService = TripService();
  List<TripModel> _trips = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final trips = await _tripService.getTripsForConductor();
      setState(() {
        _trips = trips;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not load trips: $e';
      });
    }
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
                  const Text('Conductor Home',
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white70),
                    onPressed: () => Supabase.instance.client.auth.signOut(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateRouteScreen()));
                        _loadTrips();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withOpacity(0.18)),
                        ),
                        child: const Center(
                          child: Text('+ New Route', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateTripScreen()));
                        _loadTrips();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [kAuthAccentBlue, kAuthAccentSkyBlue]),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: Text('+ New Trip', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GlassPanel(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: kAuthAccentMint))
                      : _errorMessage != null
                      ? Center(child: Text(_errorMessage!, style: TextStyle(color: Colors.white.withOpacity(0.7)), textAlign: TextAlign.center))
                      : _trips.isEmpty
                      ? Center(child: Text('No trips yet — create one above.', style: TextStyle(color: Colors.white.withOpacity(0.6))))
                      : ListView.builder(
                    itemCount: _trips.length,
                    itemBuilder: (context, index) {
                      final trip = _trips[index];
                      final routeLabel = trip.routeOrigin != null
                          ? '${trip.routeOrigin} → ${trip.routeDestination}'
                          : 'Route';
                      return GlassListRow(
                        icon: Icons.directions_bus,
                        title: routeLabel,
                        subtitle:
                        '${trip.departureTime.toString().substring(0, 16)} · ${trip.busClass}'
                            '${trip.busNumberPlate != null ? " · ${trip.busNumberPlate}" : ""}\n'
                            'Seats: ${trip.vehicleSeatCount} · Cargo left: ${trip.remainingCargoKg}kg · '
                            'UGX ${trip.effectiveFare.toStringAsFixed(0)}',
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