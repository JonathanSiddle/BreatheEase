import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:statistics/statistics.dart';
import 'package:zensoku/models/inhaler_use.dart';
import 'package:zensoku/models/peak_flow_reading.dart';

class DayData extends Equatable {
  const DayData(
      {required this.id,
      required this.date,
      required this.peakFlowReadings,
      required this.preventerUse,
      required this.relieverUse});

  final String id;
  final DateTime date;
  final List<PeakFlowReading> peakFlowReadings;
  final List<InhalerUse> preventerUse;
  final List<InhalerUse> relieverUse;

  int get dayReadingMedian {
    if (peakFlowReadings.isEmpty) {
      return 0;
    }
    final readings = peakFlowReadings.map((r) => r.reading).toList();
    return readings.median!.toInt();
  }

  int get totalPreventerUse => preventerUse.length;
  int get totalRelieverUse => relieverUse.length;

  static Map<int, int> toDisplayDatesAndValues(List<DayData> days) {
    var daysAndValues = <int, int>{};

    daysAndValues = Map.fromEntries(days.map(
        (dayData) => MapEntry(dayData.date.day, dayData.dayReadingMedian)));
    //sort leys and keep them sorted in reverse order
    final treeMap = LinkedHashMap<int, int>.from(daysAndValues);

    return treeMap;
  }

  @override
  List<Object?> get props =>
      [id, date, peakFlowReadings, preventerUse, relieverUse];
}

extension DayDataSqliteExtensions on DayData {
  // Custom factory method for deserializing from SQLite JSON
  static DayData fromSqliteJson(Map<String, dynamic> json) {
    final dateStr = json['date'] as String;
    final date = DateTime.parse(dateStr);

    List<PeakFlowReading> peakFlowReadings = [];
    final peakFlowJson =
        json['peak_flow_readings'] as List<Map<String, dynamic>>;
    peakFlowReadings = peakFlowJson
        .map((p) => PeakFlowReadingSqliteExtensions.fromSqliteJson(p))
        .toList();

    List<InhalerUse> preventerUse = [];
    final preventerUseJson =
        json['preventer_use'] as List<Map<String, dynamic>>;
    preventerUse = preventerUseJson
        .map((p) => InhalerUseSqliteExtensions.fromSqliteJson(p))
        .toList();

    List<InhalerUse> relieverUse = [];
    final relieverUseJson = json['reliever_use'] as List<Map<String, dynamic>>;
    relieverUse = relieverUseJson
        .map((p) => InhalerUseSqliteExtensions.fromSqliteJson(p))
        .toList();

    return DayData(
      id: json['id'] as String,
      date: date,
      peakFlowReadings: peakFlowReadings,
      preventerUse: preventerUse,
      relieverUse: relieverUse,
    );
  }

  Map<String, dynamic> toSqliteJson() {
    return {
      'id': id,
      'date': date.toIso8601String().split('T')[0],
      'peak_flow_readings':
          peakFlowReadings.map((r) => r.toSqliteJson()).toList(),
      'preventer_use': preventerUse.map((p) => p.toSqliteJson()).toList(),
      'reliever_use': relieverUse.map((p) => p.toSqliteJson()).toList(),
    };
  }
}
