import 'dart:math' as math;

import 'package:co_rider/models/location_suggestion.dart';
import 'package:co_rider/models/ride.dart';
import 'package:co_rider/services/ride_service.dart';
import 'package:co_rider/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RideResultsArgs {
  RideResultsArgs({
    required this.rides,
    required this.from,
    required this.to,
    required this.departureTime,
    required this.timeWindowMinutes,
    required this.seats,
  });

  final List<Ride> rides;
  final LocationSuggestion from;
  final LocationSuggestion to;
  final DateTime departureTime;
  final int timeWindowMinutes;
  final int seats;
}

class RideResultsScreen extends StatefulWidget {
  const RideResultsScreen({super.key});

  @override
  State<RideResultsScreen> createState() => _RideResultsScreenState();
}

class _RideResultsScreenState extends State<RideResultsScreen> {
  final RideService _rideService = RideService();
  final Set<String> _bookingRideIds = {};
  bool _initialized = false;
  List<Ride> _rides = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is RideResultsArgs) {
      _rides = List<Ride>.from(args.rides);
    }
    _initialized = true;
  }

  Future<void> _bookRide(Ride ride, RideResultsArgs data) async {
    final rideId = ride.id;
    if (rideId == null) return;

    setState(() => _bookingRideIds.add(rideId));

    try {
      final updatedRide = await _rideService.bookRide(
        rideId: rideId,
        seatsToBook: data.seats,
      );

      if (!mounted) return;

      setState(() {
        final index = _rides.indexWhere((r) => r.id == rideId);
        if (index != -1) {
          _rides[index] = updatedRide;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ride booked successfully.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _bookingRideIds.remove(rideId));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final data = args is RideResultsArgs ? args : null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Available Rides'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () => ThemeController().toggleTheme(),
          ),
        ],
      ),
      body: data == null
          ? const Center(child: Text('No search data found.'))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Text(
                    '${data.from.name.split(',').first} -> ${data.to.name.split(',').first}  |  '
                    '${DateFormat('MMM d, h:mm a').format(data.departureTime)}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                Expanded(
                  child: _rides.isEmpty
                      ? const Center(
                          child: Text(
                            'No matching rides found.\nTry increasing time window.',
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _rides.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final ride = _rides[index];
                            final sourceDistanceKm = _distanceKm(
                              data.from.lat,
                              data.from.lon,
                              ride.sourceLat,
                              ride.sourceLon,
                            );
                            final destinationDistanceKm = _distanceKm(
                              data.to.lat,
                              data.to.lon,
                              ride.destinationLat,
                              ride.destinationLon,
                            );

                            final rideId = ride.id;
                            final isBooking =
                                rideId != null && _bookingRideIds.contains(rideId);
                            final canBook =
                                !isBooking && ride.availableSeats >= data.seats;

                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          DateFormat('EEE, MMM d • h:mm a')
                                              .format(ride.departureTime),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            '${ride.availableSeats}/${ride.totalSeats} seats',
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      ride.sourceName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      ride.destinationName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Pickup distance: ${sourceDistanceKm.toStringAsFixed(2)} km | '
                                      'Drop distance: ${destinationDistanceKm.toStringAsFixed(2)} km',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: canBook
                                            ? () => _bookRide(ride, data)
                                            : null,
                                        child: isBooking
                                            ? const SizedBox(
                                                width: 16,
                                                height: 16,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : Text(canBook
                                                ? 'Book Ride'
                                                : 'Not enough seats'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  double _distanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadiusKm * c;
  }

  double _toRadians(double degree) => degree * math.pi / 180.0;
}
