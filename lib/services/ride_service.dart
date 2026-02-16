import 'dart:math' as math;

import 'package:co_rider/models/location_suggestion.dart';
import 'package:co_rider/models/ride_booking.dart';
import 'package:co_rider/models/ride_passenger_booking.dart';
import 'package:co_rider/models/ride.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RideService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> createRide(Ride ride) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw 'User is not logged in';
    }

    // Ensure the ride driver_id matches the current user
    if (ride.driverId != user.id) {
      throw 'Driver ID does not match current user';
    }

    try {
      await _supabase.from('rides').insert(ride.toJson());
    } catch (e) {
      throw 'Failed to create ride: $e';
    }
  }

  Future<List<Ride>> getRidesForDriver(String driverId) async {
    try {
      final response = await _supabase
          .from('rides')
          .select()
          .eq('driver_id', driverId)
          .order('departure_time', ascending: false);

      return (response as List).map((json) => Ride.fromJson(json)).toList();
    } catch (e) {
      throw 'Failed to fetch rides: $e';
    }
  }

  Future<Map<String, int>> getBookingCountsForRideIds(List<String> rideIds) async {
    if (rideIds.isEmpty) return {};

    try {
      final response = await _supabase
          .from('ride_bookings')
          .select('ride_id,seats_booked')
          .eq('status', 'CONFIRMED')
          .inFilter('ride_id', rideIds);

      final rows = (response as List).cast<Map<String, dynamic>>();
      final counts = <String, int>{};

      for (final row in rows) {
        final rideId = row['ride_id'] as String?;
        if (rideId == null) continue;
        final seatsBooked = (row['seats_booked'] as int?) ?? 0;
        counts[rideId] = (counts[rideId] ?? 0) + seatsBooked;
      }

      return counts;
    } catch (e) {
      throw 'Failed to fetch booking counts: $e';
    }
  }

  Future<List<RideBooking>> getBookingsForPassenger(String passengerId) async {
    try {
      final bookingsResponse = await _supabase
          .from('ride_bookings')
          .select('id,ride_id,passenger_id,seats_booked,status,created_at')
          .eq('passenger_id', passengerId)
          .order('created_at', ascending: false);

      final bookingRows = (bookingsResponse as List).cast<Map<String, dynamic>>();
      if (bookingRows.isEmpty) return [];

      final rideIds = bookingRows
          .map((e) => e['ride_id'] as String?)
          .whereType<String>()
          .toSet()
          .toList();

      final ridesResponse = await _supabase
          .from('rides')
          .select()
          .inFilter('id', rideIds);

      final rideRows = (ridesResponse as List).cast<Map<String, dynamic>>();
      final ridesById = <String, Ride>{};
      for (final row in rideRows) {
        final ride = Ride.fromJson(row);
        if (ride.id != null) {
          ridesById[ride.id!] = ride;
        }
      }

      final driverIds =
          ridesById.values.map((r) => r.driverId).toSet().toList();
      final profilesById = await _getUserProfilesByIds(driverIds);

      final result = <RideBooking>[];
      for (final row in bookingRows) {
        final rideId = row['ride_id'] as String?;
        if (rideId == null) continue;
        final ride = ridesById[rideId];
        if (ride == null) continue;
        final driverProfile = profilesById[ride.driverId];

        result.add(
          RideBooking(
            id: row['id'] as String,
            rideId: rideId,
            passengerId: row['passenger_id'] as String,
            seatsBooked: (row['seats_booked'] as int?) ?? 0,
            status: (row['status'] as String?) ?? 'CONFIRMED',
            createdAt: DateTime.parse(row['created_at'] as String),
            ride: ride,
            driverName: driverProfile?['full_name'] as String?,
            driverPhone: driverProfile?['phone'] as String?,
          ),
        );
      }

      return result;
    } catch (e) {
      throw 'Failed to fetch bookings: $e';
    }
  }

  Future<Map<String, List<RidePassengerBooking>>> getPassengerBookingsForRideIds(
    List<String> rideIds,
  ) async {
    if (rideIds.isEmpty) return {};

    try {
      final response = await _supabase
          .from('ride_bookings')
          .select('id,ride_id,passenger_id,seats_booked,status,created_at')
          .eq('status', 'CONFIRMED')
          .inFilter('ride_id', rideIds)
          .order('created_at', ascending: false);

      final rows = (response as List).cast<Map<String, dynamic>>();
      if (rows.isEmpty) return {};

      final passengerIds = rows
          .map((e) => e['passenger_id'] as String?)
          .whereType<String>()
          .toSet()
          .toList();
      final profilesById = await _getUserProfilesByIds(passengerIds);

      final grouped = <String, List<RidePassengerBooking>>{};
      for (final row in rows) {
        final rideId = row['ride_id'] as String?;
        final passengerId = row['passenger_id'] as String?;
        if (rideId == null || passengerId == null) continue;

        final profile = profilesById[passengerId];
        final booking = RidePassengerBooking(
          id: row['id'] as String,
          rideId: rideId,
          passengerId: passengerId,
          seatsBooked: (row['seats_booked'] as int?) ?? 0,
          status: (row['status'] as String?) ?? 'CONFIRMED',
          createdAt: DateTime.parse(row['created_at'] as String),
          passengerName: profile?['full_name'] as String?,
          passengerPhone: profile?['phone'] as String?,
        );
        grouped.putIfAbsent(rideId, () => []).add(booking);
      }

      return grouped;
    } catch (e) {
      throw 'Failed to fetch passenger bookings: $e';
    }
  }

  Future<Map<String, Map<String, dynamic>>> _getUserProfilesByIds(
    List<String> userIds,
  ) async {
    if (userIds.isEmpty) return {};

    final response = await _supabase
        .from('users')
        .select('id,full_name,phone')
        .inFilter('id', userIds);

    final rows = (response as List).cast<Map<String, dynamic>>();
    final map = <String, Map<String, dynamic>>{};
    for (final row in rows) {
      final id = row['id'] as String?;
      if (id == null) continue;
      map[id] = row;
    }
    return map;
  }

  Future<void> cancelRide(String rideId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw 'User is not logged in';
    }

    try {
      final updatedRows = await _supabase
          .from('rides')
          .update({'status': RideStatus.cancelled.name.toUpperCase()})
          .eq('id', rideId)
          .eq('driver_id', user.id)
          .select('id,status');

      if (updatedRows is! List || updatedRows.isEmpty) {
        throw 'No rows updated (likely blocked by RLS UPDATE policy or ride ownership mismatch).';
      }

      final first = updatedRows.first as Map<String, dynamic>;
      final status = (first['status'] as String?)?.toUpperCase();
      if (status != RideStatus.cancelled.name.toUpperCase()) {
        throw 'Status verification failed after update.';
      }
    } catch (e) {
      throw 'Failed to cancel ride: $e';
    }
  }

  Future<Ride> bookRide({
    required String rideId,
    int seatsToBook = 1,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw 'User is not logged in';
    }

    if (seatsToBook <= 0) {
      throw 'Invalid seat count.';
    }

    try {
      await _supabase.rpc(
        'book_ride',
        params: {
          'p_ride_id': rideId,
          'p_seats': seatsToBook,
        },
      );

      final refreshedRows = await _supabase
          .from('rides')
          .select()
          .eq('id', rideId)
          .limit(1);

      if (refreshedRows is! List || refreshedRows.isEmpty) {
        throw 'Booking succeeded but ride refresh failed.';
      }

      return Ride.fromJson(refreshedRows.first as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      throw 'Booking failed: ${e.message}';
    } catch (e) {
      throw 'Failed to book ride: $e';
    }
  }

  Future<List<Ride>> searchRides({
    required LocationSuggestion source,
    required LocationSuggestion destination,
    required DateTime departureTime,
    required double maxDistanceKm,
    required Duration timeWindow,
    int requiredSeats = 1,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      final windowStart = departureTime.subtract(timeWindow).toIso8601String();
      final windowEnd = departureTime.add(timeWindow).toIso8601String();

      dynamic query = _supabase
          .from('rides')
          .select()
          .eq('status', RideStatus.active.name.toUpperCase())
          .gte('available_seats', requiredSeats)
          .gte('departure_time', windowStart)
          .lte('departure_time', windowEnd)
          .order('departure_time', ascending: true);

      final response = await query;
      final rides = (response as List).map((json) => Ride.fromJson(json)).toList();

      final filtered = rides.where((ride) {
        if (user != null && ride.driverId == user.id) {
          return false;
        }

        final sourceDistance = _distanceKm(
          source.lat,
          source.lon,
          ride.sourceLat,
          ride.sourceLon,
        );
        final destinationDistance = _distanceKm(
          destination.lat,
          destination.lon,
          ride.destinationLat,
          ride.destinationLon,
        );

        return sourceDistance <= maxDistanceKm &&
            destinationDistance <= maxDistanceKm;
      }).toList();

      filtered.sort((a, b) {
        final aScore = _rankingScore(
          ride: a,
          source: source,
          destination: destination,
          targetTime: departureTime,
        );
        final bScore = _rankingScore(
          ride: b,
          source: source,
          destination: destination,
          targetTime: departureTime,
        );
        return aScore.compareTo(bScore);
      });

      return filtered;
    } catch (e) {
      throw 'Failed to search rides: $e';
    }
  }

  double _rankingScore({
    required Ride ride,
    required LocationSuggestion source,
    required LocationSuggestion destination,
    required DateTime targetTime,
  }) {
    final sourceDistance = _distanceKm(
      source.lat,
      source.lon,
      ride.sourceLat,
      ride.sourceLon,
    );
    final destinationDistance = _distanceKm(
      destination.lat,
      destination.lon,
      ride.destinationLat,
      ride.destinationLon,
    );
    final minutesDiff =
        (ride.departureTime.difference(targetTime).inMinutes).abs().toDouble();

    return sourceDistance + destinationDistance + (minutesDiff / 30.0);
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
