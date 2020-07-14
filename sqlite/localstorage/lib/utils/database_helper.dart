import 'dart:io';
import 'package:localstorage/models/contact.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _dbName = "contactData.db";
  static const _dbVersion = 1;
  // ::singletone class
  DatabaseHelper._();
  static final instance = DatabaseHelper._();
  Database _database;
  Future<Database> get database async {
    if (_database != null) {
      return _database;
    }
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, _dbName);
    return await openDatabase(path, version: _dbVersion, onCreate: _onCreateDb);
  }

  _onCreateDb(Database db, int version) async {
    await db.execute('''
   CREATE TABLE ${Contact.tblContacts}(
    ${Contact.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${Contact.colName} TEXT NOT NULL,
    ${Contact.colMobile} TEXT NOT NULL
   )
   ''');
  }

  // create
  Future<int> createContact(Contact contact) async {
    Database db = await database;
    return await db.insert(Contact.tblContacts, contact.toMap());
  }

  // read all
  Future<List<Contact>> fetchContacts() async {
    Database db = await database;
    List<Map> contacts = await db.query(Contact.tblContacts);
    return contacts.length == 0
        ? []
        : contacts.map((e) => Contact.fromMap(e)).toList();
  }

  // update
  Future<int> updateContact(Contact contact) async {
    Database db = await database;
    int id = contact.id;
    return await db.update(Contact.tblContacts, contact.toMap(),
        where: ' ${Contact.colId}= ?', whereArgs: [id]);
  }

  Future<int> deleteContact(int id) async {
    Database db = await database;
    return await db.delete(Contact.tblContacts,
        where: '${Contact.colId} =?', whereArgs: [id]);
  }
}
