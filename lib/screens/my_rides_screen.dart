import 'package:co_rider/models/ride_passenger_booking.dart';
import 'package:co_rider/models/ride.dart';
import 'package:co_rider/services/auth_service.dart';
import 'package:co_rider/services/ride_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class MyRidesScreen extends StatefulWidget {
  const MyRidesScreen({super.key});

  @override
  State<MyRidesScreen> createState() => _MyRidesScreenState();
}

class _MyRidesScreenState extends State<MyRidesScreen> {
  final RideService _rideService = RideService();
  final AuthService _authService = AuthService();
  
  List<Ride> _rides = [];
  Map<String, int> _bookedSeatsByRideId = {};
  Map<String, List<RidePassengerBooking>> _passengerBookingsByRideId = {};
  final Set<String> _cancellingRideIds = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchRides();
  }

  Future<void> _fetchRides() async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        final rides = await _rideService.getRidesForDriver(user.id);
        final rideIds = rides.map((r) => r.id).whereType<String>().toList();
        final bookingCounts = await _rideService.getBookingCountsForRideIds(rideIds);
        final passengerBookings =
            await _rideService.getPassengerBookingsForRideIds(rideIds);
        if (mounted) {
          setState(() {
            _rides = rides;
            _bookedSeatsByRideId = bookingCounts;
            _passengerBookingsByRideId = passengerBookings;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _cancelRide(String rideId) async {
    final rideIndex = _rides.indexWhere((r) => r.id == rideId);
    if (rideIndex == -1) return;

    final originalRide = _rides[rideIndex];

    setState(() {
      _cancellingRideIds.add(rideId);
      _rides[rideIndex] = _rides[rideIndex].copyWith(status: RideStatus.cancelled);
    });

    try {
      await _rideService.cancelRide(rideId);
      await _fetchRides();
      
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ride cancelled successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        final currentIndex = _rides.indexWhere((r) => r.id == rideId);
        setState(() {
          if (currentIndex != -1) {
            _rides[currentIndex] = originalRide;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cancelling ride: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _cancellingRideIds.remove(rideId);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Rides'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _rides.isEmpty
                  ? const Center(child: Text('You haven\'t created any rides yet.'))
                  : RefreshIndicator(
                      onRefresh: _fetchRides,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _rides.length,
                        itemBuilder: (context, index) {
                          final ride = _rides[index];
                          return _buildRideCard(ride);
                        },
                      ),
                    ),
    );
  }

  Widget _buildRideCard(Ride ride) {
    final rideId = ride.id;
    final bookedSeats = rideId == null ? 0 : (_bookedSeatsByRideId[rideId] ?? 0);
    final isCancelled = ride.status == RideStatus.cancelled;
    final isCompleted = ride.status == RideStatus.completed;
    final isCancelling = rideId != null && _cancellingRideIds.contains(rideId);
    final canCancel = !isCancelled && !isCompleted && !isCancelling;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusChip(ride.status),
                Text(
                  DateFormat('MMM d, h:mm a').format(ride.departureTime),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.circle, size: 12, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ride.sourceName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(left: 6),
              child: SizedBox(
                height: 20,
                child: VerticalDivider(width: 2, thickness: 2, color: Colors.grey),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.location_on, size: 12, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ride.destinationName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${ride.totalSeats} Seats'),
                if (bookedSeats > 0)
                  TextButton.icon(
                    onPressed: () {
                      if (rideId == null) return;
                      _showPassengerContacts(rideId);
                    },
                    icon: const Icon(Icons.group, size: 18),
                    label: Text('$bookedSeats booked'),
                  ),
                if (isCancelling)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                if (canCancel)
                  TextButton.icon(
                    onPressed: () => _showCancelConfirmation(ride.id!),
                    icon: const Icon(Icons.cancel_outlined, color: Colors.red, size: 20),
                    label: const Text('Cancel', style: TextStyle(color: Colors.red)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelConfirmation(String rideId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Ride?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelRide(rideId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _showPassengerContacts(String rideId) {
    final bookings = _passengerBookingsByRideId[rideId] ?? [];

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        if (bookings.isEmpty) {
          return const SizedBox(
            height: 120,
            child: Center(child: Text('No passenger contacts found.')),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: bookings.length,
          separatorBuilder: (_, __) => const Divider(height: 16),
          itemBuilder: (context, index) {
            final booking = bookings[index];
            final phone = booking.passengerPhone;

            return Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.passengerName ?? 'Passenger',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        phone == null || phone.isEmpty
                            ? 'Phone not available'
                            : phone,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${booking.seatsBooked} seat${booking.seatsBooked > 1 ? 's' : ''}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (phone != null && phone.isNotEmpty)
                  IconButton(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: phone));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Passenger phone copied')),
                        );
                      }
                    },
                    icon: const Icon(Icons.copy, size: 18),
                  ),
              ],
            );
          },
        );
      },
    );
  }
  
  Widget _buildStatusChip(RideStatus status) {
    Color color;
    switch (status) {
      case RideStatus.active:
        color = Colors.green;
        break;
      case RideStatus.cancelled:
        color = Colors.red;
        break;
      case RideStatus.completed:
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}
