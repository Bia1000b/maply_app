import 'dart:async';
import 'package:floor/floor.dart';
import '../models/place.dart';
import '../models/visit.dart';
import '../models/picture.dart';
import '../dao/place_dao.dart';
import '../dao/visit_dao.dart';
import '../dao/picture_dao.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

// This part directive tells Floor where to generate the code
part 'app_database.g.dart';

@Database(version: 1, entities: [Place, Visit, Picture])
abstract class AppDatabase extends FloorDatabase {
  PlaceDao get placeDao;
  VisitDao get visitDao;
  PictureDao get pictureDao;
}