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
          if (version == 1) {
            await db.execute("CREATE TABLE TrackingCode ("
              "id INTEGER PRIMARY KEY,"
              "courier_id INTEGER,"
              "tracking_code_id TEXT,"
              "code TEXT,"
              "email TEXT,"
              "last_checked_at TEXT,"
              "completed_at TEXT"
              ")");
          }
      
    });
  }

  addTrackingCode(TrackingCode trackingCode) async {
    final db = await database;

    var track = await db
        .query("TrackingCode", where: "id = ?", whereArgs: [trackingCode.id]);

    if (track.isNotEmpty) {
      return updateTrackingCode(trackingCode);
    }

    var raw = await db.rawInsert(
        "INSERT Into TrackingCode (id, courier_id, tracking_code_id, code, email, last_checked_at, completed_at)"
        " VALUES (?,?,?,?,?,?,?)",
        [
          trackingCode.id,
          trackingCode.courier_id,
          trackingCode.tracking_code_id,
          trackingCode.code,
          trackingCode.email,
          trackingCode.last_checked_at,
          trackingCode.completed_at
        ]);
    return raw;
  }

  updateTrackingCode(TrackingCode trackingCode) async {
    final db = await database;
    var track = await db.update("TrackingCode", trackingCode.toJson2(),
        where: "id = ?", whereArgs: [trackingCode.id]);
    return track;
  }

  Future<TrackingCode> getTrackingCode(int id) async {
    final db = await database;
    var res = await db.query("TrackingCode", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? TrackingCode.fromMap(res.first) : null;
  }

  Future<List<TrackingCode>> getAllTrackingCodes() async {
    final db = await database;
    var res = await db.query("TrackingCode", orderBy: "id DESC");

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
