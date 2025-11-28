import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Settings for telemetry display behavior.
class TelemetrySettings {
  /// Enable 60fps interpolation for smooth instrument animation
  final bool interpolationEnabled;

  /// Enable EMA smoothing filter for noise reduction
  final bool smoothingEnabled;

  const TelemetrySettings({
    this.interpolationEnabled = true,
    this.smoothingEnabled = true,
  });

  TelemetrySettings copyWith({
    bool? interpolationEnabled,
    bool? smoothingEnabled,
  }) {
    return TelemetrySettings(
      interpolationEnabled: interpolationEnabled ?? this.interpolationEnabled,
      smoothingEnabled: smoothingEnabled ?? this.smoothingEnabled,
    );
  }
}

/// Provider for telemetry display settings.
class TelemetrySettingsNotifier extends StateNotifier<TelemetrySettings> {
  TelemetrySettingsNotifier() : super(const TelemetrySettings());

  void toggleInterpolation() {
    state = state.copyWith(interpolationEnabled: !state.interpolationEnabled);
  }

  void toggleSmoothing() {
    state = state.copyWith(smoothingEnabled: !state.smoothingEnabled);
  }

  void setInterpolation({required bool enabled}) {
    state = state.copyWith(interpolationEnabled: enabled);
  }

  void setSmoothing({required bool enabled}) {
    state = state.copyWith(smoothingEnabled: enabled);
  }
}

/// 🎯 PROVIDER: Telemetry display settings
final telemetrySettingsProvider =
    StateNotifierProvider<TelemetrySettingsNotifier, TelemetrySettings>((ref) {
  return TelemetrySettingsNotifier();
});

/// Convenience provider for interpolation toggle
final interpolationEnabledProvider = Provider<bool>((ref) {
  return ref.watch(telemetrySettingsProvider).interpolationEnabled;
});

/// Convenience provider for smoothing toggle
final smoothingEnabledProvider = Provider<bool>((ref) {
  return ref.watch(telemetrySettingsProvider).smoothingEnabled;
});
