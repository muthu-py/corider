import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:co_rider/models/location_suggestion.dart';

class LocationService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org/search';
  
  // Singleton pattern
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// Search for locations in Chennai.
  /// 
  /// Appends ", Chennai" to the query to restrict results.
  /// Returns a list of [LocationSuggestion].
  Future<List<LocationSuggestion>> searchLocations(String query) async {
    if (query.trim().isEmpty) return [];

    // Relaxing suffix to 'Tamil Nadu' to capture Greater Chennai areas (e.g. Kilambakkam)
    final String searchContainer = '${query.trim()}, Tamil Nadu, India';
    
    final Uri uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'q': searchContainer,
      'format': 'json',
      'addressdetails': '1',
      'limit': '5',
    });

    try {
      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'corider-app', // Required by Nominatim
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => LocationSuggestion.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load locations: ${response.statusCode}');
      }
    } catch (e) {
      // In a production app, you might log this error to a monitoring service
      print('Error searching locations: $e');
      return []; // Return empty list on error to handle gracefully
    }
  }
}
