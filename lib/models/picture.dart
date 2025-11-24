import 'package:floor/floor.dart';

@entity
class Picture {
  @primaryKey
  final int id;
  final int visitId; // Foreign key to Visit
  final String filePath; // Path to the image file
  final String description;

  Picture({
    required this.id,
    required this.visitId,
    required this.filePath,
    required this.description,
  });
}