import 'package:floor/floor.dart';
import '../models/picture.dart';

@dao
abstract class PictureDao {
  @Query('SELECT * FROM Picture WHERE visitId = :visitId')
  Future<List<Picture>> findPicturesByVisitId(int visitId);

  @insert
  Future<void> insertPicture(Picture picture);

  @delete
  Future<void> deletePicture(Picture picture);
}