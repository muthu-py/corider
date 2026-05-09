
enum RideStatus {
  active,
  full,
  started,
  completed,
  cancelled,
}

class Ride {
  final String? id;
  final String driverId;
  final String sourceName;
  final double sourceLat;
  final double sourceLon;
  final String destinationName;
  final double destinationLat;
  final double destinationLon;
  final DateTime departureTime;
  final int totalSeats;
  final int availableSeats;
  final RideStatus status;
  final DateTime? createdAt;

  Ride({
    this.id,
    required this.driverId,
    required this.sourceName,
    required this.sourceLat,
    required this.sourceLon,
    required this.destinationName,
    required this.destinationLat,
    required this.destinationLon,
    required this.departureTime,
    required this.totalSeats,
    required this.availableSeats,
    this.status = RideStatus.active,
    this.createdAt,
  });

  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride(
      id: json['id'] as String?,
      driverId: json['driver_id'] as String,
      sourceName: json['source_name'] as String,
      sourceLat: (json['source_lat'] as num).toDouble(),
      sourceLon: (json['source_lon'] as num).toDouble(),
      destinationName: json['destination_name'] as String,
      destinationLat: (json['destination_lat'] as num).toDouble(),
      destinationLon: (json['destination_lon'] as num).toDouble(),
      departureTime: DateTime.parse(json['departure_time'] as String),
      totalSeats: json['total_seats'] as int,
      availableSeats: json['available_seats'] as int,
      status: RideStatus.values.firstWhere(
        (e) => e.name.toUpperCase() == (json['status'] as String).toUpperCase(),
        orElse: () => RideStatus.active,
      ),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'driver_id': driverId,
      'source_name': sourceName,
      'source_lat': sourceLat,
      'source_lon': sourceLon,
      'destination_name': destinationName,
      'destination_lat': destinationLat,
      'destination_lon': destinationLon,
      'departure_time': departureTime.toIso8601String(),
      'total_seats': totalSeats,
      'available_seats': availableSeats,
      'status': status.name.toUpperCase(),
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  Ride copyWith({
    String? id,
    String? driverId,
    String? sourceName,
    double? sourceLat,
    double? sourceLon,
    String? destinationName,
    double? destinationLat,
    double? destinationLon,
    DateTime? departureTime,
    int? totalSeats,
    int? availableSeats,
    RideStatus? status,
    DateTime? createdAt,
  }) {
    return Ride(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      sourceName: sourceName ?? this.sourceName,
      sourceLat: sourceLat ?? this.sourceLat,
      sourceLon: sourceLon ?? this.sourceLon,
      destinationName: destinationName ?? this.destinationName,
      destinationLat: destinationLat ?? this.destinationLat,
      destinationLon: destinationLon ?? this.destinationLon,
      departureTime: departureTime ?? this.departureTime,
      totalSeats: totalSeats ?? this.totalSeats,
      availableSeats: availableSeats ?? this.availableSeats,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
