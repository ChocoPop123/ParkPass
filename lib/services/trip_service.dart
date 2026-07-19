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
    required String companyId,
  }) async {
    final data = await supabase
        .from('routes')
        .insert({
      'origin': origin,
      'destination': destination,
      'base_fare': baseFare,
      'cargo_price_per_kg': cargoPricePerKg,
      'created_by': supabase.auth.currentUser!.id,
      'company_id': companyId,
    })
        .select()
        .single();

    return RouteModel.fromMap(data);
  }

  Future<List<RouteModel>> getAllRoutes() async {
    final data = await supabase.from('routes').select();
    return (data as List).map((r) => RouteModel.fromMap(r)).toList();
  }

  Future<TripModel> createTrip({
    required String routeId,
    required DateTime departureTime,
    required int seatCount,
    required double maxCargoKg,
    String? busNumberPlate,
    String? busColor,
    String busClass = 'Ordinary',
    String? driverName,
    String? driverContact,
    double? fareOverride,
  }) async {
    final tripData = await supabase
        .from('trips')
        .insert({
      'route_id': routeId,
      'departure_time': departureTime.toIso8601String(),
      'vehicle_seat_count': seatCount,
      'max_cargo_kg': maxCargoKg,
      'bus_number_plate': busNumberPlate,
      'bus_color': busColor,
      'bus_class': busClass,
      'driver_name': driverName,
      'driver_contact': driverContact,
      'fare_override': fareOverride,
    })
        .select()
        .single();

    final trip = TripModel.fromMap(tripData);

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

  // Fetches trips joined with their route info (origin, destination, base fare)
  // so the UI can show the route name and compute the effective fare.
  Future<List<TripModel>> getTripsForConductor() async {
    final data = await supabase
        .from('trips')
        .select('*, routes(origin, destination, base_fare)')
        .order('departure_time');
    return (data as List).map((t) => TripModel.fromMap(t)).toList();
  }
}