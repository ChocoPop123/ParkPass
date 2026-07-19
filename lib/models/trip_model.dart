class TripModel {
  final String id;
  final String routeId;
  final DateTime departureTime;
  final int vehicleSeatCount;
  final String status;
  final double maxCargoKg;
  final double cargoKgBooked;
  final String? busNumberPlate;
  final String? busColor;
  final String busClass;
  final String? driverName;
  final String? driverContact;
  final double? fareOverride;

  // Populated only when the trip is fetched joined with its route
  final String? routeOrigin;
  final String? routeDestination;
  final double? routeBaseFare;

  TripModel({
    required this.id,
    required this.routeId,
    required this.departureTime,
    required this.vehicleSeatCount,
    required this.status,
    required this.maxCargoKg,
    required this.cargoKgBooked,
    this.busNumberPlate,
    this.busColor,
    this.busClass = 'Ordinary',
    this.driverName,
    this.driverContact,
    this.fareOverride,
    this.routeOrigin,
    this.routeDestination,
    this.routeBaseFare,
  });

  factory TripModel.fromMap(Map<String, dynamic> map) {
    final nestedRoute = map['routes'] as Map<String, dynamic>?;

    return TripModel(
      id: map['id'],
      routeId: map['route_id'],
      departureTime: DateTime.parse(map['departure_time']),
      vehicleSeatCount: map['vehicle_seat_count'],
      status: map['status'],
      maxCargoKg: (map['max_cargo_kg'] as num).toDouble(),
      cargoKgBooked: (map['cargo_kg_booked'] as num).toDouble(),
      busNumberPlate: map['bus_number_plate'] as String?,
      busColor: map['bus_color'] as String?,
      busClass: (map['bus_class'] as String?) ?? 'Ordinary',
      driverName: map['driver_name'] as String?,
      driverContact: map['driver_contact'] as String?,
      fareOverride: map['fare_override'] != null ? (map['fare_override'] as num).toDouble() : null,
      routeOrigin: nestedRoute?['origin'] as String?,
      routeDestination: nestedRoute?['destination'] as String?,
      routeBaseFare: nestedRoute?['base_fare'] != null ? (nestedRoute!['base_fare'] as num).toDouble() : null,
    );
  }

  double get remainingCargoKg => maxCargoKg - cargoKgBooked;

  // The actual fare a passenger pays: the trip's own override if set,
  // otherwise the route's base fare.
  double get effectiveFare => fareOverride ?? routeBaseFare ?? 0;
}