import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:zensoku/models/app_state.dart';

enum FeatureCategory implements Comparable<FeatureCategory> {
  release('Release', 'Stable features for all users', 3),
  beta('Beta', 'Preview for new features', 2),
  dev('Dev', 'Dev features, very WIP', 0),
  ;

  const FeatureCategory(this.displayName, this.description, this.level);
  final String displayName;
  final String description;
  final int level;

  @override
  int compareTo(FeatureCategory other) => level.compareTo(other.level);

  bool operator <(FeatureCategory other) => level < other.level;
  bool operator <=(FeatureCategory other) => level <= other.level;
  bool operator >(FeatureCategory other) => level > other.level;
  bool operator >=(FeatureCategory other) => level >= other.level;
}

enum FeatureStatus {
  enabled,
  disabled,
}

enum FeatureType {
  unused('unused', 'unused', 'prevents null errors', FeatureCategory.release,
      false, false),
  localStorage('local_storage', 'Local Storage', 'Store data locally on device',
      FeatureCategory.release, false, true),
  dataExport(
      'data_export',
      'Data Export',
      'Export data outside of local storage',
      FeatureCategory.beta,
      true,
      false),
  incidentTracking('incident_tracking', 'Incident Tracking',
      'Track asthma incidents', FeatureCategory.dev, true, false),
  userTelemetry(
      'user_telemetry',
      'Usage Information',
      'Enable basic anonymised usage and ',
      FeatureCategory.release,
      true,
      true);

  const FeatureType(this.key, this.displayName, this.description, this.category,
      this.userTogglable, this.isOnByDefault);

  final String key;
  final String displayName;
  final String description;
  final FeatureCategory category;
  final bool userTogglable;
  final bool isOnByDefault;

  static FeatureType fromKey(String key) {
    final featureType = _keyMap[key];

    if (featureType == null) {
      throw ArgumentError('No FeatureType found for $key');
    }

    return featureType;
  }

  static const Map<String, FeatureType> _keyMap = {
    'local_storage': FeatureType.localStorage,
    'data_export': FeatureType.dataExport,
    'incident_tracking': FeatureType.incidentTracking,
    'user_telemetry': FeatureType.userTelemetry,
  };
}

class Feature {
  const Feature({
    required this.type,
    this.status = FeatureStatus.disabled,
  });

  final FeatureType type;
  final FeatureStatus status;

  bool get isEnabled => status == FeatureStatus.enabled;
  bool get isBeta => type.category == FeatureCategory.beta;
  bool get isRelease => type.category == FeatureCategory.release;

  Feature copyWith({
    FeatureStatus? status,
  }) {
    return Feature(
      type: type,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Feature &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          status == other.status;

  @override
  int get hashCode => Object.hash(type, status);

  @override
  String toString() {
    return 'Feature: ${type.displayName}, enabled: $isEnabled';
  }
}

class FeatureRegistory {
  FeatureRegistory.defaultStates() {
    _features = FeatureType.values.map((ft) {
      return Feature(
          type: ft,
          status: ft.isOnByDefault
              ? FeatureStatus.enabled
              : FeatureStatus.disabled);
    }).toList();
  }

  FeatureRegistory.withOverrides(Map<String, bool> overrides) {
    _features = FeatureType.values.map((ft) {
      var status = ft.isOnByDefault;
      final orKey = overrides[ft.key];
      if (orKey != null) {
        status = orKey;
      }

      return Feature(
          type: ft,
          status: status ? FeatureStatus.enabled : FeatureStatus.disabled);
    }).toList();
  }

  late List<Feature> _features;

  bool isEnabled(FeatureType ft) {
    if (_features.where((f) => f.type == ft).first.status ==
        FeatureStatus.enabled) {
      return true;
    } else {
      return false;
    }
  }

  List<Feature> allFeatures() => _features;

  List<Feature> featuresCanBeToggledForAppState(AppState appState) {
    final fc = switch (appState) {
      AppState.release => FeatureCategory.release,
      AppState.beta => FeatureCategory.beta,
      AppState.dev => FeatureCategory.dev,
    };

    //if current category >= the current app state, allow feature
    //we still want to show release features even when the
    //current app state is beta
    return _features
        .where((f) => f.type.category >= fc && f.type.userTogglable)
        .toList();
  }
}

extension EnvExtensions on DotEnv {
  Map<String, bool> getBoolValues() {
    final Map<String, bool> boolKeys = {};

    for (final entry in env.entries) {
      final k = entry.key.toLowerCase();
      final v = entry.value;

      if (v == '' || v == 'true') {
        if (v == 'true') {
          boolKeys[k] = true;
        } else {
          boolKeys[k] = false;
        }
      }
    }

    return boolKeys;
  }
}
