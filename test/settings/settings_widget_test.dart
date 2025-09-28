import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zensoku/logic/settings/settings_cubit.dart';
import 'package:zensoku/logic/settings/settings_page.dart';
import 'package:zensoku/models/app_state.dart';
import 'package:zensoku/models/features/app_feature.dart';
import 'package:zensoku/repositories/date_time_repository.dart';
import 'package:zensoku/repositories/peak_flow_readings_repository.dart';
import 'package:zensoku/repositories/settings_repository.dart';
import 'package:zensoku/service/peak_flow_reading/in_memory_peak_flow_reading_api.dart';
import 'package:zensoku/util/log_util.dart';

class MockStorage extends Mock implements HydratedStorage {}

void main() {
  final userTelemetryKey = FeatureType.userTelemetry.key;
  final utKey = Key(userTelemetryKey);
  final unusedKey = FeatureType.unused.key;
  final uKey = Key(unusedKey);
  final localStoreKey = FeatureType.localStorage.key;
  final lsKey = Key(localStoreKey);
  final dataExportKey = FeatureType.dataExport.key;
  final deKey = Key(dataExportKey);
  final incidentTrackingKey = FeatureType.incidentTracking.key;
  final itKey = Key(incidentTrackingKey);

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

  Widget getSettingsWidget({
    SettingsRepository? settingsRepository,
    AppState? appState,
    SettingsCubit? settingsCubit,
  }) {
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
                    InMemoryPeakFlowReadingApi(initReadings: []))),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (context) =>
                  settingsCubit ??
                  SettingsCubit(
                      appState: appState ?? AppState.beta,
                      settingsRepository: settingsRepo,
                      featureRegistory: FeatureRegistory.defaultStates())),
        ],
        child: const MaterialApp(home: SettingsPage()),
      ),
    );
  }

  testWidgets('Can display page', (WidgetTester tester) async {
    await tester.pumpWidget(getSettingsWidget());
    await tester.pumpAndSettle();
    expect(find.byType(SettingsPage), findsOneWidget);
  });

  testWidgets(
      'Can display toggle settings correctly, for default states and release mode, toggling sets featureRegistory state',
      (WidgetTester tester) async {
    final settingsRepo = SettingsRepository(
        packageApi: InMemoryPackageApi(pubspecVersion: '1.0.0'));
    final settingsCubit = SettingsCubit(
        appState: AppState.release,
        settingsRepository: settingsRepo,
        featureRegistory: FeatureRegistory.defaultStates());
    await tester.pumpWidget(getSettingsWidget(settingsCubit: settingsCubit));
    await tester.pumpAndSettle();

    expect(settingsCubit.state.isEnabled(FeatureType.userTelemetry), true);
    expect(settingsCubit.state.isEnabled(FeatureType.dataExport), false);
    expect(settingsCubit.state.isEnabled(FeatureType.incidentTracking), false);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(settingsCubit.state.isEnabled(FeatureType.userTelemetry), false);
    expect(find.byType(SettingsPage), findsOneWidget);
    expect(find.byKey(uKey), findsNothing);
    expect(find.byKey(lsKey), findsNothing);
    expect(find.byKey(deKey), findsNothing);
    expect(find.byKey(itKey), findsNothing);
  });

  testWidgets(
      'Can display toggle settings correctly, for default states and beta mode, toggling sets featureRegistory state',
      (WidgetTester tester) async {
    final settingsRepo = SettingsRepository(
        packageApi: InMemoryPackageApi(pubspecVersion: '1.0.0'));
    final settingsCubit = SettingsCubit(
        appState: AppState.beta,
        settingsRepository: settingsRepo,
        featureRegistory: FeatureRegistory.defaultStates());
    await tester.pumpWidget(getSettingsWidget(settingsCubit: settingsCubit));
    await tester.pumpAndSettle();

    expect(settingsCubit.state.isEnabled(FeatureType.userTelemetry), true);
    expect(settingsCubit.state.isEnabled(FeatureType.dataExport), false);
    expect(settingsCubit.state.isEnabled(FeatureType.incidentTracking), false);

    await tester.tap(
        find.descendant(of: find.byKey(utKey), matching: find.byType(Switch)));
    await tester.pumpAndSettle();
    await tester.tap(
        find.descendant(of: find.byKey(deKey), matching: find.byType(Switch)));
    await tester.pumpAndSettle();

    expect(settingsCubit.state.isEnabled(FeatureType.userTelemetry), false);
    expect(settingsCubit.state.isEnabled(FeatureType.dataExport), true);
    expect(find.byType(SettingsPage), findsOneWidget);
    expect(find.byKey(uKey), findsNothing);
    expect(find.byKey(lsKey), findsNothing);
    expect(find.byKey(itKey), findsNothing);
  });

  testWidgets(
      'Can display toggle settings correctly, for default states and dev mode, toggling sets featureRegistory state',
      (WidgetTester tester) async {
    final settingsRepo = SettingsRepository(
        packageApi: InMemoryPackageApi(pubspecVersion: '1.0.0'));
    final settingsCubit = SettingsCubit(
        appState: AppState.dev,
        settingsRepository: settingsRepo,
        featureRegistory: FeatureRegistory.defaultStates());
    await tester.pumpWidget(getSettingsWidget(settingsCubit: settingsCubit));
    await tester.pumpAndSettle();

    expect(settingsCubit.state.isEnabled(FeatureType.userTelemetry), true);
    expect(settingsCubit.state.isEnabled(FeatureType.dataExport), false);
    expect(settingsCubit.state.isEnabled(FeatureType.incidentTracking), false);

    await tester.tap(
        find.descendant(of: find.byKey(utKey), matching: find.byType(Switch)));
    await tester.pumpAndSettle();
    await tester.tap(
        find.descendant(of: find.byKey(deKey), matching: find.byType(Switch)));
    await tester.pumpAndSettle();
    await tester.tap(
        find.descendant(of: find.byKey(itKey), matching: find.byType(Switch)));
    await tester.pumpAndSettle();

    expect(settingsCubit.state.isEnabled(FeatureType.userTelemetry), false);
    expect(settingsCubit.state.isEnabled(FeatureType.dataExport), true);
    expect(settingsCubit.state.isEnabled(FeatureType.incidentTracking), true);
    expect(find.byType(SettingsPage), findsOneWidget);
    expect(find.byKey(uKey), findsNothing);
    expect(find.byKey(lsKey), findsNothing);
  });
}
