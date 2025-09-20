import 'package:rxdart/subjects.dart';
import 'package:zensoku/models/day_data.dart';
import 'package:zensoku/models/inhaler_use.dart';
import 'package:zensoku/models/peak_flow_reading.dart';
import 'package:zensoku/service/peak_flow_reading/peak_flow_reading_api.dart';

class InMemoryPeakFlowReadingApi extends PeakFlowReadingApi {
  InMemoryPeakFlowReadingApi(
      {required List<DayData> initReadings, bool? simulateError})
      : initialReadings = initReadings,
        _simulateError = simulateError ?? false {
    _init();
  }

  final List<DayData> initialReadings;
  List<DayData> dayData = [];
  final _peakFlowReadingStreamController =
      BehaviorSubject<List<PeakFlowReading>>.seeded(const []);
  final _dayDataStreamController =
      BehaviorSubject<List<DayData>>.seeded(const []);
  // ignore: unused_field
  final bool _simulateError;

  void _init() {
    dayData.addAll(initialReadings);
    _dayDataStreamController.add(dayData);
  }

  @override
  Future<void> deleteReading(PeakFlowReading reading) {
    final day = dayData.firstWhere((d) =>
        d.date.year == reading.date.year &&
        d.date.month == reading.date.month &&
        d.date.day == reading.date.day);
    day.peakFlowReadings.removeWhere((r) => r.id == reading.id);

    _peakFlowReadingStreamController.add(day.peakFlowReadings);
    return Future.value();
  }

  @override
  Stream<List<DayData>> getLatestSevenReadings() {
    return _dayDataStreamController.asBroadcastStream();
  }

  @override
  Future<void> addReading(PeakFlowReading reading) async {
    // print('Saving reading');
    final readingDate =
        DateTime(reading.date.year, reading.date.month, reading.date.day);
    dayData
        .firstWhere((d) => d.date == readingDate)
        .peakFlowReadings
        .add(reading);
    _dayDataStreamController.add(dayData);
  }

  @override
  Stream<List<PeakFlowReading>> getReadingsForDate(DateTime date) {
    if (_simulateError) {
      return Stream.error(Exception('Simulated error'));
    }
    final List<PeakFlowReading> r = [];
    for (final d in dayData) {
      if (d.date.year == date.year &&
          d.date.month == date.month &&
          d.date.day == date.day) {
        r.addAll(d.peakFlowReadings);
      }
    }
    _peakFlowReadingStreamController.add(r);
    return _peakFlowReadingStreamController.asBroadcastStream();
  }

  @override
  Stream<List<DayData>> getAllReadings() {
    if (_simulateError) {
      return Stream.error(Exception('Simulated error'));
    }

    return _dayDataStreamController.asBroadcastStream();
  }

  @override
  Future<void> incrementPreventerUse(InhalerUse inhalerUse) {
    final updateDayData = dayData
        .map((d) => DayDataSqliteExtensions.fromSqliteJson(d.toSqliteJson()))
        .toList();
    final day = updateDayData.firstWhere((d) =>
        d.date.year == inhalerUse.date.year &&
        d.date.month == inhalerUse.date.month &&
        d.date.day == inhalerUse.date.day);

    day.preventerUse.add(inhalerUse);
    _dayDataStreamController.add(updateDayData);
    return Future.value();
  }

  @override
  Future<void> incrementRelieverUse(InhalerUse inhalerUse) {
    final updateDayData = dayData
        .map((d) => DayDataSqliteExtensions.fromSqliteJson(d.toSqliteJson()))
        .toList();
    final day = updateDayData.firstWhere((d) =>
        d.date.year == inhalerUse.date.year &&
        d.date.month == inhalerUse.date.month &&
        d.date.day == inhalerUse.date.day);

    day.relieverUse.add(inhalerUse);
    _dayDataStreamController.add(updateDayData);
    return Future.value();
  }
}
