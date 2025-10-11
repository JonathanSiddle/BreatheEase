import 'package:flutter_test/flutter_test.dart';
import 'package:zensoku/models/app_state.dart';
import 'package:zensoku/models/features/app_feature.dart';

void main() {
  test('initial feature registory as expected', () {
    final fr = FeatureRegistory.defaultStates();
    final expectedList = [
      const Feature(type: FeatureType.unused),
      const Feature(
          type: FeatureType.localStorage, status: FeatureStatus.enabled),
      const Feature(type: FeatureType.dataExport),
      const Feature(type: FeatureType.incidentTracking),
      const Feature(
          type: FeatureType.userTelemetry, status: FeatureStatus.enabled),
    ];

    final features = fr.allFeatures();

    expect(features.length, 5);
    expect(features, unorderedEquals(expectedList));
  });

  test('can get correct features that can be toggled for app state (release)',
      () {
    final fr = FeatureRegistory.defaultStates();
    final expectedList = [
      const Feature(
          type: FeatureType.userTelemetry, status: FeatureStatus.enabled)
    ];

    final actualFeatures = fr.featuresCanBeToggledForAppState(AppState.release);

    expect(actualFeatures.length, 1);
    expect(actualFeatures, unorderedEquals(expectedList));
  });

  test('can get correct features that can be toggled for app state (beta)', () {
    final fr = FeatureRegistory.defaultStates();
    final expectedList = [
      const Feature(
          type: FeatureType.userTelemetry, status: FeatureStatus.enabled),
      const Feature(type: FeatureType.dataExport)
    ];

    final actualFeatures = fr.featuresCanBeToggledForAppState(AppState.beta);

    expect(actualFeatures.length, 2);
    expect(actualFeatures, unorderedEquals(expectedList));
  });

  test('can get correct features that can be toggled for app state (dev)', () {
    final fr = FeatureRegistory.defaultStates();
    final expectedList = [
      const Feature(
          type: FeatureType.userTelemetry, status: FeatureStatus.enabled),
      const Feature(type: FeatureType.dataExport),
      const Feature(type: FeatureType.incidentTracking),
    ];

    final actualFeatures = fr.featuresCanBeToggledForAppState(AppState.dev);

    expect(actualFeatures.length, 3);
    expect(actualFeatures, unorderedEquals(expectedList));
  });
}
