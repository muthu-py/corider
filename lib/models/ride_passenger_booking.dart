class RidePassengerBooking {
  RidePassengerBooking({
    required this.id,
    required this.rideId,
    required this.passengerId,
    required this.seatsBooked,
    required this.status,
    required this.createdAt,
    this.passengerName,
    this.passengerPhone,
  });

  final String id;
  final String rideId;
  final String passengerId;
  final int seatsBooked;
  final String status;
  final DateTime createdAt;
  final String? passengerName;
  final String? passengerPhone;
}
