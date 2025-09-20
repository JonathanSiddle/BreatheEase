import 'package:package_info_plus/package_info_plus.dart';

class SettingsRepository {
  const SettingsRepository({required PackageApi packageApi})
      : _packageApi = packageApi;

  final PackageApi _packageApi;

  String get pubspecVersion => _packageApi.pubspecVersion;
}

abstract class PackageApi {
  String get pubspecVersion;
}

class PubspecPackageApi implements PackageApi {
  PubspecPackageApi({required PackageInfo packageInfo})
      : _packageInfo = packageInfo;

  final PackageInfo _packageInfo;

  @override
  String get pubspecVersion => _packageInfo.version;
}

class InMemoryPackageApi implements PackageApi {
  InMemoryPackageApi({required String pubspecVersion})
      : _pubspecVersion = pubspecVersion;

  final String _pubspecVersion;

  @override
  String get pubspecVersion => _pubspecVersion;
}
