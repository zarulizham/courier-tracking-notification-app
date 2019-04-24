import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import './model/TrackingCode.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();

  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "TestDB.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE TrackingCode ("
          "id INTEGER PRIMARY KEY,"
          "courier_id INTEGER,"
          "code TEXT,"
          "email TEXT,"
          "last_checked_at TEXT,"
          "completed_at TEXT"
          ")");
    });
  }

  addTrackingCode(TrackingCode trackingCode) async {
    final db = await database;

    print("Starting to add...");
    var track = await db.query("TrackingCode", where: "id = ?", whereArgs: [trackingCode.id]);

    if (track.isNotEmpty) {
      return updateTrackingCode(trackingCode);
    }

    var raw = await db.rawInsert(
        "INSERT Into TrackingCode (id, courier_id, code, email, last_checked_at, completed_at)"
        " VALUES (?,?,?,?,?,?)",
        [trackingCode.id, trackingCode.courier_id, trackingCode.code, trackingCode.email, trackingCode.last_checked_at, trackingCode.completed_at]);

    print(raw.toString());
    print("   End add");
    return raw;
  }

  updateTrackingCode(TrackingCode trackingCode) async {
    final db = await database;
    print("Starting to update...");
    var track = await db.update("TrackingCode", trackingCode.toJson2(),
      where: "id = ?", whereArgs: [trackingCode.id]
    );
    print("  End update...");
    return track;
  }

  Future<TrackingCode> getTrackingCode(int id) async {
    final db = await database;
    var res = await db.query("TrackingCode", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? TrackingCode.fromMap(res.first) : null;
  }

  Future<List<TrackingCode>> getAllTrackingCodes() async {
    final db = await database;
    var res = await db.query("TrackingCode");

    List<TrackingCode> list =
        res.isNotEmpty ? res.map((c) => TrackingCode.fromMap(c)).toList() : [];
    return list;
  }

  deleteClient(int id) async {
    final db = await database;
    return db.delete("TrackingCode", where: "id = ?", whereArgs: [id]);
  }

  deleteAll() async {
    final db = await database;
    db.rawDelete("DELETE FROM TrackingCode");
  }
}