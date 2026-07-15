class TripModel {
  final String id;
  final String routeId;
  final DateTime departureTime;
  final int vehicleSeatCount;
  final String status;
  final double maxCargoKg;
  final double cargoKgBooked;

  TripModel({
    required this.id,
    required this.routeId,
    required this.departureTime,
    required this.vehicleSeatCount,
    required this.status,
    required this.maxCargoKg,
    required this.cargoKgBooked,
  });

  factory TripModel.fromMap(Map<String, dynamic> map) {
    return TripModel(
      id: map['id'],
      routeId: map['route_id'],
      departureTime: DateTime.parse(map['departure_time']),
      vehicleSeatCount: map['vehicle_seat_count'],
      status: map['status'],
      maxCargoKg: (map['max_cargo_kg'] as num).toDouble(),
      cargoKgBooked: (map['cargo_kg_booked'] as num).toDouble(),
    );
  }

  double get remainingCargoKg => maxCargoKg - cargoKgBooked;
}