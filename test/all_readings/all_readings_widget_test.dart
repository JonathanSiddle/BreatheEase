import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zensoku/logic/all_readings/view/all_readings_view.dart';
import 'package:zensoku/logic/settings/settings_cubit.dart';
import 'package:zensoku/models/app_state.dart';
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
  final day1Data = DayData(
      id: '1',
      date: DateTime.parse('2023-10-05'),
      peakFlowReadings: [day1Reading1, day1Reading2, day1Reading3],
      preventerUse: const [],
      relieverUse: const []);

  Widget getWidgetToTest({List<DayData>? readings}) {
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
                appState: AppState.beta,
                settingsRepository: settingsRepo,
                featureRegistory: FeatureRegistory.defaultStates()),
          ),
        ],
        child: const MaterialApp(home: AllReadingsPage()),
      ),
    );
  }

  group('Peak flow reading overview widget tests', () {
    testWidgets('Can display page subscription request success and readings',
        (WidgetTester tester) async {
      final widget = getWidgetToTest(readings: [day1Data]);
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Set the window size
      final listFinder = find.byType(Scrollable);
      await tester.drag(
          listFinder, const Offset(0, -600)); // Scroll up by 300 pixels
      await tester.pumpAndSettle();

      expect(find.text('All Readings'), findsOneWidget);
      expect(find.text('05 Oct 23'), findsOneWidget);
      expect(find.text('112 l/m'), findsOneWidget);
      expect(find.text('All (3)'), findsOneWidget);
    });

    testWidgets('No readings displays error message',
        (WidgetTester tester) async {
      final widget = getWidgetToTest(readings: []);
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Set the window size
      final listFinder = find.byType(Scrollable);
      await tester.drag(
          listFinder, const Offset(0, -600)); // Scroll up by 300 pixels
      await tester.pumpAndSettle();
    });
  });

  group('Day overview card tests', () {
    testWidgets(
        'Test tapping all on an overview card goes to all readings day page',
        (WidgetTester tester) async {
      final widget = getWidgetToTest(readings: [day1Data]);
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Set the window size
      final listFinder = find.byType(Scrollable);
      await tester.drag(
          listFinder, const Offset(0, -600)); // Scroll up by 300 pixels
      await tester.pumpAndSettle();

      expect(find.text('All Readings'), findsOneWidget);
      expect(find.text('05 Oct 23'), findsOneWidget);
      expect(find.text('112 l/m'), findsOneWidget);
      expect(find.text('All (3)'), findsOneWidget);

      await tester.tap(find.text('All (3)'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      expect(find.byType(ReadingDayPage), findsOneWidget);
      // expect(true, false);
    });
  });
}
