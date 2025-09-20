import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:zensoku/models/features/app_feature.dart';
import 'package:zensoku/repositories/settings_repository.dart';

class SettingsCubit extends HydratedCubit<ZensokuThemeMode> {
  SettingsCubit(
      {required SettingsRepository settingsRepository,
      required FeatureRegistory featureRegistory})
      : _settingsRepository = settingsRepository,
        usingLocalStorage =
            featureRegistory.isEnabled(FeatureType.localStorage),
        super(ZensokuThemeMode.light);

  final SettingsRepository _settingsRepository;
  final bool usingLocalStorage;

  String get pubspecVersion => _settingsRepository.pubspecVersion;

  void updateTheme(ZensokuThemeMode themeMode) => emit(themeMode);

  // This handles the restoration of the theme mode when the app is restarted.
  @override
  ZensokuThemeMode? fromJson(Map<String, dynamic> json) {
    final theme = json['themeMode'];

    switch (theme) {
      case 'ThemeMode.system':
        return ZensokuThemeMode.system;
      case 'ThemeMode.light':
        return ZensokuThemeMode.light;
      case 'ThemeMode.dark':
        return ZensokuThemeMode.dark;
    }
    return ZensokuThemeMode.system;
  }

  // This stores the ThemeMode anytime its changed
  @override
  Map<String, dynamic>? toJson(ZensokuThemeMode state) {
    return {
      'themeMode': state.toString(),
    };
  }
}

enum ZensokuThemeMode { system, light, dark }
