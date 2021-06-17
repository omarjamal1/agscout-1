import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class CropTypeDatabaseHelper {
  static final _dbName = 'agscoutdb.db';
  static final dbVersion = 2;
  static final _cropTypeDataTable = 'cropTypeDataTable';

  ///Crop Type
  static final cropTypeId = '_cropTypeId';
  static final cropType = 'cropType';
  static final cropTypeCreatedDate = 'cropTypeCreatedDate';

  // Private constructor
  CropTypeDatabaseHelper._privateConstructor();
  static final CropTypeDatabaseHelper instance =
      CropTypeDatabaseHelper._privateConstructor();

  static Database _database;

  Future<Database> get database async {
    // check if database exists return it else initiate database.
    if (_database != null) return _database;
    _database = await _initiateDatabase();
    return _database;
  }

  _initiateDatabase() async {
    // Initiate database function.
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(
        directory.path, _dbName); // Join the file path with the database name
    return await openDatabase(path,
        version: dbVersion,
        onCreate:
            _onCropTypeCreate); // onCreate is what to do when the db is created
  }

  Future _onCropTypeCreate(Database db, int version) {
    db.execute('''
    CREATE TABLE $_cropTypeDataTable(
    $cropTypeId INTEGER,
    $cropType TEXT,
    $cropTypeCreatedDate TEXT )
       ''');
  }

  // Insert function
  Future<int> insert(Map<String, dynamic> row) async {
    // call the get database function first
    Database db = await instance.database;
    //Insert value and return the unique id or primary key.
    return await db.insert(_cropTypeDataTable, row);
  }

  // Query Function
  Future<List<Map<String, dynamic>>> queryAll() async {
    Database db = await instance.database;
    return await db.query(_cropTypeDataTable);
  }

  // Get one object from db
  Future<List<Map<String, dynamic>>> queryOne(int id) async {
    Database db = await instance.database;

    return await db
        .query(_cropTypeDataTable, where: '$cropTypeId=?', whereArgs: [id]);
  }

  // Update the object
  Future<int> update(Map<String, dynamic> row) async {
    // call the get database function first
    Database db = await instance.database;
    // Update value by id and return it or primary key.
    int id = row[cropTypeId];
    return db.update(_cropTypeDataTable, row,
        where: '$cropTypeId=?', whereArgs: [id]);
  }

  // Delete the object.
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db
        .delete(_cropTypeDataTable, where: '$cropTypeId=?', whereArgs: [id]);
  }
}
//
//class CropTypeDatabaseHelper {
//  static const CROP_TYPE_TABLE_NAME = '_cropScoutTypeDataTable';
//  static final CropTypeDatabaseHelper _instance =
//      CropTypeDatabaseHelper._internal();
//  factory CropTypeDatabaseHelper() => _instance;
//  static Database _db;
//
//  Future<Database> initD() async {
//    var databasePath = await getDatabasesPath();
//    String path = join(databasePath, 'agscoutdb.db');
//  }
//}
