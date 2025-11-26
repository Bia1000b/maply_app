import 'package:floor/floor.dart';

@entity
class Visit {
  @primaryKey
  final int id;
  final String description;
  final double rating; // Rating out of 5
  final String date;
  final String placeName;
  final String placeLocation;
  final String placeDescription;
  final String category;
  final double latitude;
  final double longitude;
  final bool favorite;

  Visit({
    required this.id,
    required this.description,
    required this.rating,
    required this.date,
    required this.placeName,
    required this.placeLocation,
    required this.placeDescription,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.favorite,
  });
}
