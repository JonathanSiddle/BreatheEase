import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zensoku/logic/settings/settings_cubit.dart';
import 'package:zensoku/logic/settings/settings_page.dart';
import 'package:zensoku/models/features/app_feature.dart';
import 'package:zensoku/repositories/date_time_repository.dart';
import 'package:zensoku/repositories/peak_flow_readings_repository.dart';
import 'package:zensoku/repositories/settings_repository.dart';
import 'package:zensoku/service/peak_flow_reading/in_memory_peak_flow_reading_api.dart';
import 'package:zensoku/util/log_util.dart';

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

  Widget getSettingsWidget({
    SettingsRepository? settingsRepository,
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
              create: (context) => SettingsCubit(
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
}
