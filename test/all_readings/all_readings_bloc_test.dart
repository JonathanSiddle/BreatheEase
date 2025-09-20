import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zensoku/logic/all_readings/bloc/all_readings_bloc.dart';
import 'package:zensoku/models/models.dart';
import 'package:zensoku/repositories/peak_flow_readings_repository.dart';
import 'package:zensoku/service/peak_flow_reading/in_memory_peak_flow_reading_api.dart';

void main() {
  final day1Reading1 = PeakFlowReading(
    id: '1',
    reading: 111,
    date: DateTime.parse('2023-10-05 14:30:00'),
  );
  final day2Reading1 = PeakFlowReading(
    id: '4',
    reading: 114,
    date: DateTime.parse('2023-10-06 14:30:00'),
  );
  final day3Reading1 = PeakFlowReading(
    id: '5',
    reading: 115,
    date: DateTime.parse('2023-10-07 14:30:00'),
  );
  final day3Data = DayData(
      id: '3',
      date: DateTime.parse('2023-10-07'),
      peakFlowReadings: [day3Reading1],
      preventerUse: const [],
      relieverUse: const []);
  final day2Data = DayData(
      id: '2',
      date: DateTime.parse('2023-10-06'),
      peakFlowReadings: [day2Reading1],
      preventerUse: const [],
      relieverUse: const []);
  final day1Data = DayData(
      id: '1',
      date: DateTime.parse('2023-10-05'),
      peakFlowReadings: [day1Reading1],
      preventerUse: const [],
      relieverUse: const []);

  AllReadingsBloc getOverviewBlock(
    List<DayData> readings,
    bool simulateError,
  ) {
    return AllReadingsBloc(
      peakFlowReadingsRepository: PeakFlowReadingsRepository(
        peakFlowReadingApi: InMemoryPeakFlowReadingApi(
          initReadings: readings,
          simulateError: simulateError,
        ),
      ),
    );
  }

  group('all readings block tests', () {
    blocTest('On subscription requested success sets status with zero readings',
        build: () {
          return getOverviewBlock([], false);
        },
        act: (bloc) {
          bloc.add(const AllReadingSubscriptionRequested());
        },
        expect: () => [
              const AllReadingsState(status: AllReadingsStatus.loading),
              const AllReadingsState(
                status: AllReadingsStatus.success,
              ),
            ]);

    blocTest(
        'On subscription requested success sets status with three days of readings',
        build: () {
          return getOverviewBlock([day1Data, day2Data, day3Data], false);
        },
        act: (bloc) {
          bloc.add(const AllReadingSubscriptionRequested());
        },
        expect: () => [
              const AllReadingsState(status: AllReadingsStatus.loading),
              AllReadingsState(
                  status: AllReadingsStatus.success,
                  dayData: [day1Data, day2Data, day3Data]),
            ]);

    blocTest('On subscription requested error sets error status correctly',
        build: () {
          return getOverviewBlock([day1Data, day2Data, day3Data], true);
        },
        act: (bloc) {
          bloc.add(const AllReadingSubscriptionRequested());
        },
        expect: () => [
              const AllReadingsState(status: AllReadingsStatus.loading),
              const AllReadingsState(
                status: AllReadingsStatus.failure,
              ),
            ]);
  });
}
