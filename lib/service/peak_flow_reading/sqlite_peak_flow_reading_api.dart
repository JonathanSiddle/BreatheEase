import 'dart:async';

import 'package:rxdart/subjects.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:uuid/uuid.dart';
import 'package:zensoku/models/day_data.dart';
import 'package:zensoku/models/inhaler_use.dart';
import 'package:zensoku/models/peak_flow_reading.dart';
import 'package:zensoku/service/peak_flow_reading/peak_flow_reading_api.dart';

class SqlitePeakFlowReadingApi extends PeakFlowReadingApi {
  SqlitePeakFlowReadingApi({required Database database})
      : _database = database {
    _initializeStreams();
  }

  final Database _database;
  final _uuid = const Uuid();

  final _dayDataStreamController = BehaviorSubject<List<DayData>>();
  final _readingsForDateStreamController =
      BehaviorSubject<List<PeakFlowReading>>();

  // Track current stream contexts for refreshing
  DateTime? _currentReadingsForDate;

  void _initializeStreams() {
    _dayDataStreamController.add([]);
    _readingsForDateStreamController.add([]);
  }

  void dispose() {
    _dayDataStreamController.close();
    _readingsForDateStreamController.close();
  }

  @override
  Future<void> addReading(PeakFlowReading reading) async {
    final currentDate =
        DateTime(reading.date.year, reading.date.month, reading.date.day);

    await _database.transaction((txn) async {
      // Check if day_data exists for this date
      final dayDataExists = await txn.query(
        'day_data',
        where: 'date = ?',
        whereArgs: [
          currentDate.toIso8601String().split('T')[0],
        ],
      );

      String dayDataId;
      if (dayDataExists.isEmpty) {
        // Create new day_data record
        dayDataId = _generateId();
        await txn.insert('day_data', {
          'id': dayDataId,
          'date': currentDate.toIso8601String().split('T')[0],
        });
      } else {
        final id = dayDataExists.first['id'];
        if (id == null) throw StateError('Day data ID cannot be null');
        dayDataId = id as String;
      }

      // Insert peak flow reading
      await txn.insert('peak_flow_readings', {
        'id': reading.id.isEmpty ? _generateId() : reading.id,
        'day_data_id': dayDataId,
        'reading_value': reading.reading,
        'date': reading.date.millisecondsSinceEpoch ~/ 1000,
      });
    });

    // Refresh streams for the user who added the reading
    await _refreshAllStreams();
  }

  @override
  Future<void> deleteReading(PeakFlowReading reading) async {
    await _database.delete(
      'peak_flow_readings',
      where: 'id = ?',
      whereArgs: [reading.id],
    );

    // Refresh streams for the user who deleted the reading
    await _refreshAllStreams();
  }

  @override
  Stream<List<DayData>> getAllReadings() {
    _refreshDayDataStream();
    return _dayDataStreamController.stream;
  }

  @override
  Stream<List<DayData>> getLatestSevenReadings() {
    _refreshDayDataStream(limit: 7);
    return _dayDataStreamController.stream;
  }

  @override
  Stream<List<PeakFlowReading>> getReadingsForDate(DateTime date) {
    _currentReadingsForDate = date;
    _refreshReadingsForDateStream(date);
    return _readingsForDateStreamController.stream;
  }

  @override
  Future<void> incrementPreventerUse(InhalerUse inhalerUse) async {
    final currentDate = DateTime(
        inhalerUse.date.year, inhalerUse.date.month, inhalerUse.date.day);

    await _database.transaction((txn) async {
      // Check if day_data exists for this date
      final dayDataExists = await txn.query(
        'day_data',
        where: 'date = ?',
        whereArgs: [
          currentDate.toIso8601String().split('T')[0],
        ],
      );

      String dayDataId;
      if (dayDataExists.isEmpty) {
        // Create new day_data record
        dayDataId = _generateId();
        await txn.insert('day_data', {
          'id': dayDataId,
          'date': currentDate.toIso8601String().split('T')[0],
        });
      } else {
        final id = dayDataExists.first['id'];
        if (id == null) throw StateError('Day data ID cannot be null');
        dayDataId = id as String;
      }

      // Insert inhaler use
      await txn.insert('inhaler_uses', {
        'id': inhalerUse.id.isEmpty ? _generateId() : inhalerUse.id,
        'day_data_id': dayDataId,
        'inhaler_type': 'preventer',
        'date': inhalerUse.date.millisecondsSinceEpoch ~/ 1000,
      });
    });

    // Refresh streams for the user who incremented preventer use
    await _refreshAllStreams();
  }

  @override
  Future<void> incrementRelieverUse(InhalerUse inhalerUse) async {
    final currentDate = DateTime(
        inhalerUse.date.year, inhalerUse.date.month, inhalerUse.date.day);

    await _database.transaction((txn) async {
      // Check if day_data exists for this date
      final dayDataExists = await txn.query(
        'day_data',
        where: 'date = ?',
        whereArgs: [
          currentDate.toIso8601String().split('T')[0],
        ],
      );

      String dayDataId;
      if (dayDataExists.isEmpty) {
        // Create new day_data record
        dayDataId = _generateId();
        await txn.insert('day_data', {
          'id': dayDataId,
          'date': currentDate.toIso8601String().split('T')[0],
        });
      } else {
        final id = dayDataExists.first['id'];
        if (id == null) throw StateError('Day data ID cannot be null');
        dayDataId = id as String;
      }

      // Insert inhaler use
      await txn.insert('inhaler_uses', {
        'id': inhalerUse.id.isEmpty ? _generateId() : inhalerUse.id,
        'day_data_id': dayDataId,
        'inhaler_type': 'reliever',
        'date': inhalerUse.date.millisecondsSinceEpoch ~/ 1000,
      });
    });

    // Refresh streams for the user who incremented reliever use
    await _refreshAllStreams();
  }

