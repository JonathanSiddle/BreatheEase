import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zensoku/logic/settings/settings_cubit.dart';
import 'package:zensoku/models/day_data.dart';
import 'package:zensoku/models/features/app_feature.dart';
import 'package:zensoku/models/peak_flow_reading.dart';
import 'package:zensoku/repositories/date_time_repository.dart';
import 'package:zensoku/repositories/peak_flow_readings_repository.dart';
import 'package:zensoku/repositories/settings_repository.dart';
import 'package:zensoku/service/peak_flow_reading/in_memory_peak_flow_reading_api.dart';
import 'package:zensoku/util/log_util.dart';
import 'package:zensoku/widgets/reading_day_page.dart';

// Mock class for HydratedStorage
class MockStorage extends Mock implements HydratedStorage {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late HydratedStorage storage;

  setUp(() async {
    // Mock or provide a temp directory for hydrated storage
    storage = MockStorage();
    when(
      () => storage.write(any(), any<dynamic>()),
    ).thenAnswer((_) async {});
    HydratedBloc.storage = storage;
  });

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

  Widget getWidgetToTest({List<DayData>? readings, DateTime? currentDate}) {
    final settingsRepo = SettingsRepository(
        packageApi: InMemoryPackageApi(pubspecVersion: '1.0.0'));
    final dateTimeRepo =
        DateTimeRepository(dateProvider: () => DateTime(2024, 8, 26, 15, 30));
    final loggingFactory = DefaultLoggingFactory();
    // ignore: unused_local_variable
    final logger = loggingFactory.getLogger('test logger');

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<LoggingFactory>.value(value: loggingFactory),
        RepositoryProvider<DateTimeRepository>.value(value: dateTimeRepo),
        RepositoryProvider<SettingsRepository>.value(value: settingsRepo),
        RepositoryProvider<PeakFlowReadingsRepository>.value(
            value: PeakFlowReadingsRepository(
                peakFlowReadingApi:
                    InMemoryPeakFlowReadingApi(initReadings: readings ?? []))),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (context) => SettingsCubit(
                  settingsRepository: settingsRepo,
                  featureRegistory: FeatureRegistory.defaultStates())),
        ],
        child: MaterialApp(
            home: ReadingDayPage(
          currentDate: currentDate ?? DateTime.now(),
        )),
      ),
    );
  }

  group('Reading day display test', () {
    testWidgets('Can display readings for day (3 readings)',
        (WidgetTester tester) async {
      final widget = getWidgetToTest(
          readings: [dayData1], currentDate: DateTime(2023, 10, 5));

      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 5));

      expect(find.text('05 Oct 23'), findsOneWidget);

      expect(find.text('14:30:00'), findsOneWidget);
      expect(find.text('111 l/min'), findsOneWidget);

      expect(find.text('14:31:00'), findsOneWidget);
      expect(find.text('112 l/min'), findsOneWidget);

      expect(find.text('14:32:00'), findsOneWidget);
      expect(find.text('113 l/min'), findsOneWidget);
    });

    testWidgets('No readings displays message', (WidgetTester tester) async {
      final widget =
          getWidgetToTest(readings: [], currentDate: DateTime(2023, 10, 5));

      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 5));

      expect(find.text('Looks like there is nothing here!'), findsOneWidget);
    });
  });

  group('Delete reading tests', () {
    testWidgets('Tapping delete then tapping no does not delete reading',
        (WidgetTester tester) async {
      final widget = getWidgetToTest(
          readings: [dayData1], currentDate: DateTime(2023, 10, 5));

      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 5));

      await tester.tap(find.byIcon(FontAwesomeIcons.trash).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('No'));
      await tester.pumpAndSettle();

      expect(find.text('14:30:00'), findsOneWidget);
      expect(find.text('111 l/min'), findsOneWidget);

      expect(find.text('14:31:00'), findsOneWidget);
      expect(find.text('112 l/min'), findsOneWidget);

      expect(find.text('14:32:00'), findsOneWidget);
      expect(find.text('113 l/min'), findsOneWidget);
    });

    testWidgets('Tapping delete then tapping yes deletes reading',
        (WidgetTester tester) async {
      final widget = getWidgetToTest(
          readings: [dayData1], currentDate: DateTime(2023, 10, 5));

      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(FontAwesomeIcons.trash).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();

      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      expect(find.text('14:30:00'), findsNothing);
      expect(find.text('111 l/min'), findsNothing);

      expect(find.text('14:31:00'), findsOneWidget);
      expect(find.text('112 l/min'), findsOneWidget);

      expect(find.text('14:32:00'), findsOneWidget);
      expect(find.text('113 l/min'), findsOneWidget);
    });
  });
}
