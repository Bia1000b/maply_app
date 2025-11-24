import 'package:floor/floor.dart';

@entity
class Place {
  @primaryKey
  final int id;
  final String name;
  final String location;
  final bool favorite;
  final double latitude;
  final double longitude;
  final String description;
  final String category;

  Place({
    required this.id,
    required this.name,
    required this.location,
    required this.favorite,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.category,
  });
}
