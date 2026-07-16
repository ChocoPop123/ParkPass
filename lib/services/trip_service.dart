import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/route_model.dart';
import '../models/trip_model.dart';

class TripService {
  final supabase = Supabase.instance.client;

  Future<RouteModel> createRoute({
    required String origin,
    required String destination,
    required double baseFare,
    required double cargoPricePerKg,
  }) async {
    final data = await supabase
        .from('routes')
        .insert({
      'origin': origin,
      'destination': destination,
      'base_fare': baseFare,
      'cargo_price_per_kg': cargoPricePerKg,
      'created_by': supabase.auth.currentUser!.id,
    })
        .select()
        .single();

    return RouteModel.fromMap(data);
  }

  Future<List<RouteModel>> getAllRoutes() async {
    final data = await supabase.from('routes').select();
    return (data as List).map((r) => RouteModel.fromMap(r)).toList();
  }

  // Creates a trip AND generates all its seat_widget.dart rows in one go
  Future<TripModel> createTrip({
    required String routeId,
    required DateTime departureTime,
    required int seatCount,
    required double maxCargoKg,
  }) async {
    final tripData = await supabase
        .from('trips')
        .insert({
      'route_id': routeId,
      'departure_time': departureTime.toIso8601String(),
      'vehicle_seat_count': seatCount,
      'max_cargo_kg': maxCargoKg,
      'status': 'scheduled', // default status
    })
        .select()
        .single();

    final trip = TripModel.fromMap(tripData);

    // Generate one seat_widget.dart row per seat_widget.dart number
    final List<Map<String, dynamic>> seatRows = [];

    final seatsPerRow = 5; // Standard bus (2+3)

    for (int i = 0; i < seatCount; i++) {
      final row = i ~/ seatsPerRow;
      final seat = (i % seatsPerRow) + 1;

      final rowLetter = String.fromCharCode(65 + row);

      seatRows.add({
        'trip_id': trip.id,
        'seat_number': '$rowLetter$seat',
        'status': 'available',
      });
    }

    await supabase.from('seats').insert(seatRows);

    return trip;
  }

  Future<List<TripModel>> getTripsForConductor() async {
    final data = await supabase
        .from('trips')
        .select()
        .order('departure_time');
    return (data as List).map((t) => TripModel.fromMap(t)).toList();
  }

  Future<List<Map<String, dynamic>>> searchTrips({
    required String origin,
    required String destination,
  }) async {
    final data = await supabase
        .from('trips')
        .select('''
        id,
        departure_time,
        routes!inner(
          origin,
          destination,
          base_fare
        ),
        buses(
          bus_name
        )
      ''')
        .eq('routes.origin', origin)
        .eq('routes.destination', destination);

    return List<Map<String, dynamic>>.from(data);
  }
}
