import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zensoku/logic/add_peak_flow_reading/add_peak_flow_reading.dart';
import 'package:zensoku/logic/all_readings/view/all_readings_view.dart';
import 'package:zensoku/logic/peak_flow_reading_overview/view/peak_flow_reading_overview_view.dart';
import 'package:zensoku/logic/settings/settings_cubit.dart';
import 'package:zensoku/logic/settings/settings_page.dart';
import 'package:zensoku/models/day_data.dart';
import 'package:zensoku/models/features/app_feature.dart';
import 'package:zensoku/models/peak_flow_reading.dart';
import 'package:zensoku/repositories/date_time_repository.dart';
import 'package:zensoku/repositories/guid_id_repository.dart';
import 'package:zensoku/repositories/peak_flow_readings_repository.dart';
import 'package:zensoku/repositories/settings_repository.dart';
import 'package:zensoku/service/peak_flow_reading/in_memory_peak_flow_reading_api.dart';
import 'package:zensoku/util/log_util.dart';
import 'package:zensoku/widgets/day_summary_tile.dart';
import 'package:zensoku/widgets/reading_day_page.dart';
import 'package:zensoku/widgets/week_overview_graph.dart';

// Mock class for HydratedStorage
class MockStorage extends Mock implements HydratedStorage {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
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

  late DayData dayData1;
  late DayData dayData2;
  late DayData dayData3;
  late DayData dayData4;
  late DayData dayData5;
  late DayData dayData6;
  late DayData dayData7;
  late DayData dayData8;
  const welcomeMessage = 'Start Adding Readings';
  late HydratedStorage storage;

  setUp(() async {
    dayData1 = DayData(
      id: '1',
      date: DateTime.parse('2023-10-05'),
      peakFlowReadings: [day1Reading1, day1Reading2, day1Reading3],
      preventerUse: const [],
      relieverUse: const [],
    );
    dayData2 = DayData(
      id: '2',
      date: DateTime.parse('2023-10-06'),
      peakFlowReadings: [day2Reading1],
      preventerUse: const [],
      relieverUse: const [],
    );
    dayData3 = DayData(
      id: '3',
      date: DateTime.parse('2023-10-07'),
      peakFlowReadings: [day3Reading1],
      preventerUse: const [],
      relieverUse: const [],
    );
    dayData4 = DayData(
      id: '4',
      date: DateTime.parse('2023-10-08'),
      peakFlowReadings: [day4Reading1],
      preventerUse: const [],
      relieverUse: const [],
    );
    dayData5 = DayData(
      id: '5',
      date: DateTime.parse('2023-10-09'),
      peakFlowReadings: [day5Reading1],
      preventerUse: const [],
      relieverUse: const [],
    );
    dayData6 = DayData(
      id: '6',
      date: DateTime.parse('2023-10-10'),
      peakFlowReadings: [day6Reading1],
      preventerUse: const [],
      relieverUse: const [],
    );
    dayData7 = DayData(
      id: '7',
      date: DateTime.parse('2023-10-11'),
      peakFlowReadings: [day7Reading1],
      preventerUse: const [],
      relieverUse: const [],
    );
    dayData8 = DayData(
      id: '8',
      date: DateTime.parse('2023-10-12'),
      peakFlowReadings: [day8Reading1],
      preventerUse: const [],
      relieverUse: const [],
    );

    // Mock or provide a temp directory for hydrated storage
    storage = MockStorage();
    when(
      () => storage.write(any(), any<dynamic>()),
    ).thenAnswer((_) async {});
    HydratedBloc.storage = storage;
  });

