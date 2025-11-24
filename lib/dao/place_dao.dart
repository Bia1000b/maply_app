import 'package:floor/floor.dart';
import '../models/place.dart';

@dao
abstract class PlaceDao {
  @Query('SELECT * FROM Place')
  Future<List<Place>> findAllPlaces();

  @Query('SELECT * FROM Place WHERE id = :id')
  Future<Place?> findPlaceById(int id);

  @insert
  Future<void> insertPlace(Place place);

  @delete
  Future<void> deletePlace(Place place);
}