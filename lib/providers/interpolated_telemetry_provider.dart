import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/telemetry_data.dart';
import '../services/interpolation/interpolation_service.dart';
import 'telemetry_provider.dart';
import 'telemetry_settings_provider.dart';

/// 🎯 PROVIDER: Interpolation service instance
final interpolationServiceProvider = Provider<InterpolationService>((ref) {
  return InterpolationService();
});

/// 🎯 PROVIDER: Interpolated telemetry at 60fps
/// 
/// This provider:
/// 1. Listens to raw telemetry (3-4Hz)
/// 2. Feeds targets to InterpolationService
/// 3. Uses Ticker to emit interpolated values at 60fps
/// 4. Respects interpolation toggle setting
final interpolatedTelemetryProvider =
    StateNotifierProvider<InterpolatedTelemetryNotifier, TelemetryData>((ref) {
  final rawTelemetry = ref.watch(telemetryProvider);
  final interpolationService = ref.watch(interpolationServiceProvider);
  final settings = ref.watch(telemetrySettingsProvider);

  return InterpolatedTelemetryNotifier(
    rawTelemetry: rawTelemetry,
    interpolationService: interpolationService,
    interpolationEnabled: settings.interpolationEnabled,
    ref: ref,
  );
});

/// 🎯 PROVIDER: Stale status (no data > 1 second)
final telemetryStaleProvider = Provider<bool>((ref) {
  final service = ref.watch(interpolationServiceProvider);
  // This will update when interpolatedTelemetryProvider updates
  ref.watch(interpolatedTelemetryProvider);
  return service.isStale;
});

/// Notifier that manages 60fps interpolation ticker.
class InterpolatedTelemetryNotifier extends StateNotifier<TelemetryData> {
  final InterpolationService _interpolationService;
  final bool _interpolationEnabled;
  final Ref _ref;
  
  Ticker? _ticker;
  TelemetryData _lastRawData;

  InterpolatedTelemetryNotifier({
    required TelemetryData rawTelemetry,
    required InterpolationService interpolationService,
    required bool interpolationEnabled,
    required Ref ref,
  })  : _interpolationService = interpolationService,
        _interpolationEnabled = interpolationEnabled,
        _ref = ref,
        _lastRawData = rawTelemetry,
        super(rawTelemetry) {
    // Feed initial data to interpolation service
    _interpolationService.setTarget(rawTelemetry);

    if (_interpolationEnabled) {
      _startTicker();
    }
  }

  void _startTicker() {
    _ticker = Ticker(_onTick);
    _ticker!.start();
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;

    // Check for new raw data
    final currentRaw = _ref.read(telemetryProvider);
    if (currentRaw != _lastRawData) {
      _interpolationService.setTarget(currentRaw);
      _lastRawData = currentRaw;
    }

    // Get interpolated value
    state = _interpolationService.getInterpolated();
  }

  /// Updates with new raw telemetry data.
  /// Called when telemetryProvider changes.
  void updateRawTelemetry(TelemetryData rawData) {
    _lastRawData = rawData;
    _interpolationService.setTarget(rawData);

    if (!_interpolationEnabled) {
      // If interpolation disabled, emit raw data directly
      state = rawData;
    }
  }

  @override
  void dispose() {
    _ticker?.stop();
    _ticker?.dispose();
    super.dispose();
  }
}
