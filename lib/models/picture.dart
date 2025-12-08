import 'package:floor/floor.dart';
import 'visit.dart';

@Entity(
    tableName: 'Picture',
    foreignKeys: [
      ForeignKey(
          childColumns: ['visitId'],
          parentColumns: ['id'],
          entity: Visit,
          onDelete: ForeignKeyAction.cascade
      )
    ]
)
class Picture {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final int visitId;
  final String filePath;
  final String description;

  Picture({
    this.id,
    required this.visitId,
    required this.filePath,
    required this.description,
  });
}