// ignore_for_file: avoid_classes_with_only_static_members

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class SqliteService {
  static Database? _database;
  static const String _databaseName = 'BreatheEase.db';
  static const int _databaseVersion = 1;

  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  static Future<void> _createTables(Database db) async {
    //create day data table
    await db.execute('''
    CREATE TABLE day_data (
      id TEXT PRIMARY KEY,
      date TEXT NOT NULL,
      created_at INTEGER DEFAULT (strftime('%s','now')),
      updated_at INTEGER DEFAULT (strftime('%s','now'))
    );
    ''');

    await db.execute('''
    CREATE INDEX idx_day_data_date ON day_data(date);
    ''');

    //peak flow readings
    await db.execute('''
    CREATE TABLE peak_flow_readings (
      id TEXT PRIMARY KEY,
      day_data_id TEXT NOT NULL,
      reading_value INTEGER NOT NULL,
      date INTEGER NOT NULL,
      FOREIGN KEY (day_data_id) REFERENCES day_data(id) ON DELETE CASCADE
    );
    ''');

    await db.execute('''
    CREATE INDEX idx_peak_flow_day_data ON peak_flow_readings(day_data_id);
    ''');

    await db.execute('''
    CREATE INDEX idx_peak_flow_date ON peak_flow_readings(date);
    ''');

    //inhaler uses
    await db.execute('''
    CREATE TABLE inhaler_uses (
      id TEXT PRIMARY KEY,
      day_data_id TEXT NOT NULL,
      inhaler_type TEXT NOT NULL CHECK (inhaler_type IN ('preventer', 'reliever')),
      date INTEGER NOT NULL,
      FOREIGN KEY (day_data_id) REFERENCES day_data(id) ON DELETE CASCADE
    );
    ''');

    await db.execute('''
    CREATE INDEX idx_inhaler_day_data_type ON inhaler_uses(day_data_id, inhaler_type);
    ''');

    await db.execute('''
    CREATE INDEX idx_inhaler_date ON inhaler_uses(date);
    ''');
  }

  static Future<Database> _initDatabase() async {
    //save data to documents directory
    final appDocsDir = await getApplicationDocumentsDirectory();
    final databasePath =
        p.join(appDocsDir.path, 'BreatheEaseData', 'database', _databaseName);

    // Create directory if it doesn't exist
    final directory = Directory(p.dirname(databasePath));
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    if (Platform.isIOS || Platform.isAndroid) {
      // For mobile platforms, use the native sqflite
      return await sqflite.openDatabase(
        databasePath,
        version: _databaseVersion,
        onCreate: (Database db, int version) async {
          await _createTables(db);
        },
      );
    } else {
      // For desktop platforms, use FFI
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;

      return await openDatabase(
        databasePath,
        version: _databaseVersion,
        onCreate: _onCreate,
      );
    }
  }

  static Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
  }
}
