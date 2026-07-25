import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/route_model.dart';
import '../models/trip_model.dart';
import '../models/booking_model.dart';

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

  Future<void> updateTripStatus(String tripId, String status) async {
    await supabase.from('trips').update({'status': status}).eq('id', tripId);
  }

  Future<void> deleteTrip(String tripId) async {
    await supabase.from('trips').delete().eq('id', tripId);
  }

  Future<void> updateTrip({
    required String tripId,
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
    await supabase.from('trips').update({
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
    }).eq('id', tripId);
  }

  Future<List<BookingModel>> getManifestForTrip(String tripId) async {
    final data = await supabase
        .from('bookings')
        .select('*, profiles(full_name), seats(seat_number)')
        .eq('trip_id', tripId);
    return (data as List).map((b) => BookingModel.fromMap(b)).toList();
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

  Future<int> getRouteCountForCompany(String companyId) async {
    final data = await supabase.from('routes').select('id').eq('company_id', companyId);
    return (data as List).length;
  }

  Future<int> getTripCountForCompany(String companyId) async {
    final data = await supabase
        .from('trips')
        .select('id, routes!inner(company_id)')
        .eq('routes.company_id', companyId);
    return (data as List).length;
  }

  // Fetches trips matching the selected route and optional date criteria,
  // ensuring users only see future departures even for today's date.
  Future<List<Map<String, dynamic>>> searchTrips({
    required String origin,
    required String destination,
    DateTime? date,
  }) async {
    var query = supabase
        .from('trips')
        .select('''
          *,
          routes!inner(
            origin,
            destination,
            base_fare
          )
        ''')
        .eq('routes.origin', origin)
        .eq('routes.destination', destination);

    if (date != null) {
      final now = DateTime.now();

      // If the selected date is today, start searching from right NOW.
      // Otherwise, start from 00:00 of the selected date.
      final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
      final startSearchTime = isToday
          ? now.toIso8601String()
          : DateTime(date.year, date.month, date.day).toIso8601String();

      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59).toIso8601String();

      query = query
          .gte('departure_time', startSearchTime)
          .lte('departure_time', endOfDay);
    } else {
      final now = DateTime.now().toIso8601String();
      query = query.gte('departure_time', now);
    }

    final data = await query.order('departure_time');

    return List<Map<String, dynamic>>.from(data as List);
  }
}