class RouteModel {
  final String id;
  final String origin;
  final String destination;
  final double baseFare;
  final double cargoPricePerKg;

  RouteModel({
    required this.id,
    required this.origin,
    required this.destination,
    required this.baseFare,
    required this.cargoPricePerKg,
  });

  factory RouteModel.fromMap(Map<String, dynamic> map) {
    return RouteModel(
      id: map['id'],
      origin: map['origin'],
      destination: map['destination'],
      baseFare: (map['base_fare'] as num).toDouble(),
      cargoPricePerKg: (map['cargo_price_per_kg'] as num).toDouble(),
    );
  }
}