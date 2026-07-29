class BookingModel {
  final String id;
  final String tripId;
  final String seatId;
  final String passengerId;
  final double farePaid;
  final String paymentStatus;
  final bool checkedIn;
  final String? passengerName;
  final int? seatNumber;

  BookingModel({
    required this.id,
    required this.tripId,
    required this.seatId,
    required this.passengerId,
    required this.farePaid,
    required this.paymentStatus,
    required this.checkedIn,
    this.passengerName,
    this.seatNumber,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    final profile = map['profiles'] as Map<String, dynamic>?;
    final seat = map['seats'] as Map<String, dynamic>?;

    return BookingModel(
      id: map['id'],
      tripId: map['trip_id'],
      seatId: map['seat_id'],
      passengerId: map['passenger_id'],
      farePaid: (map['fare_paid'] as num?)?.toDouble() ?? 0,
      paymentStatus: map['payment_status'] ?? 'pending',
      checkedIn: map['checked_in'] ?? false,
      passengerName: profile?['full_name'] as String?,
      seatNumber: seat?['seat_number'] as int?,
    );
  }
}