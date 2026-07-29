import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cargo_booking_model.dart';

class CargoService {
  final supabase = Supabase.instance.client;

  Future<List<CargoBookingModel>> getCargoForTrip(String tripId) async {
    final data = await supabase
        .from('cargo_bookings')
        .select('*, profiles(full_name)')
        .eq('trip_id', tripId);
    return (data as List).map((c) => CargoBookingModel.fromMap(c)).toList();
  }

  Future<void> setCargoStatus(String cargoId, String status) async {
    await supabase.from('cargo_bookings').update({'status': status}).eq('id', cargoId);
  }
}