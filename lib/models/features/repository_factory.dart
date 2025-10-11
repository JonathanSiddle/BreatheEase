import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:zensoku/models/features/app_feature.dart';
import 'package:zensoku/repositories/date_time_repository.dart';
import 'package:zensoku/repositories/guid_id_repository.dart';
import 'package:zensoku/repositories/peak_flow_readings_repository.dart';
import 'package:zensoku/repositories/settings_repository.dart';
import 'package:zensoku/service/peak_flow_reading/sqlite_peak_flow_reading_api.dart';
import 'package:zensoku/service/sqlite_service.dart';
import 'package:zensoku/util/log_util.dart';

Future<
    (
      PeakFlowReadingsRepository,
      GuidRepository,
      DateTimeRepository,
      SettingsRepository,
    )> getReposForFeatures(FeatureRegistory fr, LoggingFactory lf) async {
  late PeakFlowReadingsRepository peakFlowReadingsRepository;
  late GuidRepository guidRepository;
  late DateTimeRepository dateTimeRepository;
  late SettingsRepository settingsRepository;

  //settings repo stuff
  final info = await PackageInfo.fromPlatform();
  final packageApi = PubspecPackageApi(packageInfo: info);
  settingsRepository = SettingsRepository(
    packageApi: packageApi,
  );
  dateTimeRepository = DateTimeRepository();
  const uuid = Uuid();
  guidRepository = GuidRepository(guidProvider: () => uuid.v4());

  final localdb = await SqliteService.database;

  //repos we actually care about - use SQLite for local storage
  final peakFlowReadingsAPI = SqlitePeakFlowReadingApi(database: localdb);
  peakFlowReadingsRepository =
      PeakFlowReadingsRepository(peakFlowReadingApi: peakFlowReadingsAPI);

  return Future.value((
    peakFlowReadingsRepository,
    guidRepository,
    dateTimeRepository,
    settingsRepository,
  ));
}
