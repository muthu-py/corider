import 'package:co_rider/models/ride.dart';

class RideBooking {
  RideBooking({
    required this.id,
    required this.rideId,
    required this.passengerId,
    required this.seatsBooked,
    required this.status,
    required this.createdAt,
    required this.ride,
    this.driverName,
    this.driverPhone,
  });

  final String id;
  final String rideId;
  final String passengerId;
  final int seatsBooked;
  final String status;
  final DateTime createdAt;
  final Ride ride;
  final String? driverName;
  final String? driverPhone;
}
