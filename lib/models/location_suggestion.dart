class LocationSuggestion {
  final String name;
  final double lat;
  final double lon;

  LocationSuggestion({
    required this.name,
    required this.lat,
    required this.lon,
  });

  factory LocationSuggestion.fromJson(Map<String, dynamic> json) {
    return LocationSuggestion(
      name: json['display_name'] as String,
      lat: double.parse(json['lat'] as String),
      lon: double.parse(json['lon'] as String),
    );
  }

  @override
  String toString() => 'LocationSuggestion(name: $name, lat: $lat, lon: $lon)';
}
