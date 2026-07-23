import 'package:flutter/material.dart';
import '../../models/trip_model.dart';
import '../../services/trip_service.dart';
import '../../widgets/glass_widgets.dart';
import 'create_trip_screen.dart';
import 'trip_detail_screen.dart';

class ConductorTripsScreen extends StatefulWidget {
  const ConductorTripsScreen({super.key});

  @override
  State<ConductorTripsScreen> createState() => _ConductorTripsScreenState();
}

class _ConductorTripsScreenState extends State<ConductorTripsScreen> {
  final _tripService = TripService();
  List<TripModel> _trips = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Trips', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateTripScreen()));
              _load();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [kAuthAccentBlue, kAuthAccentSkyBlue]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text('+ New Trip', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GlassPanel(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: kAuthAccentMint))
                  : _errorMessage != null
                  ? Center(child: Text(_errorMessage!, style: TextStyle(color: Colors.white.withOpacity(0.7))))
                  : _trips.isEmpty
                  ? Center(child: Text('No trips yet.', style: TextStyle(color: Colors.white.withOpacity(0.6))))
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
                    '${trip.departureTime.toString().substring(0, 16)} · ${trip.busClass} · ${trip.displayStatus}',
                    onTap: () async {
                      final changed = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => TripDetailScreen(trip: trip)),
                      );
                      if (changed == true) _load();
                    },
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