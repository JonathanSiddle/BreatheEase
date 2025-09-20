import 'package:flutter_dotenv/flutter_dotenv.dart';

enum FeatureCategory {
  release('Release', 'Stable features for all users'),
  beta('Beta', 'Preview for new features'),
  ;

  const FeatureCategory(this.displayName, this.description);
  final String displayName;
  final String description;
}

enum FeatureStatus {
  enabled,
  disabled,
}

enum FeatureType {
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
      'Track asthma incidents', FeatureCategory.beta, true, false),
  userTelemetry('user_telemetry', 'Usage Information',
      'Enable basic anonymised usage and ', FeatureCategory.beta, true, false),
  firebaseStorage('firebase_storage', 'Firebase Storage',
      'Save data to firebase', FeatureCategory.release, false, false),
  useProduction('use_production', 'Use Production', 'Uses production server',
      FeatureCategory.release, false, false);

  const FeatureType(this.key, this.displayName, this.description, this.category,
      this.userTogglable, this.isOnByDefault);
  final String key;
  final String displayName;
  final String description;
  final FeatureCategory category;
  final bool userTogglable;
  final bool isOnByDefault;
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
    double? rolloutPercentage,
  }) {
    return Feature(
      type: type,
      status: status ?? this.status,
    );
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

  //TODO: add functionality to toggle firebase and prod off if local_storage is set
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
}

extension EnvExtensions on DotEnv {
  Map<String, bool> getBoolValues() {
    final Map<String, bool> boolKeys = {};

    for (final entry in env.entries) {
      final k = entry.key.toLowerCase();
      final v = entry.value;

      if (v == 'false' || v == 'true') {
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