  Widget getWidgetToTest({List<DayData>? readings, DateTime? date}) {
    var uuid = 0;
    final guidRepo = GuidRepository(guidProvider: () => (uuid += 1).toString());
    final settingsRepo = SettingsRepository(
        packageApi: InMemoryPackageApi(pubspecVersion: '1.0.0'));
    final dateTimeRepo = DateTimeRepository(
        dateProvider: () => date ?? DateTime(2023, 10, 5, 15, 30));
    final loggingFactory = DefaultLoggingFactory();
    // ignore: unused_local_variable
    final logger = loggingFactory.getLogger('test logger');

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<FeatureRegistory>.value(
            value: FeatureRegistory.defaultStates()),
        RepositoryProvider<LoggingFactory>.value(value: loggingFactory),
        RepositoryProvider<GuidRepository>.value(value: guidRepo),
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
        child: MaterialApp(home: PeakFlowReadingOverviewPage()),
      ),
    );
  }

  group('Peak flow reading overview widget tests', () {
    testWidgets('Can display page subscription request success and readings',
        (WidgetTester tester) async {
      final widget = getWidgetToTest(readings: [dayData1]);
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Set the window size
      final listFinder = find.byType(Scrollable);
      await tester.drag(
          listFinder, const Offset(0, -600)); // Scroll up by 300 pixels
      await tester.pumpAndSettle();

      expect(find.byType(WeekOverviewGraph), findsOneWidget);
      expect(find.byType(DaySummaryTile), findsOneWidget);
      expect(find.text('112 l/m'), findsOneWidget);
      expect(find.text('All (3)'), findsOneWidget);
      expect(find.byType(ExpandableFab), findsOneWidget);
    });

    testWidgets(
        'Will only display cards for the most recent 7 days of readings',
        (WidgetTester tester) async {
      final widget = getWidgetToTest(readings: [
        dayData8,
        dayData7,
        dayData6,
        dayData5,
        dayData4,
        dayData3,
        dayData2,
        dayData1,
      ]);
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      final listFinder = find.byType(Scrollable);
      await tester.drag(listFinder, const Offset(0, -100));
      await tester.pumpAndSettle();

      expect(find.byType(WeekOverviewGraph), findsOneWidget);
      expect(find.byType(DaySummaryTile), findsAtLeastNWidgets(1));
      expect(find.text('12 Oct 23'), findsOneWidget);
      expect(find.text('120 l/m'), findsAtLeastNWidgets(1));
      expect(find.byType(ExpandableFab), findsOneWidget);

      await tester.drag(listFinder, const Offset(0, -1200));
      await tester.pumpAndSettle();

      expect(find.text('06 Oct 23'), findsOneWidget);
      expect(find.text('114 l/m'), findsAtLeastNWidgets(1));
    });

    // test for no readings
    testWidgets(
        'No previous readings displays welcome message and no day overview cards',
        (WidgetTester tester) async {
      final widget = getWidgetToTest(readings: []);
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Set the window size
      final listFinder = find.byType(Scrollable);
      await tester.drag(
          listFinder, const Offset(0, -600)); // Scroll up by 300 pixels
      await tester.pumpAndSettle();

      expect(find.byType(WeekOverviewGraph), findsOneWidget);
      expect(find.byType(DaySummaryTile), findsNothing);
      expect(find.text(welcomeMessage), findsOneWidget);
      expect(find.byType(ExpandableFab), findsOneWidget);
    });
  });

  group('Day overview card tests', () {
    //test tapping 'All' takes to day pages and shows all readings
    testWidgets(
        'Test tapping all on an overview card goes to all readings page',
        (WidgetTester tester) async {
      final widget = getWidgetToTest(readings: [dayData1]);
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Set the window size
      final listFinder = find.byType(Scrollable);
      await tester.drag(
          listFinder, const Offset(0, -600)); // Scroll up by 300 pixels
      await tester.pumpAndSettle();

      expect(find.byType(WeekOverviewGraph), findsOneWidget);
      expect(find.byType(DaySummaryTile), findsOneWidget);
      expect(find.text('All (3)'), findsOneWidget);
      expect(find.byType(ExpandableFab), findsOneWidget);

      await tester.tap(find.text('All (3)'));
      await tester.pumpAndSettle();

      expect(find.byType(ReadingDayPage), findsOneWidget);
    });
  });

  group('Tests for viewing settings page', () {
    testWidgets('Tapping on settings icon takes user to settings page',
        (WidgetTester tester) async {
      final widget = getWidgetToTest(readings: [dayData1]);
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsPage), findsOneWidget);
    });
  });

  group('Tests for adding readings', () {
    // test for no reading adding one reading
    testWidgets(
        'Tapping add button shows add reading dialog, tapping outside dialog will dismiss dialog',
        (WidgetTester tester) async {
      final widget = getWidgetToTest(readings: [dayData1]);
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(FontAwesomeIcons.plus));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Peak Flow'));
      await tester.pumpAndSettle();

      expect(find.byType(AddPeakFlowReading), findsOneWidget);

      await tester.tapAt(const Offset(150, 300));
      await tester.pumpAndSettle();

      expect(find.byType(AddPeakFlowReading), findsNothing);
    });

    testWidgets('Test adding two readings updates the main page',
        (WidgetTester tester) async {
      final widget = getWidgetToTest(readings: [dayData1]);
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(FontAwesomeIcons.plus));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Peak Flow'));
      await tester.pumpAndSettle();

      //Add two new readings
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 5));

      await tester.enterText(find.byType(TextField), '450');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 5));

      await tester.tapAt(const Offset(150, 300));
      await tester.pumpAndSettle();

      //scroll down to check new readings have updated main page
      final listFinder = find.byType(Scrollable);
      await tester.drag(listFinder, const Offset(0, -250));
      await tester.pumpAndSettle();

      expect(find.text('05 Oct 23'), findsOneWidget);
      expect(find.text('112 l/m'), findsOneWidget);
      expect(find.text('All (3)'), findsOneWidget);
    });
  });

  group('tests for adding inhaler usage', () {
    testWidgets('Tapping add preventer inhaler adds inhaler',
        (WidgetTester tester) async {
      final widget = getWidgetToTest(readings: [dayData1]);
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      final listFinder = find.byType(Scrollable);
      await tester.drag(listFinder, const Offset(0, -1200));
      await tester.pumpAndSettle();

      expect(find.text('0'), findsExactly(2));

      await tester.tap(find.byIcon(FontAwesomeIcons.plus));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Preventer'));
      await tester.pumpAndSettle();

      //TODO: distinguish these better
      expect(find.text('0'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('Tapping add reliever inhaler adds inhaler',
        (WidgetTester tester) async {
      final widget = getWidgetToTest(readings: [dayData1]);
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      final listFinder = find.byType(Scrollable);
      await tester.drag(listFinder, const Offset(0, -1200));
      await tester.pumpAndSettle();

      expect(find.text('0'), findsExactly(2));

      await tester.tap(find.byIcon(FontAwesomeIcons.plus));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reliever'));
      await tester.pumpAndSettle();

      //TODO: distinguish these better
      expect(find.text('0'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    });
  });

  group('More button tests', () {
    //make sure IAP flow is handled correctly
    testWidgets('More than seven days readings shows more button',
        (WidgetTester tester) async {
      final widget = getWidgetToTest(readings: [
        dayData8,
        dayData7,
        dayData6,
        dayData5,
        dayData4,
        dayData3,
        dayData2,
        dayData1
      ]);
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      final listFinder = find.byType(Scrollable);
      await tester.drag(listFinder, const Offset(0, -100));
      await tester.pumpAndSettle();

      expect(find.byType(WeekOverviewGraph), findsOneWidget);
      expect(find.byType(DaySummaryTile), findsAtLeastNWidgets(1));
      expect(find.text('12 Oct 23'), findsOneWidget);
      expect(find.text('120 l/m'), findsAtLeastNWidgets(1));
      expect(find.byType(ExpandableFab), findsOneWidget);

      await tester.drag(listFinder, const Offset(0, -1200));
      await tester.pumpAndSettle();

      expect(find.text('06 Oct 23'), findsOneWidget);
      expect(find.text('114 l/m'), findsAtLeastNWidgets(1));

      expect(find.text('More'), findsOneWidget);
    });

    testWidgets('Tapping more shows premium page', (WidgetTester tester) async {
      final widget = getWidgetToTest(readings: [
        dayData8,
        dayData7,
        dayData6,
        dayData5,
        dayData4,
        dayData3,
        dayData2,
        dayData1
      ]);
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      final listFinder = find.byType(Scrollable);
      await tester.drag(listFinder, const Offset(0, -100));
      await tester.pumpAndSettle();

      expect(find.byType(WeekOverviewGraph), findsOneWidget);
      expect(find.byType(DaySummaryTile), findsAtLeastNWidgets(1));
      expect(find.text('12 Oct 23'), findsOneWidget);
      expect(find.text('120 l/m'), findsAtLeastNWidgets(1));
      expect(find.byType(ExpandableFab), findsOneWidget);

      await tester.drag(listFinder, const Offset(0, -1200));
      await tester.pumpAndSettle();

      expect(find.text('06 Oct 23'), findsOneWidget);
      expect(find.text('114 l/m'), findsAtLeastNWidgets(1));

      expect(find.text('More'), findsOneWidget);

      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();

      expect(find.byType(AllReadingsPage), findsOneWidget);
    });
  });
}
