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
  final TripService _tripService = TripService();

  List<TripModel> _trips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    setState(() => _isLoading = true);

    try {
      final trips = await _tripService.getTripsForConductor();

      if (!mounted) return;

      setState(() {
        _trips = trips;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Operator Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.route),
                        label: const Text("New Route"),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CreateRouteScreen(),
                            ),
                          );

                          _loadTrips();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.directions_bus),
                        label: const Text("New Trip"),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CreateTripScreen(),
                            ),
                          );

                          _loadTrips();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(),
            )
                : _trips.isEmpty
                ? const Center(
              child: Text(
                "No trips yet.\nCreate a route and trip to get started.",
                textAlign: TextAlign.center,
              ),
            )
                : ListView.builder(
              itemCount: _trips.length,
              itemBuilder: (context, index) {
                final trip = _trips[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.directions_bus),
                    title: Text(
                      "Departure: ${trip.departureTime}",
                    ),
                    subtitle: Text(
                      "Seats: ${trip.vehicleSeatCount}\n"
                          "Cargo Remaining: ${trip.remainingCargoKg} kg\n"
                          "Status: ${trip.status}",
                    ),
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