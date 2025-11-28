import '../../core/constants/interpolation_constants.dart';
import '../../models/telemetry_data.dart';

/// Pure interpolation service for smooth 60fps telemetry rendering.
class InterpolationService {
  // Current interpolated values
  double _velocidade = 0;
  double _altitude = 0;
  double _heading = 0;
  double _pitch = 0;
  double _roll = 0;
  double _vario = 0;
  double _temperatura = 0;
  double _pressao = 101325;
  double _lat = 0;
  double _lng = 0;
  double _gyroZ = 0;
  double _accelX = 0;
  double _accelY = 0;

  // Spring velocities
  double _velocityPitch = 0;
  double _velocityRoll = 0;
  double _velocityVario = 0;
  double _velocityGyroZ = 0;
  double _velocityAccelX = 0;
  double _velocityAccelY = 0;

  // Target values
  double _targetVelocidade = 0;
  double _targetAltitude = 0;
  double _targetHeading = 0;
  double _targetPitch = 0;
  double _targetRoll = 0;
  double _targetVario = 0;
  double _targetTemperatura = 0;
  double _targetPressao = 101325;
  double _targetLat = 0;
  double _targetLng = 0;
  double _targetGyroZ = 0;
  double _targetAccelX = 0;
  double _targetAccelY = 0;

  // Timing
  DateTime _lastUpdateTime = DateTime.now();
  DateTime _lastTargetTime = DateTime.now();
  bool _initialized = false;

  void setTarget(TelemetryData data) {
    _lastTargetTime = DateTime.now();
    if (!_initialized) {
      _snapToTarget(data);
      _initialized = true;
      return;
    }
    _targetVelocidade = data.velocidade;
    _targetAltitude = data.altitude;
    _targetHeading = data.heading;
    _targetPitch = data.pitch;
    _targetRoll = data.roll;
    _targetVario = data.vario;
    _targetTemperatura = data.temperatura;
    _targetPressao = data.pressao;
    _targetLat = data.lat;
    _targetLng = data.lng;
    _targetGyroZ = data.gyroZ;
    _targetAccelX = data.accelX;
    _targetAccelY = data.accelY;
  }

  TelemetryData getInterpolated() {
    final now = DateTime.now();
    double deltaTime = now.difference(_lastUpdateTime).inMilliseconds / 1000.0;
    _lastUpdateTime = now;

    if (!_initialized) return TelemetryData.initial();

    // 🛡️ FIX 1: Clamp deltaTime para evitar explosão após background
    // Max 100ms (0.1s) - se maior, provavelmente voltou do background
    if (deltaTime > InterpolationConstants.maxDeltaTimeSeconds) {
      // Reset velocidades spring para evitar aceleração absurda
      _velocityPitch = 0;
      _velocityRoll = 0;
      _velocityVario = 0;
      _velocityGyroZ = 0;
      _velocityAccelX = 0;
      _velocityAccelY = 0;
      deltaTime = InterpolationConstants.maxDeltaTimeSeconds;
    }

    final timeSinceLastTarget = now.difference(_lastTargetTime).inMilliseconds;
    if (timeSinceLastTarget > InterpolationConstants.maxInterpolationTimeMs) {
      return _buildTelemetryData();
    }

    _interpolateLinear(deltaTime);
    _interpolateSpring(deltaTime);
    _interpolateCircular(deltaTime);

    // 🛡️ FIX 2: Clamp valores para ranges físicos válidos
    _clampAllValues();

    return _buildTelemetryData();
  }

  bool get isStale {
    final elapsed = DateTime.now().difference(_lastTargetTime).inMilliseconds;
    return elapsed > InterpolationConstants.staleTimeoutMs;
  }

  int get timeSinceLastUpdate {
    return DateTime.now().difference(_lastTargetTime).inMilliseconds;
  }

  void reset() {
    _initialized = false;
    _velocidade = _altitude = _heading = _pitch = _roll = _vario = 0;
    _temperatura = 0;
    _pressao = 101325;
    _lat = _lng = _gyroZ = _accelX = _accelY = 0;
    _velocityPitch = _velocityRoll = _velocityVario = 0;
    _velocityGyroZ = _velocityAccelX = _velocityAccelY = 0;
  }

  void _snapToTarget(TelemetryData data) {
    _velocidade = _targetVelocidade = data.velocidade;
    _altitude = _targetAltitude = data.altitude;
    _heading = _targetHeading = data.heading;
    _pitch = _targetPitch = data.pitch;
    _roll = _targetRoll = data.roll;
    _vario = _targetVario = data.vario;
    _temperatura = _targetTemperatura = data.temperatura;
    _pressao = _targetPressao = data.pressao;
    _lat = _targetLat = data.lat;
    _lng = _targetLng = data.lng;
    _gyroZ = _targetGyroZ = data.gyroZ;
    _accelX = _targetAccelX = data.accelX;
    _accelY = _targetAccelY = data.accelY;
    _lastUpdateTime = DateTime.now();
  }

  void _interpolateLinear(double deltaTime) {
    _velocidade = _lerp(
      _velocidade,
      _targetVelocidade,
      InterpolationConstants.lerpSpeedVelocidade,
    );
    _altitude = _lerp(
      _altitude,
      _targetAltitude,
      InterpolationConstants.lerpSpeedAltitude,
    );
    _temperatura = _lerp(
      _temperatura,
      _targetTemperatura,
      InterpolationConstants.lerpSpeedTemperatura,
    );
    _pressao = _lerp(
      _pressao,
      _targetPressao,
      InterpolationConstants.lerpSpeedPressao,
    );
    _lat = _lerp(_lat, _targetLat, InterpolationConstants.lerpSpeedGps);
    _lng = _lerp(_lng, _targetLng, InterpolationConstants.lerpSpeedGps);
  }

