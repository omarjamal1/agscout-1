//import 'dart:io';
//import 'package:sqflite/sqflite.dart';
//import 'package:path_provider/path_provider.dart';
//import 'package:path/path.dart';
//
//class DatabaseHelper {
//  static final _dbName = 'agscoutdb.db';
//  static final dbVersion = 1;
//  static final _cropScoutDataTable = 'cropScoutDataTable';
//
//  // Columns for Crop Scout Table
//  static final scoutPlotId = 'scoutPlotId';
//  static final cropScoutId = '_plotId';
//  static final typeOfScout = 'typeOfScout';
//  static final rowNumber = 'rowNumber';
//  static final plantNumber = 'plantNumber';
//  static final numberOfLaterals = 'numberOfLaterals';
//  static final numberOfBranches = 'numberOfBranches';
//  static final numberOfCounts = 'numberOfCounts';
//  static final cropImage = 'cropImage';
//  static final lat = 'lat';
//  static final lon = 'lon';
//  static final accuracy = 'accuracy';
//  static final scoutedDate = 'scoutedDate';
//  static final user = 'user';
//  static final createdDate = 'createdDate';
//
//  // Private constructor
//  DatabaseHelper._privateConstructor();
//  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
//
//  static Database _database;
//
//  Future<Database> get database async {
//    // check if database exists return it else initiate database.
//    if (_database != null) return _database;
//    _database = await _initiateDatabase();
//    return _database;
//  }
//
//  _initiateDatabase() async {
//    // Initiate database function.
//    Directory directory = await getApplicationDocumentsDirectory();
//    String path = join(
//        directory.path, _dbName); // Join the file path with the database name
//    return await openDatabase(path,
//        version: dbVersion,
//        onCreate:
//            _onCropScoutCreate); // onCreate is what to do when the db is created
//  }
//
//  Future _onCropScoutCreate(Database db, int version) {
//    db.execute('''
//    CREATE TABLE $_cropScoutDataTable(
//    $cropScoutId INTEGER,
//    $scoutPlotId TEXT,
//    $typeOfScout TEXT,
//    $rowNumber TEXT,
//    $plantNumber TEXT,
//    $numberOfLaterals TEXT,
//    $numberOfBranches TEXT,
//    $numberOfCounts TEXT,
//    $cropImage TEXT,
//    $lat TEXT,
//    $lon TEXT,
//    $user TEXT,
//    $createdDate TEXT )
//       ''');
//  }
//
//  // Insert function
//  Future<int> insert(Map<String, dynamic> row) async {
//    // call the get database function first
//    Database db = await instance.database;
//    //Insert value and return the unique id or primary key.
//    return await db.insert(_cropScoutDataTable, row);
//  }
//
//  // Query Function
//  Future<List<Map<String, dynamic>>> queryAll() async {
//    Database db = await instance.database;
//    return await db.query(_cropScoutDataTable);
//  }
//
//  // Get one object from db
//  Future<List<Map<String, dynamic>>> queryOne(int id) async {
//    Database db = await instance.database;
//
//    return await db
//        .query(_cropScoutDataTable, where: '$scoutPlotId=?', whereArgs: [id]);
//  }
//
//  // Update the object
//  Future<int> update(Map<String, dynamic> row) async {
//    // call the get database function first
//    Database db = await instance.database;
//    // Update value by id and return it or primary key.
//    int id = row[scoutPlotId];
//    return db.update(_cropScoutDataTable, row,
//        where: '$scoutPlotId=?', whereArgs: [id]);
//  }
//
//  // Delete the object.
//  Future<int> delete(int id) async {
//    Database db = await instance.database;
//    return await db
//        .delete(_cropScoutDataTable, where: '$scoutPlotId=?', whereArgs: [id]);
//  }
//}
