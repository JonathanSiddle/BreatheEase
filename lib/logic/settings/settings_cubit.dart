import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:zensoku/models/app_state.dart';
import 'package:zensoku/models/features/app_feature.dart';
import 'package:zensoku/repositories/settings_repository.dart';

class SettingsCubit extends HydratedCubit<BreatheEaseSettings> {
  SettingsCubit(
      {required AppState appState,
      required SettingsRepository settingsRepository,
      required FeatureRegistory featureRegistory})
      : _appState = appState,
        _settingsRepository = settingsRepository,
        _featureRegistory = featureRegistory,
        usingLocalStorage =
            featureRegistory.isEnabled(FeatureType.localStorage),
        super(BreatheEaseSettings(
            mode: ZensokuThemeMode.light,
            features:
                featureRegistory.featuresCanBeToggledForAppState(appState)));

  final AppState _appState;
  final SettingsRepository _settingsRepository;
  final FeatureRegistory _featureRegistory;
  final bool usingLocalStorage;

  String get pubspecVersion => _settingsRepository.pubspecVersion;

  void updateTheme(ZensokuThemeMode themeMode) =>
      emit(state.copywith(mode: () => themeMode));

  void updateFeature(String key, bool toggle) {
    final updatedFeatures = state.features.map((f) {
      if (f.type.key == key) {
        return f.copyWith(
            status: toggle ? FeatureStatus.enabled : FeatureStatus.disabled);
      }
      return f;
    }).toList();

    emit(state.copywith(features: () => updatedFeatures));
  }

  @override
  BreatheEaseSettings? fromJson(Map<String, dynamic> json) {
    final theme = json['themeMode'];
    final featuresJson = json['features'];
    final Map<String, bool> features = featuresJson is Map<String, dynamic>
        ? featuresJson.cast<String, bool>()
        : <String, bool>{};

    ZensokuThemeMode mode = ZensokuThemeMode.light;
    switch (theme) {
      case 'ZensokuThemeMode.system':
        mode = ZensokuThemeMode.system;
      case 'ZensokuThemeMode.light':
        mode = ZensokuThemeMode.light;
      case 'ZensokuThemeMode.dark':
        mode = ZensokuThemeMode.dark;
    }

    //make sure we are cleaning out any features not available to the current app state
    //this should cover situations where we remove an app feature in future
    final availableFeatures =
        _featureRegistory.featuresCanBeToggledForAppState(_appState);

    //replace default toggle status with saved toggle status
    final updatedFeatures = availableFeatures.map((v) {
      final savedStatus = features[v.type.key];
      if (savedStatus != null) {
        return v.copyWith(
            status:
                savedStatus ? FeatureStatus.enabled : FeatureStatus.disabled);
      }
      return v;
    }).toList();

    return BreatheEaseSettings(mode: mode, features: updatedFeatures);
  }

  // Saves settings when updated
  @override
  Map<String, dynamic>? toJson(BreatheEaseSettings state) {
    final json = {
      'themeMode': state.mode.toString(),
      'features': {for (final f in state.features) f.type.key: f.isEnabled}
    };
    return json;
  }
}

class BreatheEaseSettings {
  const BreatheEaseSettings({required this.mode, required this.features});

  final ZensokuThemeMode mode;
  final List<Feature> features;

  bool isEnabled(FeatureType ft) {
    return features
        .firstWhere((f) => f.type == ft,
            orElse: () => const Feature(type: FeatureType.unused))
        .isEnabled;
  }

  BreatheEaseSettings copywith({
    ZensokuThemeMode Function()? mode,
    List<Feature> Function()? features,
  }) {
    return BreatheEaseSettings(
      mode: mode != null ? mode() : this.mode,
      features: features != null ? features() : this.features,
    );
  }
}

enum ZensokuThemeMode { system, light, dark }
