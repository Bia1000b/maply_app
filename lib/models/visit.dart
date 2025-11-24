import 'package:floor/floor.dart';

@entity
class Visit {
  @primaryKey
  final int id;
  final int placeId; // Foreign key to Place
  final String description;
  final double rating; // Rating out of 5
  final String date;

  Visit({
    required this.id,
    required this.placeId,
    required this.description,
    required this.rating,
    required this.date,
  });
}
