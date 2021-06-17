//import 'dart:io';
//import 'package:sqflite/sqflite.dart';
//import 'package:path_provider/path_provider.dart';
//import 'package:path/path.dart';
//
//class FarmDatabaseHelper {
//  static final _dbName = 'agscoutdb.db';
//  static final dbVersion = 1;
//  static final _farmDataTable = 'farmDataTable';
//
//  /// Columns for  Farm Table
//  static final farmOrgId = 'farmOrgId';
//  static final farmId = '_farmId';
//  static final farmName = 'farmName';
//  static final farmLocation = 'farmLocation';
//  static final farmUser = 'farmUser';
//  static final plotCount = 'plotCount';
//  static final farmCreatedDate = 'farmCreatedDate';
//
//  // Private constructor
//  FarmDatabaseHelper._privateConstructor();
//  static final FarmDatabaseHelper instance =
//      FarmDatabaseHelper._privateConstructor();
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
//        onCreate: _onCreate); // onCreate is what to do when the db is created
//  }
//
//  Future _onCreate(Database db, int version) {
//    // Create Table for Farm
//    db.execute('''
//    CREATE TABLE $_farmDataTable(
//    $farmId INTEGER,
//    $farmOrgId TEXT,
//    $farmName TEXT,
//    $farmLocation TEXT,
//    $farmUser TEXT,
//    $plotCount TEXT,
//    $farmCreatedDate TEXT )
//       ''');
//  }
//
//  /// Farm DB functions.
//  // Insert Farm db function.
//  Future<int> insertFarmData(Map<String, dynamic> row) async {
//    // Call the get database function first
//    Database db = await instance.database;
//    // Insert value and return the unique id or primary key.
//    return await db.insert(_farmDataTable, row);
//  }
//
//  // Check to see if Farm table exists at the time of refreshing and
//  // reinserting data From the api.
//  Future _dropFarmTableIfExistsThenReCreate(Database db, int version) async {
//    // Here we execute a query to drop the table if exists which is called "tableName"
//    // and could be given as method's input parameter too
//    await db.execute("DROP TABLE IF EXISTS $_farmDataTable");
//
//    // And finally here we recreate our beloved "tableName" again which needs
//    // some columns initialization
//    await db.execute('''CREATE TABLE $_farmDataTable (
//        $farmId INTEGER,
//        $farmOrgId TEXT,
//        $farmName TEXT,
//        $farmLocation TEXT,
//        $farmUser TEXT,
//        $plotCount TEXT,
//        $farmCreatedDate TEXT )
//        ''');
//  }
//
//  // Query Farm Function
//  Future<List<Map<String, dynamic>>> queryFarmAll() async {
//    Database db = await instance.database;
//    return await db.query(_farmDataTable);
//  }
//
//  // Call the drop crop table if exists
//  Future deleteFarmTable() async {
//    Database db = await instance.database;
//    _dropFarmTableIfExistsThenReCreate(db, dbVersion);
//  }
//}