  void _interpolateSpring(double deltaTime) {
    final pitchResult = _springInterpolate(
      _pitch,
      _targetPitch,
      _velocityPitch,
      InterpolationConstants.springStiffnessPitch,
      InterpolationConstants.springDampingPitch,
      deltaTime,
    );
    _pitch = pitchResult.$1;
    _velocityPitch = pitchResult.$2;

    final rollResult = _springInterpolate(
      _roll,
      _targetRoll,
      _velocityRoll,
      InterpolationConstants.springStiffnessRoll,
      InterpolationConstants.springDampingRoll,
      deltaTime,
    );
    _roll = rollResult.$1;
    _velocityRoll = rollResult.$2;

    final varioResult = _springInterpolate(
      _vario,
      _targetVario,
      _velocityVario,
      InterpolationConstants.springStiffnessVario,
      InterpolationConstants.springDampingVario,
      deltaTime,
    );
    _vario = varioResult.$1;
    _velocityVario = varioResult.$2;

    final gyroResult = _springInterpolate(
      _gyroZ,
      _targetGyroZ,
      _velocityGyroZ,
      InterpolationConstants.springStiffnessGyroZ,
      InterpolationConstants.springDampingGyroZ,
      deltaTime,
    );
    _gyroZ = gyroResult.$1;
    _velocityGyroZ = gyroResult.$2;

    final accelXResult = _springInterpolate(
      _accelX,
      _targetAccelX,
      _velocityAccelX,
      InterpolationConstants.springStiffnessAccel,
      InterpolationConstants.springDampingAccel,
      deltaTime,
    );
    _accelX = accelXResult.$1;
    _velocityAccelX = accelXResult.$2;

    final accelYResult = _springInterpolate(
      _accelY,
      _targetAccelY,
      _velocityAccelY,
      InterpolationConstants.springStiffnessAccel,
      InterpolationConstants.springDampingAccel,
      deltaTime,
    );
    _accelY = accelYResult.$1;
    _velocityAccelY = accelYResult.$2;
  }

  void _interpolateCircular(double deltaTime) {
    _heading = _lerpCircular(
      _heading,
      _targetHeading,
      InterpolationConstants.lerpSpeedHeading,
    );
  }

  /// 🛡️ Clamp all values to physically valid ranges
  void _clampAllValues() {
    _velocidade = _velocidade.clamp(
      InterpolationConstants.minVelocidade,
      InterpolationConstants.maxVelocidade,
    );
    _altitude = _altitude.clamp(
      InterpolationConstants.minAltitude,
      InterpolationConstants.maxAltitude,
    );
    _heading = _normalizeAngle(_heading);
    _pitch = _pitch.clamp(
      InterpolationConstants.minPitch,
      InterpolationConstants.maxPitch,
    );
    _roll = _roll.clamp(
      InterpolationConstants.minRoll,
      InterpolationConstants.maxRoll,
    );
    _vario = _vario.clamp(
      InterpolationConstants.minVario,
      InterpolationConstants.maxVario,
    );
    _temperatura = _temperatura.clamp(
      InterpolationConstants.minTemperatura,
      InterpolationConstants.maxTemperatura,
    );
    _pressao = _pressao.clamp(
      InterpolationConstants.minPressao,
      InterpolationConstants.maxPressao,
    );
    _gyroZ = _gyroZ.clamp(
      InterpolationConstants.minGyroZ,
      InterpolationConstants.maxGyroZ,
    );
    _accelX = _accelX.clamp(
      InterpolationConstants.minAccel,
      InterpolationConstants.maxAccel,
    );
    _accelY = _accelY.clamp(
      InterpolationConstants.minAccel,
      InterpolationConstants.maxAccel,
    );
  }

  double _lerp(double current, double target, double speed) {
    return current + (target - current) * speed;
  }

  double _lerpCircular(double current, double target, double speed) {
    current = _normalizeAngle(current);
    target = _normalizeAngle(target);
    double diff = target - current;
    if (diff > 180) diff -= 360;
    if (diff < -180) diff += 360;
    return _normalizeAngle(current + diff * speed);
  }

  double _normalizeAngle(double angle) {
    while (angle < 0) angle += 360;
    while (angle >= 360) angle -= 360;
    return angle;
  }

  (double, double) _springInterpolate(
    double current,
    double target,
    double velocity,
    double stiffness,
    double damping,
    double deltaTime,
  ) {
    final displacement = current - target;
    final springForce = -stiffness * displacement;
    final dampingForce = -damping * velocity;
    final acceleration = springForce + dampingForce;
    final newVelocity = velocity + acceleration * deltaTime;
    final newValue = current + newVelocity * deltaTime;
    return (newValue, newVelocity);
  }

  TelemetryData _buildTelemetryData() {
    return TelemetryData(
      velocidade: _velocidade,
      altitude: _altitude,
      heading: _heading,
      pitch: _pitch,
      roll: _roll,
      vario: _vario,
      temperatura: _temperatura,
      pressao: _pressao,
      lat: _lat,
      lng: _lng,
      gyroZ: _gyroZ,
      accelX: _accelX,
      accelY: _accelY,
      timestamp: DateTime.now(),
      gpsValid: true,
    );
  }
}
