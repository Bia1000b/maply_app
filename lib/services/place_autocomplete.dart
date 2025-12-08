import 'dart:convert';
import 'package:http/http.dart' as http;

class PlaceSuggestion {
  final String description;
  final String? placeId;
  final double? lat;
  final double? lng;

  PlaceSuggestion({
    required this.description,
    this.placeId,
    this.lat,
    this.lng,
  });
}

/// Service que usa Google Places Autocomplete ou OSM Nominatim
class PlaceAutocompleteService {
  final String? googleApiKey; // se a key for nula, usa o Nominatim
  PlaceAutocompleteService({this.googleApiKey});

  Future<List<PlaceSuggestion>> fetch(
    String input, {
    String countryCode = '',
  }) async {
    if (input.trim().isEmpty) return [];

    if (googleApiKey != null && googleApiKey!.isNotEmpty) {
      try {
        final sessionToken = DateTime.now().millisecondsSinceEpoch.toString();
        final url = Uri.https(
          'maps.googleapis.com',
          '/maps/api/place/autocomplete/json',
          {
            'input': input,
            'key': googleApiKey!,
            'sessiontoken': sessionToken,
            'components': countryCode.isNotEmpty
                ? 'country:$countryCode'
                : null,
          }..removeWhere((k, v) => v == null),
        );
        final resp = await http.get(url);
        if (resp.statusCode == 200) {
          final j = json.decode(resp.body);
          if (j['status'] == 'OK') {
            final preds = (j['predictions'] as List)
                .map(
                  (p) => PlaceSuggestion(
                    description: p['description'],
                    placeId: p['place_id'],
                  ),
                )
                .toList();
            return preds;
          }
        }
      } catch (_) {}
    }

    // Fallback: OSM Nominatim
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(input)}&format=json&limit=6&addressdetails=0',
      );
      final resp = await http.get(
        url,
        headers: {'User-Agent': 'maply_app/1.0'},
      );
      if (resp.statusCode == 200) {
        final j = json.decode(resp.body) as List;
        return j
            .map(
              (e) => PlaceSuggestion(
                description: e['display_name'] as String,
                lat: double.tryParse(e['lat'].toString()),
                lng: double.tryParse(e['lon'].toString()),
              ),
            )
            .toList();
      }
    } catch (_) {}

    return [];
  }

  /// Se usando Google, obter detalhes do lugar (lat/lng) pelo placeId
  Future<PlaceSuggestion?> getPlaceDetails(String placeId) async {
    if (googleApiKey == null || googleApiKey!.isEmpty) return null;
    try {
      final url =
          Uri.https('maps.googleapis.com', '/maps/api/place/details/json', {
            'place_id': placeId,
            'key': googleApiKey!,
            'fields': 'name,formatted_address,geometry',
          });
      final resp = await http.get(url);
      if (resp.statusCode == 200) {
        final j = json.decode(resp.body);
        if (j['status'] == 'OK') {
          final result = j['result'];
          final loc = result['geometry']?['location'];
          return PlaceSuggestion(
            description: result['formatted_address'] ?? result['name'],
            placeId: placeId,
            lat: loc != null ? (loc['lat'] as num).toDouble() : null,
            lng: loc != null ? (loc['lng'] as num).toDouble() : null,
          );
        }
      }
    } catch (_) {}
    return null;
  }
}
