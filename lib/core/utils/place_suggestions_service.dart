import 'dart:convert';
import 'package:http/http.dart' as http;

class PlaceSuggestion {
  final String description;
  final String placeId;

  PlaceSuggestion({required this.description, required this.placeId});
}

class PlaceSuggestionsService {
  final String apiKey;

  PlaceSuggestionsService(this.apiKey);

  Future<List<PlaceSuggestion>> fetchSuggestions(String input) async {
    // Center on Cairo, Egypt for better results
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&types=geocode&key=$apiKey&location=30.0444,31.2357&radius=50000&components=country:eg',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        final List predictions = data['predictions'];
        // For each prediction, fetch its coordinates
        List<PlaceSuggestion> suggestions = [];
        for (final item in predictions) {
          final placeId = item['place_id'];
          final description = item['description'];
          // Fetch details for lat/lng
          final details = await fetchPlaceDetails(placeId);
          if (details != null) {
            suggestions.add(
              PlaceSuggestion(
                description: description,
                placeId: placeId,
              ),
            );
          }
        }
        return suggestions;
      }
    }
    return [];
  }

  Future<Map<String, dynamic>?> fetchPlaceDetails(String placeId) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=geometry,name,formatted_address&key=$apiKey',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        final result = data['result'];
        final location = result['geometry']['location'];
        return {
          'name': result['name'],
          'address': result['formatted_address'],
          'lat': location['lat'] as double,
          'lng': location['lng'] as double,
        };
      }
    }
    return null;
  }
} 