class CargoBookingModel {
  final String id;
  final String tripId;
  final String ownerId;
  final double weightKg;
  final double price;
  final String status;
  final String? ownerName;

  CargoBookingModel({
    required this.id,
    required this.tripId,
    required this.ownerId,
    required this.weightKg,
    required this.price,
    required this.status,
    this.ownerName,
  });

  factory CargoBookingModel.fromMap(Map<String, dynamic> map) {
    final profile = map['profiles'] as Map<String, dynamic>?;
    return CargoBookingModel(
      id: map['id'],
      tripId: map['trip_id'],
      ownerId: map['owner_id'],
      weightKg: (map['weight_kg'] as num).toDouble(),
      price: (map['price'] as num).toDouble(),
      status: map['status'],
      ownerName: profile?['full_name'] as String?,
    );
  }
}