import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/trip_model.dart';
import '../../services/trip_service.dart';
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

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    setState(() => _isLoading = true);
    final trips = await _tripService.getTripsForConductor();
    setState(() {
      _trips = trips;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conductor Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Supabase.instance.client.auth.signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const CreateRouteScreen()));
                      _loadTrips();
                    },
                    child: const Text('+ New Route'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const CreateTripScreen()));
                      _loadTrips();
                    },
                    child: const Text('+ New Trip'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _trips.isEmpty
                ? const Center(child: Text('No trips yet — create one above.'))
                : ListView.builder(
              itemCount: _trips.length,
              itemBuilder: (context, index) {
                final trip = _trips[index];
                return ListTile(
                  title: Text('Departs: ${trip.departureTime}'),
                  subtitle: Text(
                    'Seats: ${trip.vehicleSeatCount} • Cargo left: ${trip.remainingCargoKg}kg • ${trip.status}',
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}