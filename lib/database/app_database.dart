import 'dart:async';
import 'package:floor/floor.dart';
import '../models/visit.dart';
import '../models/picture.dart';
import '../dao/visit_dao.dart';
import '../dao/picture_dao.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

// This part directive tells Floor where to generate the code
part 'app_database.g.dart';

@Database(version: 1, entities: [Visit, Picture])
abstract class AppDatabase extends FloorDatabase {
  VisitDao get visitDao;
  PictureDao get pictureDao;
}