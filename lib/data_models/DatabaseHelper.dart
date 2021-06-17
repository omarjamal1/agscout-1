import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final _dbName = 'agscoutdb.db';
  static final dbVersion = 1;
  static final _orgProfileTable = 'organizationTable';
  static final _cropTypeDataTable = 'cropTypeDataTable';
  static final _cropScoutTypeDataTable = 'cropScoutTypeDataTable';
  static final _farmDataTable = 'farmDataTable';
  static final _plotDataTable = 'plotDataTable';
  static final _farmDataQueueTable = 'farmDataQueueTable';
  static final _cropScoutDataTable = 'cropScoutDataTable';
  static final _cropScoutQueueDataTable = 'cropScoutQueueDataTable';

  // Columns or fields for the organization profile table/
  static final orgId = '_Id';
  static final orgName = 'name';
  static final location = 'location';
  static final email = 'email';
  static final address = 'address';
  static final organizationCode = 'organizationCode';
  static final logo = 'logo';
  static final user = 'user';
  static final createdDate = 'createdDate';

  ///Crop Type
  static final cropTypeId = '_cropTypeId';
  static final cropType = 'cropType';
  static final cropTypeCreatedDate = 'cropTypeCreatedDate';

  /// Scout Type
  static final scoutTypeId = '_scoutTypeId';
  static final scoutType = 'scoutType';
  static final scoutTypeCreatedDate = 'scoutTypeCreatedDate';

  /// Columns for  Farm Table
  static final farmOrgId = 'farmOrgId';
  static final farmId = '_farmId';
  static final farmName = 'farmName';
  static final farmLocation = 'farmLocation';
  static final farmUser = 'farmUser';
  static final plotCount = 'plotCount';
  static final farmCreatedDate = 'farmCreatedDate';

  // Columns for  Plot Table
  static final plotFarmId = 'plotFarmId';
  static final plotId = '_plotId';
  static final plotName = 'plotName';
  static final variety = 'variety';
  static final plotCropType = 'plotCropType';
  static final area = 'area';
  static final centroDeCosto = 'centroDeCosto';
  static final plantPerHectare = 'plantPerHectare';
  static final plotUser = 'plotUser';
  static final plotCreatedDate = 'plotCreatedDate';

  // Columns for Crop Scout Table
  static final scoutPlotId = 'scoutPlotId';
  static final scoutId = '_scoutId';
  static final scoutPlotName = 'scoutPlotName';
  static final typeOfScout = 'typeOfScout';
  static final rowNumber = 'rowNumber';
  static final plantNumber = 'plantNumber';
  static final numberOfLaterals = 'numberOfLaterals';
  static final numberOfBranches = 'numberOfBranches';
  static final numberOfCounts = 'numberOfCounts';
  static final cropImage = 'cropImage';
  static final lat = 'lat';
  static final lon = 'lon';
  static final accuracy = 'accuracy';
  static final scoutedDate = 'scoutedDate';
  static final scoutUser = 'scoutUser';

  // Private constructor
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

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
        onCreate: _onCreate); // onCreate is what to do when the db is created
  }

  Future _onCreate(Database db, int version) {
    // Create table for Organization profile
    db.execute('''
    CREATE TABLE $_orgProfileTable(
    $orgId INTEGER,
    $orgName TEXT,
    $location TEXT,
    $email TEXT,
    $address TEXT,
    $organizationCode TEXT,
    $logo TEXT,
    $user TEXT,
    $createdDate TEXT )
       ''');

    // Create Table for Crop type
    db.execute('''
    CREATE TABLE $_cropTypeDataTable(
    $cropTypeId INTEGER,
    $cropType TEXT,
    $cropTypeCreatedDate TEXT )
       ''');

    // Create table for Scout type
    db.execute('''
    CREATE TABLE $_cropScoutTypeDataTable(
    $scoutTypeId INTEGER,
    $scoutType TEXT,
    $scoutTypeCreatedDate TEXT )
       ''');

    // Create Table for Farm
    db.execute('''
    CREATE TABLE $_farmDataTable(
    $farmId INTEGER,
    $farmOrgId TEXT,
    $farmName TEXT,
    $farmLocation TEXT,
    $farmUser TEXT,
    $plotCount TEXT,
    $farmCreatedDate TEXT )
       ''');

    //  Create Farm Data Queue Table
    db.execute('''
    CREATE TABLE $_farmDataQueueTable(
    id INTEGER PRIMARY KEY,
    $farmOrgId TEXT,
    $farmName TEXT,
    $farmLocation TEXT,
    $farmUser TEXT,
    $plotCount TEXT,
    $farmCreatedDate TEXT )
       ''');

    // Plot Data table
    db.execute('''
    CREATE TABLE $_plotDataTable(
    id INTEGER PRIMARY KEY,
    $plotFarmId TEXT,
    $plotId TEXT,
    $plotName TEXT,
    $variety TEXT,
    $plotCropType TEXT,
    $centroDeCosto TEXT,
    $area TEXT,
    $plantPerHectare TEXT,
    $plotUser TEXT,
    $plotCreatedDate TEXT )
       ''');

    // Create Scout Data Table
    db.execute('''
    CREATE TABLE $_cropScoutDataTable(
    id INTEGER PRIMARY KEY,
    $scoutId INTEGER,
    $scoutPlotId TEXT,
    $scoutPlotName TEXT,
    $typeOfScout TEXT,
    $rowNumber TEXT,
    $plantNumber TEXT,
    $numberOfLaterals TEXT,
    $numberOfBranches TEXT,
    $numberOfCounts TEXT,
    $cropImage TEXT,
    $lat TEXT,
    $lon TEXT,
    $accuracy TEXT,
    $scoutUser TEXT,
    $scoutedDate TEXT )
       ''');

    // Create Scout Queue Table
    db.execute('''
    CREATE TABLE $_cropScoutQueueDataTable(
    id INTEGER PRIMARY KEY,
    $scoutId INTEGER,
    $scoutPlotId TEXT,
    $typeOfScout TEXT,
    $rowNumber TEXT,
    $plantNumber TEXT,
    $numberOfLaterals TEXT,
    $numberOfBranches TEXT,
    $numberOfCounts TEXT,
    $cropImage TEXT,
    $lat TEXT,
    $lon TEXT,
    $accuracy TEXT,
    $scoutUser TEXT,
    $scoutedDate TEXT )
       ''');
  }

  /// Organization profile
  // Insert function for organization profile
  Future<int> insert(Map<String, dynamic> row) async {
    // call the get database function first
    Database db = await instance.database;
    //Insert value and return the unique id or primary key.
    return await db.insert(_orgProfileTable, row);
  }

  // Query Function
  Future<List<Map<String, dynamic>>> queryAll() async {
    Database db = await instance.database;
    return await db.query(_orgProfileTable);
  }

  // Get one object from db
  Future<List<Map<String, dynamic>>> queryOne(int id) async {
    Database db = await instance.database;

    return await db.query(_orgProfileTable, where: '$orgId=?', whereArgs: [id]);
  }

  // Update the object
  Future<int> update(Map<String, dynamic> row) async {
    // call the get database function first
    Database db = await instance.database;
    // Update value by id and return it or primary key.
    int id = row[orgId];
    return db.update(_orgProfileTable, row, where: '$orgId=?', whereArgs: [id]);
  }

  // Delete the object.
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db
        .delete(_orgProfileTable, where: '$orgId=?', whereArgs: [id]);
  }

  /// Crop Type DB functions.
  // Insert crop type function
  Future<int> insertCropType(Map<String, dynamic> row) async {
    // call the get database function first
    Database db = await instance.database;
    //Insert value and return the unique id or primary key.
    return await db.insert(_cropTypeDataTable, row);
  }

  // Check to see if Crop type table exists at the time of refreshing and
  // reinserting data From the api.
  Future _dropCropTypeTableIfExistsThenReCreate(
      Database db, int version) async {
    // Here we execute a query to drop the table if exists which is called "cropTypeDataTable"
    //and could be given as method's input parameter too
    await db.execute("DROP TABLE IF EXISTS cropTypeDataTable");

    //and finally here we recreate our beloved "cropTypeDataTable" again which needs
    //some columns initialization
    await db.execute('''CREATE TABLE $_cropTypeDataTable (
        $cropTypeId INTEGER, 
        $cropType TEXT, 
        $cropTypeCreatedDate TEXT)
        ''');
  }

  // Query Crop type Function
  Future<List<Map<String, dynamic>>> queryCropTypeAll() async {
    Database db = await instance.database;
    return await db.query(_cropTypeDataTable);
  }

  // Call the drop crop table if exists
  Future deleteCropTypeTable() async {
    Database db = await instance.database;
    _dropCropTypeTableIfExistsThenReCreate(db, dbVersion);
  }

  /// Scout Type DB functions.
  // Insert scout type function.
  Future<int> insertScoutType(Map<String, dynamic> row) async {
    // Call the get database function first
    Database db = await instance.database;
    // Insert value and return the unique id or primary key.
    return await db.insert(_cropScoutTypeDataTable, row);
  }

  // Check to see if scout type table exists at the time of refreshing and
  // reinserting data From the api.
  Future _dropScoutTypeTableIfExistsThenReCreate(
      Database db, int version) async {
    // Here we execute a query to drop the table if exists which is called "tableName"
    // and could be given as method's input parameter too
    await db.execute("DROP TABLE IF EXISTS $_cropScoutTypeDataTable");

    // And finally here we recreate our beloved "tableName" again which needs
    // some columns initialization
    await db.execute('''CREATE TABLE $_cropScoutTypeDataTable (
        $scoutTypeId INTEGER, 
        $scoutType TEXT, 
        $scoutTypeCreatedDate TEXT)
        ''');
  }

  // Query Scout type Function
  Future<List<Map<String, dynamic>>> queryScoutTypeAll() async {
    Database db = await instance.database;
    return await db.query(_cropScoutTypeDataTable);
  }

  // Call the drop crop table if exists
  Future deleteScoutTypeTable() async {
    Database db = await instance.database;
    _dropScoutTypeTableIfExistsThenReCreate(db, dbVersion);
  }

  // Delete the object. Delete Scout type content
  Future<int> deleteScoutTypeContent() async {
    Database db = await instance.database;
    return await db.delete(_cropScoutTypeDataTable);
  }

  /// Farm DB functions.
  // Insert Farm db function.
  Future<int> insertFarmData(Map<String, dynamic> row) async {
    // Call the get database function first
    Database db = await instance.database;
    // Insert value and return the unique id or primary key.
    return await db.insert(_farmDataTable, row);
  }

  // Check to see if Farm table exists at the time of refreshing and
  // reinserting data From the api.
  Future _dropFarmTableIfExistsThenReCreate(Database db, int version) async {
    // Here we execute a query to drop the table if exists which is called "tableName"
    // and could be given as method's input parameter too
    await db.execute("DROP TABLE IF EXISTS $_farmDataTable");

    // And finally here we recreate our beloved "tableName" again which needs
    // some columns initialization
    await db.execute('''CREATE TABLE $_farmDataTable (
        $farmId INTEGER,
        $farmOrgId TEXT,
        $farmName TEXT,
        $farmLocation TEXT,
        $farmUser TEXT,
        $plotCount TEXT,
        $farmCreatedDate TEXT )
        ''');
  }

  // Query Farm Function
  Future<List<Map<String, dynamic>>> queryFarmAll() async {
    Database db = await instance.database;
    return await db.query(_farmDataTable);
  }

  // Call the drop crop table if exists
  Future deleteFarmTable() async {
    Database db = await instance.database;
    _dropFarmTableIfExistsThenReCreate(db, dbVersion);
  }

  // Delete the object. Delete farm content
  Future<int> deleteFarmContent() async {
    Database db = await instance.database;
    return await db.delete(_farmDataTable);
  }

  /// Farm Data table Queue
  // Insert data to local storage.
  // Responsible for pushing data to api server
  Future<int> insertFarmDataToQueue(Map<String, dynamic> row) async {
    // call the get database function first
    Database db = await instance.database;
    //Insert value and return the unique id or primary key.
    return await db.insert(_farmDataQueueTable, row);
  }

  // Query Farm Data from table Queue.
  Future<List<Map<String, dynamic>>> queryAllDataFarmLocalQueueTable() async {
    Database db = await instance.database;
    return await db.query(_farmDataQueueTable);
  }

  // Delete the object in the queue table after successful upload
  Future<int> deleteObjectInFarmQueue(int id) async {
    Database db = await instance.database;
    return await db.delete(_farmDataQueueTable, where: 'id=?', whereArgs: [id]);
  }

  /// Plot DB functions.
  // Insert Farm db function.
  Future<int> insertPlotData(Map<String, dynamic> row) async {
    // Call the get database function first
    Database db = await instance.database;
    // Insert value and return the unique id or primary key.
    return await db.insert(_plotDataTable, row);
  }

  // Check to see if Farm table exists at the time of refreshing and
  // reinserting data From the api.
  Future _dropPlotTableIfExistsThenReCreate(Database db, int version) async {
    // Here we execute a query to drop the table if exists which is called "tableName"
    // and could be given as method's input parameter too
    await db.execute("DROP TABLE IF EXISTS $_plotDataTable");

    // And finally here we recreate our beloved "tableName" again which needs
    // some columns initialization
    await db.execute('''
    CREATE TABLE $_plotDataTable(
    id INTEGER PRIMARY KEY,
    $plotFarmId TEXT,
    $plotId TEXT,
    $plotName TEXT,
    $variety TEXT,
    $plotCropType TEXT,
    $centroDeCosto TEXT,
    $area TEXT,
    $plantPerHectare TEXT,
    $plotUser TEXT,
    $plotCreatedDate TEXT )
       ''');
  }

  // Query Plot Function
  Future<List<Map<String, dynamic>>> queryPlotAll() async {
    Database db = await instance.database;
    return await db.query(_plotDataTable);
  }

  Future<List<Map<String, dynamic>>> queryPlotByFarm(int id) async {
    Database db = await instance.database;

    return await db
        .query(_plotDataTable, where: '$plotFarmId=?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> queryOnePlotById(int id) async {
    Database db = await instance.database;

    return await db.query(_plotDataTable, where: '$plotId=?', whereArgs: [id]);
  }

  // Call the drop crop table if exists
  Future deletePlotTable() async {
    Database db = await instance.database;
    _dropPlotTableIfExistsThenReCreate(db, dbVersion);
  }

// Delete the object. Delete Plot content
  Future<int> deletePlotContent() async {
    Database db = await instance.database;
    return await db.delete(_plotDataTable);
  }

  /// Scout DB functions.
  // Insert Farm db function.
  Future<int> insertScoutData(Map<String, dynamic> row) async {
    // Call the get database function first
    Database db = await instance.database;
    // Insert value and return the unique id or primary key.
    return await db.insert(_cropScoutDataTable, row);
  }

  // Check to see if Farm table exists at the time of refreshing and
  // reinserting data From the api.
  Future _dropScoutTableIfExistsThenReCreate(Database db, int version) async {
    // Here we execute a query to drop the table if exists which is called "tableName"
    // and could be given as method's input parameter too
    await db.execute("DROP TABLE IF EXISTS $_cropScoutDataTable");

    // And finally here we recreate our beloved "tableName" again which needs
    // some columns initialization
    await db.execute('''CREATE TABLE $_cropScoutDataTable (
        $scoutId INTEGER,
        $scoutPlotId TEXT,
        $scoutPlotName TEXT,
        $typeOfScout TEXT,
        $rowNumber TEXT,
        $plantNumber TEXT,
        $numberOfLaterals TEXT,
        $numberOfBranches TEXT,
        $numberOfCounts TEXT,
        $cropImage TEXT,
        $lat TEXT,
        $lon TEXT,
        $accuracy TEXT,
        $scoutUser TEXT,
        $scoutedDate TEXT )
        ''');
  }

  // Query Scout Function
  Future<List<Map<String, dynamic>>> queryAllScout() async {
    Database db = await instance.database;
    return await db.query(_cropScoutDataTable);
  }

  // Call the drop crop table if exists
  Future deleteScoutTable() async {
    Database db = await instance.database;
    _dropScoutTableIfExistsThenReCreate(db, dbVersion);
  }

  // Delete the object. Delete scout data content.
  Future<int> deleteScoutDataContent() async {
    Database db = await instance.database;
    return await db.delete(_cropScoutDataTable);
  }

  /// Scout Queue Data table
  // Insert data to local storage.
  // Responsible for pushing data to api server
  Future<int> insertScoutDataToQueue(Map<String, dynamic> row) async {
    // call the get database function first
    Database db = await instance.database;
    //Insert value and return the unique id or primary key.
    return await db.insert(_cropScoutQueueDataTable, row);
  }

  // Query Farm Data from table Queue.
  Future<List<Map<String, dynamic>>> queryAllDataScoutLocalQueueTable() async {
    Database db = await instance.database;
    return await db.query(_cropScoutQueueDataTable);
  }

  // Delete the object in the queue table after successful upload
  Future<int> deleteObjectInScoutQueue(int id) async {
    Database db = await instance.database;
    return await db
        .delete(_cropScoutQueueDataTable, where: 'id=?', whereArgs: [id]);
  }
}
