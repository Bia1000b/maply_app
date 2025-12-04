import 'package:floor/floor.dart';
import '../models/visit.dart';

@dao
abstract class VisitDao {

  @Query('SELECT * FROM Visit')
  Future<List<Visit>> findAllVisits();

  @Query('SELECT * FROM Visit WHERE placeId = :placeId')
  Future<List<Visit>> findVisitsByPlaceId(int placeId);

  @insert
  Future<int> insertVisit(Visit visit);

  @update
  Future<int> updateVisit(Visit visit);

  @delete
  Future<void> deleteVisit(Visit visit);
}