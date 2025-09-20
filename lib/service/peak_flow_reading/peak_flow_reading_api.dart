import 'package:zensoku/models/day_data.dart';
import 'package:zensoku/models/inhaler_use.dart';
import 'package:zensoku/models/peak_flow_reading.dart';

abstract class PeakFlowReadingApi {
  const PeakFlowReadingApi();

  Stream<List<DayData>> getLatestSevenReadings();
  Stream<List<DayData>> getAllReadings();
  Stream<List<PeakFlowReading>> getReadingsForDate(DateTime date);
  Future<void> addReading(PeakFlowReading reading);
  Future<void> incrementRelieverUse(InhalerUse inhalerUse);
  Future<void> incrementPreventerUse(InhalerUse inhalerUse);
  Future<void> deleteReading(PeakFlowReading reading);
}

class PeakFlowReadingNotFoundException implements Exception {}
