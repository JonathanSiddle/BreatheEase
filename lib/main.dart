import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wiredash/wiredash.dart';
import 'package:zensoku/logic/peak_flow_reading_overview/view/peak_flow_reading_overview_view.dart';
import 'package:zensoku/logic/settings/settings_cubit.dart';
import 'package:zensoku/models/app_state.dart';
import 'package:zensoku/models/features/app_feature.dart';
import 'package:zensoku/models/features/repository_factory.dart';
import 'package:zensoku/repositories/date_time_repository.dart';
import 'package:zensoku/repositories/guid_id_repository.dart';
import 'package:zensoku/repositories/peak_flow_readings_repository.dart';
import 'package:zensoku/repositories/settings_repository.dart';
import 'package:zensoku/static/global_strings.dart';
import 'package:zensoku/util/log_util.dart';
import 'package:zensoku/zensoku_theme.dart';

void main() async {
  final loggingFactory = DefaultLoggingFactory();
  final logger = loggingFactory.getLogger('main');
  logger.d('Starting App!');

  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorage.webStorageDirectory
        : await getApplicationDocumentsDirectory(),
  );

  await dotenv.load();
  final Map<String, bool> boolEnvValues = dotenv.getBoolValues();
  final appState = AppState.fromString(dotenv.get(APP_STATE_ENV));
  final wiredashKey = dotenv.get(WIREDASH_KEY);
  final FeatureRegistory fr = FeatureRegistory.withOverrides(boolEnvValues);

  final (
    peakFlowReadingsRepository,
    guidRepository,
    dateTimeRepository,
    settingsRepository,
  ) = await getReposForFeatures(fr, loggingFactory);

  bootstrap(
      wiredashKey: wiredashKey,
      appState: appState,
      featureRegistory: fr,
      peakFlowReadingsRepository: peakFlowReadingsRepository,
      guidRepository: guidRepository,
      dateTimeRepository: dateTimeRepository,
      settingsRepository: settingsRepository,
      loggingFactory: loggingFactory);
}

void bootstrap(
    {required String wiredashKey,
    required AppState appState,
    required FeatureRegistory featureRegistory,
    required PeakFlowReadingsRepository peakFlowReadingsRepository,
    required SettingsRepository settingsRepository,
    required GuidRepository guidRepository,
    required DateTimeRepository dateTimeRepository,
    required LoggingFactory loggingFactory}) {
  runApp(App(
    wiredashKey: wiredashKey,
    appState: appState,
    featureRegistory: featureRegistory,
    peakFlowReadingsRepository: peakFlowReadingsRepository,
    settingsRepository: settingsRepository,
    guidRepository: guidRepository,
    dateTimeRepository: dateTimeRepository,
    loggingFactory: loggingFactory,
  ));
}

class App extends StatelessWidget {
  const App(
      {required this.wiredashKey,
      required this.appState,
      required this.featureRegistory,
      required this.peakFlowReadingsRepository,
      required this.settingsRepository,
      required this.guidRepository,
      required this.dateTimeRepository,
      required this.loggingFactory,
      super.key});

  final AppState appState;
  final String wiredashKey;
  final FeatureRegistory featureRegistory;
  final PeakFlowReadingsRepository peakFlowReadingsRepository;
  final SettingsRepository settingsRepository;
  final GuidRepository guidRepository;
  final DateTimeRepository dateTimeRepository;
  final LoggingFactory loggingFactory;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(
          value: appState,
        ),
        RepositoryProvider.value(
          value: featureRegistory,
        ),
        RepositoryProvider.value(
          value: peakFlowReadingsRepository,
        ),
        RepositoryProvider.value(
          value: settingsRepository,
        ),
        RepositoryProvider.value(
          value: guidRepository,
        ),
        RepositoryProvider.value(
          value: dateTimeRepository,
        ),
        RepositoryProvider.value(
          value: loggingFactory,
        )
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (context) => SettingsCubit(
                  appState: appState,
                  settingsRepository: settingsRepository,
                  featureRegistory: featureRegistory)),
        ],
        child: AppView(
          wiredashKey: wiredashKey,
          appState: appState,
          loggingFactory: loggingFactory,
        ),
      ),
    );
  }
}

//interject appView here to test logging in
class AppView extends StatelessWidget {
  AppView(
      {super.key,
      required String wiredashKey,
      required LoggingFactory loggingFactory,
      required AppState appState})
      : _logger = loggingFactory.getLogger('[PeakFlowReadingOverviewPage]'),
        _wiredashKey = wiredashKey,
        _appState = appState;

  final Logger _logger;
  final AppState _appState;
  final String _wiredashKey;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  ThemeData _getTheme(ZensokuThemeMode themeMode) {
    switch (themeMode) {
      case ZensokuThemeMode.system:
        final brightness =
            SchedulerBinding.instance.platformDispatcher.platformBrightness;
        return brightness == Brightness.light
            ? ZensokuTheme.lightTheme
            : ZensokuTheme.darkTheme;
      case ZensokuThemeMode.light:
        return ZensokuTheme.lightTheme;
      case ZensokuThemeMode.dark:
        return ZensokuTheme.darkTheme;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, BreatheEaseSettings>(
      builder: (context, state) {
        final materialApp = MaterialApp(
          title: 'BreatheEase',
          navigatorKey: _navigatorKey,
          debugShowCheckedModeBanner: _appState != AppState.release,
          theme: _getTheme(state.mode),
          home: PeakFlowReadingOverviewPage(logger: _logger),
        );

        if (state.isEnabled(FeatureType.userTelemetry) &&
            _appState != AppState.dev) {
          return wrapWithWiredash(materialApp);
        } else {
          return materialApp;
        }
      },
    );
  }

  Widget wrapWithWiredash(Widget widgetToWrap) {
    return Wiredash(
        projectId: 'breatheease-hwc37ap',
        secret: _wiredashKey,
        child: widgetToWrap);
  }
}
