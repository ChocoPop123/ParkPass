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

  // Creates a trip AND generates all its seat rows in one go
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
    })
        .select()
        .single();

    final trip = TripModel.fromMap(tripData);

    // Generate one seat row per seat number
    final seatRows = List.generate(
      seatCount,
          (index) => {
        'trip_id': trip.id,
        'seat_number': index + 1,
        'status': 'available',
      },
    );
    await supabase.from('seats').insert(seatRows);

    return trip;
  }

  Future<List<TripModel>> getTripsForConductor() async {
    // For now: all trips (since routes aren't filtered by conductor yet).
    // We'll refine this to "only trips on routes I created" once you have more than one conductor testing.
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
        fare,
        routes!inner(
          origin,
          destination
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