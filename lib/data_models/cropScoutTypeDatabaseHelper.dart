//import 'dart:io';
//import 'package:sqflite/sqflite.dart';
//import 'package:path_provider/path_provider.dart';
//import 'package:path/path.dart';
//
//class DatabaseHelper {
//  static final _dbName = 'agscoutdb.db';
//  static final dbVersion = 1;
//  static final _cropScoutTypeDataTable = 'cropScoutTyeDataTable';
//
//  ///Scout type
//  static final scoutTypeId = '_scoutTypeId';
//  static final scoutType = 'scoutType';
//  static final scoutTypeCreatedDate = '_scoutTypeCreatedDate';
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
//            _onCropScoutTypeCreate); // onCreate is what to do when the db is created
//  }
//
//  Future _onCropScoutTypeCreate(Database db, int version) {
//    db.execute('''
//    CREATE TABLE $_cropScoutTypeDataTable(
//    $scoutTypeId INTEGER,
//    $scoutType TEXT,
//    $scoutTypeCreatedDate TEXT )
//       ''');
//  }
//
//  // Insert function
//  Future<int> insert(Map<String, dynamic> row) async {
//    // call the get database function first
//    Database db = await instance.database;
//    //Insert value and return the unique id or primary key.
//    return await db.insert(_cropScoutTypeDataTable, row);
//  }
//
//  // Query Function
//  Future<List<Map<String, dynamic>>> queryAll() async {
//    Database db = await instance.database;
//    return await db.query(_cropScoutTypeDataTable);
//  }
//
//  // Get one object from db
//  Future<List<Map<String, dynamic>>> queryOne(int id) async {
//    Database db = await instance.database;
//
//    return await db.query(_cropScoutTypeDataTable,
//        where: '$scoutTypeId=?', whereArgs: [id]);
//  }
//
//  // Update the object
//  Future<int> update(Map<String, dynamic> row) async {
//    // call the get database function first
//    Database db = await instance.database;
//    // Update value by id and return it or primary key.
//    int id = row[scoutTypeId];
//    return db.update(_cropScoutTypeDataTable, row,
//        where: '$scoutTypeId=?', whereArgs: [id]);
//  }
//
//  // Delete the object.
//  Future<int> delete(int id) async {
//    Database db = await instance.database;
//    return await db.delete(_cropScoutTypeDataTable,
//        where: '$scoutTypeId=?', whereArgs: [id]);
//  }
//}
