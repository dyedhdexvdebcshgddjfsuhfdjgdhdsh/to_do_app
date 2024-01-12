import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class sqlDB {
  static Database? _db;

// method check database is already existed or not and use in many operation (create/insert/update/delete)
  Future<Database?> get dbMethod async {
    if (_db == null) {
      _db = await initalDB();
      return _db;
    } else {
      return _db;
    }
  }

  // method to inital database
  initalDB() async {
// Get a location using getDatabasesPath
    String path = await getDatabasesPath();
// to get name Path for the Database by join method take (path,text-->nameDatabase)
    String namePath = join(path, 'todo.db'); //---->// path/sflite.db
// open the database (namepath,version,oncreate method)
    Database mydb = await openDatabase(namePath,
        version: 6, onCreate: _onCreateDb, onUpgrade: _onUpgrade);
    return mydb;
  }

  // method that create table in database
  _onCreateDb(Database db, int version) async {
    await db.execute(''' 
   CREATE TABLE tasks(
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "title" TEXT,
    "date" TEXT,
    "time" TEXT,
    "status" TEXT) 
  ''');
    print('Table is Created Successfully');
  }

  _onUpgrade(Database db, int oldversion, int newversion) async {
    print('\n=============onUpgrade\n====================');
    // db.execute('ALTER TABLE notes ADD COLUMN title TEXT');
  }

// method to inital database
  /*
  initalDB() async {
// Get a location using getDatabasesPath
    String path = await getDatabasesPath();
// to get name Path for the Database by join method take (path,text-->nameDatabase)
    String namePath = join(path, 'notes.db'); //---->// path/sflite.db
// open the database (namepath,version,oncreate method)
    Database mydb = await openDatabase(namePath,
        version: 9, onCreate: _onCreateDb, onUpgrade: _onUpgrade);
    return mydb;
  }

   */
/*
// method that create table in database
  _onCreateDb(Database db, int version) async {
    await db.execute(''' 
   CREATE TABLE notes(
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE,
    "note" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "color" TEXT NOT NULL) 
  ''');
    print('Table is Created Successfully');
  }
*/

// method that create table in database
  readData(String table) async {
    Database? mydb = await dbMethod;
    List<Map> response = await mydb!.rawQuery(table);
    return response;
  }

// method that insert newdata  to table in database
  rawInsertData(String sql) async {
    Database? mydb = await dbMethod;
    int response = await mydb!.rawInsert(sql);
    return response;
  }

// method that modify on fixed cell in table in database
  updateData(String sql) async {
    Database? mydb = await dbMethod;
    int response = await mydb!.rawUpdate(sql);
    return response;
  }

// method that delete fixed cell in table in database
  deleteData(String sql) async {
    Database? mydb = await dbMethod;
    int response = await mydb!.rawDelete(sql);
    return response;
  }

  //
  myDeleteDatabase() async {
    String databasepath = await getDatabasesPath();
    String path = join(databasepath, "notes.db");
    await deleteDatabase(path);
    print('deleted Database');
  }
}
