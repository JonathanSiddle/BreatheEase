import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zensoku/logic/peak_flow_reading_overview/bloc/peak_flow_reading_overview_bloc.dart';
import 'package:zensoku/models/day_data.dart';
import 'package:zensoku/models/features/app_feature.dart';
import 'package:zensoku/models/inhaler_use.dart';
import 'package:zensoku/models/peak_flow_reading.dart';
import 'package:zensoku/repositories/date_time_repository.dart';
import 'package:zensoku/repositories/guid_id_repository.dart';
import 'package:zensoku/repositories/peak_flow_readings_repository.dart';
import 'package:zensoku/service/peak_flow_reading/in_memory_peak_flow_reading_api.dart';

void main() {
  var uuid = 0;
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
  final day4Reading1 = PeakFlowReading(
    id: '6',
    reading: 116,
    date: DateTime.parse('2023-10-08 14:30:00'),
  );
  final day5Reading1 = PeakFlowReading(
    id: '7',
    reading: 117,
    date: DateTime.parse('2023-10-09 14:30:00'),
  );
  final day6Reading1 = PeakFlowReading(
    id: '8',
    reading: 118,
    date: DateTime.parse('2023-10-10 14:30:00'),
  );
  final day7Reading1 = PeakFlowReading(
    id: '9',
    reading: 119,
    date: DateTime.parse('2023-10-11 14:30:00'),
  );
  final day8Reading1 = PeakFlowReading(
    id: '10',
    reading: 120,
    date: DateTime.parse('2023-10-12 14:30:00'),
  );

  final dayData8 = DayData(
      id: '7',
      date: DateTime.parse('2023-10-12'),
      peakFlowReadings: [day8Reading1],
      preventerUse: const [],
      relieverUse: const []);
  final dayData7 = DayData(
      id: '6',
      date: DateTime.parse('2023-10-11'),
      peakFlowReadings: [day7Reading1],
      preventerUse: const [],
      relieverUse: const []);
  final dayData6 = DayData(
      id: '5',
      date: DateTime.parse('2023-10-10 14:30:00'),
      peakFlowReadings: [day6Reading1],
      preventerUse: const [],
      relieverUse: const []);
  final dayData5 = DayData(
      id: '4',
      date: DateTime.parse('2023-10-09'),
      peakFlowReadings: [day5Reading1],
      preventerUse: const [],
      relieverUse: const []);
  final dayData4 = DayData(
      id: '3',
      date: DateTime.parse('2023-10-08'),
      peakFlowReadings: [day4Reading1],
      preventerUse: const [],
      relieverUse: const []);
  final dayData3 = DayData(
      id: '2',
      date: DateTime.parse('2023-10-07'),
      peakFlowReadings: [day3Reading1],
      preventerUse: const [],
      relieverUse: const []);
  final dayData2 = DayData(
      id: '1',
      date: DateTime.parse('2023-10-06'),
      peakFlowReadings: [day2Reading1],
      preventerUse: const [],
      relieverUse: const []);
  late DayData dayData1;

  PeakFlowReadingOverviewBloc getOverviewBlock(
      List<DayData>? readings, bool? simulateError,
      {bool? simulateSubscriptionCheckError,
      DateTimeRepository? dateTimeRepo}) {
    return PeakFlowReadingOverviewBloc(
        peakFlowReadingsRepository: PeakFlowReadingsRepository(
          peakFlowReadingApi: InMemoryPeakFlowReadingApi(
            initReadings: readings ?? [],
            simulateError: simulateError ?? false,
          ),
        ),
        guidRepository:
            GuidRepository(guidProvider: () => (uuid += 1).toString()),
        dateTimeRepository: dateTimeRepo ??
            DateTimeRepository(
                dateProvider: () => DateTime(2023, 10, 6, 15, 30)),
        featureRegistory: FeatureRegistory.defaultStates());
  }

  group(PeakFlowReadingOverviewBloc, () {
    late PeakFlowReadingOverviewBloc peakFlowReadingOverviewBloc;

    //need to mock the repositories
    setUp(() {
      uuid = 0;
      dayData1 = DayData(
          id: '1',
          date: DateTime.parse('2023-10-06'),
          peakFlowReadings: [day1Reading1, day1Reading2, day1Reading3],
          preventerUse: const [],
          relieverUse: const []);

      peakFlowReadingOverviewBloc = PeakFlowReadingOverviewBloc(
          peakFlowReadingsRepository: PeakFlowReadingsRepository(
            peakFlowReadingApi: InMemoryPeakFlowReadingApi(
              initReadings: [
                dayData1,
              ],
              simulateError: false,
            ),
          ),
          guidRepository:
              GuidRepository(guidProvider: () => (uuid += 1).toString()),
          dateTimeRepository: DateTimeRepository(
              dateProvider: () => DateTime(2023, 10, 06, 15, 30)),
          featureRegistory: FeatureRegistory.defaultStates());
    });

    //test initial state is correct
    test('Test initial state is correct', () {
      final peakFlowReadingOverviewState = peakFlowReadingOverviewBloc.state;
      const expectedState = PeakFlowReadingOverviewState();

      expect(peakFlowReadingOverviewState, expectedState);
    });

    //test loading and error states
    blocTest('On subscription requested success sets status with zero readings',
        build: () {
          return getOverviewBlock(
            [],
            false,
          );
        },
        act: (bloc) {
          bloc.add(const PeakFlowReadingOverviewSubscriptionRequested());
        },
        expect: () => [
              const PeakFlowReadingOverviewState(
                  status: PeakFlowReadingOverviewStatus.loading),
              const PeakFlowReadingOverviewState(
                status: PeakFlowReadingOverviewStatus.success,
              ),
            ]);

    blocTest(
        'On subscription requested success sets status and day readings less than 7 readings with different days',
        build: () => peakFlowReadingOverviewBloc,
        act: (bloc) {
          bloc.add(const PeakFlowReadingOverviewSubscriptionRequested());
        },
        expect: () => [
              const PeakFlowReadingOverviewState(
                  status: PeakFlowReadingOverviewStatus.loading),
              PeakFlowReadingOverviewState(
                  status: PeakFlowReadingOverviewStatus.success,
                  dayData: [
                    DayData(
                        id: '1',
                        date: DateTime.parse('2023-10-06'),
                        peakFlowReadings: [
                          day1Reading1,
                          day1Reading2,
                          day1Reading3,
                        ],
                        preventerUse: const [],
                        relieverUse: const [])
                  ]),
            ]);

    blocTest(
        'More than 7 readings returned is reduced to 7 readings - oldest readings removed',
        build: () {
          return getOverviewBlock([
            dayData8,
            dayData7,
            dayData6,
            dayData5,
            dayData4,
            dayData3,
            dayData2,
            dayData1,
          ], false);
        },
        act: (bloc) {
          bloc.add(const PeakFlowReadingOverviewSubscriptionRequested());
        },
        expect: () => [
              const PeakFlowReadingOverviewState(
                  status: PeakFlowReadingOverviewStatus.loading),
              const PeakFlowReadingOverviewState(
                status: PeakFlowReadingOverviewStatus.loading,
                showMoreButton: true,
              ),
              PeakFlowReadingOverviewState(
                status: PeakFlowReadingOverviewStatus.success,
                showMoreButton: true,
                dayData: [
                  DayData(
                      id: '7',
                      date: DateTime.parse('2023-10-12'),
                      peakFlowReadings: [day8Reading1],
                      preventerUse: const [],
                      relieverUse: const []),
                  DayData(
                    id: '6',
                    date: DateTime.parse('2023-10-11'),
                    peakFlowReadings: [day7Reading1],
                    preventerUse: const [],
                    relieverUse: const [],
                  ),
                  DayData(
                    id: '5',
                    date: DateTime.parse('2023-10-10 14:30:00'),
                    peakFlowReadings: [day6Reading1],
                    preventerUse: const [],
                    relieverUse: const [],
                  ),
                  DayData(
                    id: '4',
                    date: DateTime.parse('2023-10-09'),
                    peakFlowReadings: [day5Reading1],
                    preventerUse: const [],
                    relieverUse: const [],
                  ),
                  DayData(
                    id: '3',
                    date: DateTime.parse('2023-10-08'),
                    peakFlowReadings: [day4Reading1],
                    preventerUse: const [],
                    relieverUse: const [],
                  ),
                  DayData(
                    id: '2',
                    date: DateTime.parse('2023-10-07'),
                    peakFlowReadings: [day3Reading1],
                    preventerUse: const [],
                    relieverUse: const [],
                  ),
                  DayData(
                    id: '1',
                    date: DateTime.parse('2023-10-06'),
                    peakFlowReadings: [day2Reading1],
                    preventerUse: const [],
                    relieverUse: const [],
                  )
                ],
              ),
            ]);

    blocTest('Can increment preventer inhaler use',
        build: () => peakFlowReadingOverviewBloc,
        act: (bloc) async {
          bloc.add(const PeakFlowReadingOverviewSubscriptionRequested());
          bloc.add(const PeakFlowReadingOverviewIncrementPreventerUse());
        },
        expect: () => [
              const PeakFlowReadingOverviewState(
                  status: PeakFlowReadingOverviewStatus.loading),
              PeakFlowReadingOverviewState(
                  status: PeakFlowReadingOverviewStatus.success,
                  dayData: [
                    DayData(
                      id: '1',
                      date: DateTime.parse('2023-10-06'),
                      peakFlowReadings: [
                        day1Reading1,
                        day1Reading2,
                        day1Reading3,
                      ],
                      preventerUse: const [],
                      relieverUse: const [],
                    )
                  ]),
              PeakFlowReadingOverviewState(
                  status:
                      PeakFlowReadingOverviewStatus.incrementingPreventerUse,
                  dayData: [
                    DayData(
                      id: '1',
                      date: DateTime.parse('2023-10-06'),
                      peakFlowReadings: [
                        day1Reading1,
                        day1Reading2,
                        day1Reading3,
                      ],
                      preventerUse: const [],
                      relieverUse: const [],
                    )
                  ]),
              PeakFlowReadingOverviewState(
                  status: PeakFlowReadingOverviewStatus
                      .incrementPreventerUseSuccess,
                  dayData: [
                    DayData(
                      id: '1',
                      date: DateTime.parse('2023-10-06'),
                      peakFlowReadings: [
                        day1Reading1,
                        day1Reading2,
                        day1Reading3,
                      ],
                      preventerUse: const [],
                      relieverUse: const [],
                    )
                  ]),
              PeakFlowReadingOverviewState(
                  status: PeakFlowReadingOverviewStatus.success,
                  dayData: [
                    DayData(
                      id: '1',
                      date: DateTime.parse('2023-10-06'),
                      peakFlowReadings: [
                        day1Reading1,
                        day1Reading2,
                        day1Reading3,
                      ],
                      preventerUse: [
                        InhalerUse(
                          id: '1',
                          date: DateTime(2023, 10, 06, 15, 30),
                        )
                      ],
                      relieverUse: const [],
                    )
                  ]),
            ]);

    blocTest('Can increment preventer inhaler use',
        build: () => peakFlowReadingOverviewBloc,
        act: (bloc) async {
          bloc.add(const PeakFlowReadingOverviewSubscriptionRequested());
          bloc.add(const PeakFlowReadingOverviewIncrementRelieverUse());
        },
        expect: () => [
              const PeakFlowReadingOverviewState(
                  status: PeakFlowReadingOverviewStatus.loading),
              PeakFlowReadingOverviewState(
                  status: PeakFlowReadingOverviewStatus.success,
                  dayData: [
                    DayData(
                      id: '1',
                      date: DateTime.parse('2023-10-06'),
                      peakFlowReadings: [
                        day1Reading1,
                        day1Reading2,
                        day1Reading3,
                      ],
                      preventerUse: const [],
                      relieverUse: const [],
                    )
                  ]),
              PeakFlowReadingOverviewState(
                  status:
                      PeakFlowReadingOverviewStatus.incrementingPreventerUse,
                  dayData: [
                    DayData(
                      id: '1',
                      date: DateTime.parse('2023-10-06'),
                      peakFlowReadings: [
                        day1Reading1,
                        day1Reading2,
                        day1Reading3,
                      ],
                      preventerUse: const [],
                      relieverUse: const [],
                    )
                  ]),
              PeakFlowReadingOverviewState(
                  status: PeakFlowReadingOverviewStatus
                      .incrementPreventerUseSuccess,
                  dayData: [
                    DayData(
                      id: '1',
                      date: DateTime.parse('2023-10-06'),
                      peakFlowReadings: [
                        day1Reading1,
                        day1Reading2,
                        day1Reading3,
                      ],
                      preventerUse: const [],
                      relieverUse: const [],
                    )
                  ]),
              PeakFlowReadingOverviewState(
                  status: PeakFlowReadingOverviewStatus.success,
                  dayData: [
                    DayData(
                      id: '1',
                      date: DateTime.parse('2023-10-06'),
                      peakFlowReadings: [
                        day1Reading1,
                        day1Reading2,
                        day1Reading3,
                      ],
                      preventerUse: const [],
                      relieverUse: [
                        InhalerUse(
                          id: '1',
                          date: DateTime(2023, 10, 06, 15, 30),
                        )
                      ],
                    )
                  ]),
            ]);
  });
}
