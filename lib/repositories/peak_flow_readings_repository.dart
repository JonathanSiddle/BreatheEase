import 'package:zensoku/models/day_data.dart';
import 'package:zensoku/models/inhaler_use.dart';
import 'package:zensoku/models/peak_flow_reading.dart';
import 'package:zensoku/service/peak_flow_reading/peak_flow_reading_api.dart';

class PeakFlowReadingsRepository {
  const PeakFlowReadingsRepository(
      {required PeakFlowReadingApi peakFlowReadingApi})
      : _peakFlowReadingApi = peakFlowReadingApi;

  final PeakFlowReadingApi _peakFlowReadingApi;

  Stream<List<DayData>> getAllPeakFlowReadings() =>
      _peakFlowReadingApi.getAllReadings();

  Stream<List<DayData>> getPeakFlowReadingsLastSevenDays() =>
      _peakFlowReadingApi.getLatestSevenReadings();

  Stream<List<PeakFlowReading>> getPeakFlowReadingsForDate(DateTime date) =>
      _peakFlowReadingApi.getReadingsForDate(date);

  void addPeakFlowReading(PeakFlowReading reading) {
    _peakFlowReadingApi.addReading(reading);
  }

  void incrementPreventerUse(InhalerUse inhalerUse) {
    _peakFlowReadingApi.incrementPreventerUse(inhalerUse);
  }

  void incrementRelieverUse(InhalerUse inhalerUse) {
    _peakFlowReadingApi.incrementRelieverUse(inhalerUse);
  }

  void deletePeakFlowReading(PeakFlowReading reading) {
    _peakFlowReadingApi.deleteReading(reading);
  }
}