  Future<void> _refreshDayDataStream({int? limit}) async {
    String dayDataQuery = '''
      SELECT id, date
      FROM day_data
      ORDER BY date DESC
    ''';

    if (limit != null) {
      dayDataQuery += ' LIMIT $limit';
    }

    final dayDataResults = await _database.rawQuery(dayDataQuery);
    final List<DayData> dayDataList = [];

    //for each day, build object with related data
    for (final dayRow in dayDataResults) {
      final id = dayRow['id'];
      final date = dayRow['date'];
      if (id == null) throw StateError('Day data ID cannot be null');
      if (date == null) throw StateError('Day data date cannot be null');
      final dayDataId = id as String;
      final dateStr = date as String;
      final dayDate = DateTime.parse(dateStr);

      final readingsResults = await _database.query(
        'peak_flow_readings',
        where: 'day_data_id = ?',
        whereArgs: [dayDataId],
        orderBy: 'date ASC',
      );

      final readings = readingsResults.map((row) {
        final id = row['id'];
        final timestamp = row['date'];
        final reading = row['reading_value'];
        if (id == null) throw StateError('Peak flow reading ID cannot be null');
        if (timestamp == null) {
          throw StateError('Peak flow reading timestamp cannot be null');
        }
        if (reading == null) {
          throw StateError('Peak flow reading value cannot be null');
        }
        return PeakFlowReading(
          id: id as String,
          date: DateTime.fromMillisecondsSinceEpoch((timestamp as int) * 1000),
          reading: reading as int,
        );
      }).toList();

      final preventerResults = await _database.query(
        'inhaler_uses',
        where: 'day_data_id = ? AND inhaler_type = ?',
        whereArgs: [dayDataId, 'preventer'],
        orderBy: 'date ASC',
      );

      final preventerUses = preventerResults.map((row) {
        final id = row['id'];
        final timestamp = row['date'];
        if (id == null) throw StateError('Inhaler use ID cannot be null');
        if (timestamp == null) {
          throw StateError('Inhaler use timestamp cannot be null');
        }
        return InhalerUse(
          id: id as String,
          date: DateTime.fromMillisecondsSinceEpoch((timestamp as int) * 1000),
        );
      }).toList();

      final relieverResults = await _database.query(
        'inhaler_uses',
        where: 'day_data_id = ? AND inhaler_type = ?',
        whereArgs: [dayDataId, 'reliever'],
        orderBy: 'date ASC',
      );

      final relieverUses = relieverResults.map((row) {
        final id = row['id'];
        final timestamp = row['date'];
        if (id == null) throw StateError('Inhaler use ID cannot be null');
        if (timestamp == null) {
          throw StateError('Inhaler use timestamp cannot be null');
        }
        return InhalerUse(
          id: id as String,
          date: DateTime.fromMillisecondsSinceEpoch((timestamp as int) * 1000),
        );
      }).toList();

      final dayData = DayData(
        id: dayDataId,
        date: dayDate,
        peakFlowReadings: readings,
        preventerUse: preventerUses,
        relieverUse: relieverUses,
      );

      dayDataList.add(dayData);
    }

    _dayDataStreamController.add(dayDataList);
  }

  Future<void> _refreshReadingsForDateStream(DateTime date) async {
    final searchDate = DateTime(date.year, date.month, date.day);

    final results = await _database.query(
      'peak_flow_readings',
      columns: ['id', 'reading_value', 'date'],
      where: 'date >= ? AND date < ?',
      whereArgs: [
        searchDate.millisecondsSinceEpoch ~/ 1000,
        searchDate.add(const Duration(days: 1)).millisecondsSinceEpoch ~/ 1000,
      ],
      orderBy: 'date DESC',
    );

    final readings = results.map((row) {
      final id = row['id'];
      final timestamp = row['date'];
      final reading = row['reading_value'];
      if (id == null) throw StateError('Peak flow reading ID cannot be null');
      if (timestamp == null) {
        throw StateError('Peak flow reading timestamp cannot be null');
      }
      if (reading == null) {
        throw StateError('Peak flow reading value cannot be null');
      }
      return PeakFlowReading(
        id: id as String,
        date: DateTime.fromMillisecondsSinceEpoch((timestamp as int) * 1000),
        reading: reading as int,
      );
    }).toList();

    _readingsForDateStreamController.add(readings);
  }

  Future<void> _refreshAllStreams() async {
    await _refreshDayDataStream();

    if (_currentReadingsForDate != null) {
      await _refreshReadingsForDateStream(_currentReadingsForDate!);
    }
  }

  String _generateId() {
    return _uuid.v4();
  }
}
