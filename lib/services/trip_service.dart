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
      'origin': origin.trim(),
      'destination': destination.trim(),
      'base_fare': baseFare,
      'cargo_price_per_kg': cargoPricePerKg,
      'created_by': supabase.auth.currentUser!.id,
      'company_id': companyId,
    })
        .select()
        .single();

    return RouteModel.fromMap(data);
  }

  Future<List<RouteModel>> getAllRoutes({String? companyId}) async {
    var query = supabase.from('routes').select();
    if (companyId != null) {
      query = query.eq('company_id', companyId);
    }
    final data = await query.order('origin');
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
      'status': 'scheduled',
    })
        .select()
        .single();

    final trip = TripModel.fromMap(tripData);

    // Create seat records for the trip
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

  Future<List<TripModel>> getTripsForConductor(String companyId) async {
    final data = await supabase
        .from('trips')
        .select('*, routes!inner(origin, destination, base_fare, company_id)')
        .eq('routes.company_id', companyId)
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
            base_fare,
            companies(name)
          )
        ''')
        .ilike('routes.origin', origin.trim())
        .ilike('routes.destination', destination.trim());

    // Allow scheduled or null status (null = migration legacy)
    query = query.or('status.eq.scheduled,status.is.null');

    if (date != null) {
      final nowBuffer = DateTime.now().subtract(const Duration(minutes: 5));
      final isToday = date.year == nowBuffer.year && date.month == nowBuffer.month && date.day == nowBuffer.day;
      
      final startSearchTime = isToday
          ? nowBuffer.toIso8601String()
          : DateTime(date.year, date.month, date.day).toIso8601String();

      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59).toIso8601String();

      query = query
          .gte('departure_time', startSearchTime)
          .lte('departure_time', endOfDay);
    } else {
      final nowBuffer = DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String();
      query = query.gte('departure_time', nowBuffer);
    }

    final data = await query.order('departure_time');

    return List<Map<String, dynamic>>.from(data as List);
  }
}
