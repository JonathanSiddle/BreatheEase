import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:zensoku/logic/reading_day/bloc/reading_day_bloc.dart';
import 'package:zensoku/models/day_data.dart';
import 'package:zensoku/models/peak_flow_reading.dart';
import 'package:zensoku/repositories/peak_flow_readings_repository.dart';
import 'package:zensoku/service/peak_flow_reading/in_memory_peak_flow_reading_api.dart';

void main() {
  final day1Reading1 = PeakFlowReading(
    id: '1',
    reading: 111,
    date: DateTime.parse('2023-10-05 14:30:00'),
  );
  final day1Reading2 = PeakFlowReading(
    id: '2',
    reading: 112,
    date: DateTime.parse('2023-10-05 14:31:00'),
  );
  final day1Reading3 = PeakFlowReading(
    id: '3',
    reading: 113,
    date: DateTime.parse('2023-10-05 14:32:00'),
  );
  final dayData1 = DayData(
      id: '1',
      date: DateTime.parse('2023-10-05'),
      peakFlowReadings: [day1Reading1, day1Reading2, day1Reading3],
      preventerUse: const [],
      relieverUse: const []);

  ReadingDayBloc getReadingDayBloc(List<DayData>? readings, bool? simulateError,
      {DateTime? currentDate, InMemoryPeakFlowReadingApi? peakFlowReadingApi}) {
    return ReadingDayBloc(
      peakFlowReadingsRepository: PeakFlowReadingsRepository(
        peakFlowReadingApi: peakFlowReadingApi ??
            InMemoryPeakFlowReadingApi(
              initReadings: readings ?? [],
              simulateError: simulateError ?? false,
            ),
      ),
      logger: Logger(),
      currentDate: currentDate ?? DateTime(2023, 10, 5),
    );
  }

  group('Initial and subscription requested events', () {
    setUp(() {});

    //test initial state is correct
    test('Test initial state is correct', () {
      final readingDayBloc = getReadingDayBloc([], false);
      final blocState = readingDayBloc.state;
      const expectedState = ReadingDayState();

      expect(blocState, expectedState);
    });

    // test loading and error states
    blocTest(
        'On subscription requested has readings no error, status success and readings set in state',
        build: () {
          return getReadingDayBloc(
            [dayData1],
            false,
          );
        },
        act: (bloc) {
          bloc.add(const ReadingDaySubscriptionRequested());
        },
        // wait: const Duration(seconds: 5),
        expect: () => [
              const ReadingDayState(status: ReadingDayStatus.loading),
              ReadingDayState(
                  status: ReadingDayStatus.success,
                  readings: [day1Reading1, day1Reading2, day1Reading3]),
            ]);

    blocTest('On subscription requested has error',
        build: () {
          return getReadingDayBloc(
            [],
            true,
          );
        },
        act: (bloc) {
          bloc.add(const ReadingDaySubscriptionRequested());
        },
        expect: () => [
              const ReadingDayState(status: ReadingDayStatus.loading),
              const ReadingDayState(
                  status: ReadingDayStatus.failure,
                  errorMessage: 'Simulated error'),
            ]);
  });

  group('Delete reading events', () {
    late InMemoryPeakFlowReadingApi peakFlowReadingApi;
    setUp(() {
      peakFlowReadingApi = InMemoryPeakFlowReadingApi(initReadings: [dayData1]);
    });

    blocTest(
        'On delete reading requested sets status deleteRequested and readingToDelete in state',
        build: () {
          return getReadingDayBloc(
            [dayData1],
            false,
          );
        },
        act: (bloc) {
          bloc.add(ReadingDayDeleteReading(day1Reading1));
        },
        expect: () => [
              ReadingDayState(
                  status: ReadingDayStatus.deleteRequested,
                  readingToDelete: day1Reading1),
            ]);

    blocTest(
        'On delete reading confirmed sets status deleteSuccess and reading to delete back to null',
        build: () {
          return getReadingDayBloc([], false,
              peakFlowReadingApi: peakFlowReadingApi);
        },
        act: (bloc) {
          bloc.add(ReadingDayDeleteReading(day1Reading1));
          bloc.add(const ReadingDayDeleteReadingConfirmed());
        },
        expect: () => [
              ReadingDayState(
                  status: ReadingDayStatus.deleteRequested,
                  readingToDelete: day1Reading1),
              const ReadingDayState(status: ReadingDayStatus.deleteSuccess),
            ],
        verify: (bloc) {
          expect(peakFlowReadingApi.dayData[0].peakFlowReadings.length, 2);
          expect(
              peakFlowReadingApi.dayData[0].peakFlowReadings
                  .contains(day1Reading2),
              true);
          expect(
              peakFlowReadingApi.dayData[0].peakFlowReadings
                  .contains(day1Reading3),
              true);
        });

    blocTest('On delete reading cancelled sets status deleteCancelled',
        build: () {
          return getReadingDayBloc(
            [dayData1],
            false,
          );
        },
        act: (bloc) {
          bloc.add(ReadingDayDeleteReading(day1Reading1));
          bloc.add(const ReadingDayDeleteReadingCancelled());
        },
        expect: () => [
              ReadingDayState(
                  status: ReadingDayStatus.deleteRequested,
                  readingToDelete: day1Reading1),
              const ReadingDayState(status: ReadingDayStatus.deleteCancelled),
            ]);
  });
}
