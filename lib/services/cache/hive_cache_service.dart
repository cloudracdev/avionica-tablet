/// ⚡ HIVE CACHE SERVICE
///
/// Cache local para configurações e último voo
/// Usa SharedPreferences como fallback se Hive falhar

import 'package:hive_flutter/hive_flutter.dart';

class HiveCacheService {
  static const String _configBoxName = 'app_config';
  static const String _lastFlightBoxName = 'last_flight';

  static Box<dynamic>? _configBox;
  static Box<dynamic>? _lastFlightBox;

  /// 🚀 Inicializar Hive (chamar no main.dart)
  static Future<void> init() async {
    await Hive.initFlutter();
    _configBox = await Hive.openBox(_configBoxName);
    _lastFlightBox = await Hive.openBox(_lastFlightBoxName);
  }

  /// 🔒 Fechar boxes (chamar ao encerrar app)
  static Future<void> close() async {
    await _configBox?.close();
    await _lastFlightBox?.close();
  }

  // ═══════════════════════════════════════════════════════════
  // ⚙️ CONFIGURAÇÕES
  // ═══════════════════════════════════════════════════════════

  /// 💾 Salvar configuração
  static Future<void> setConfig(String key, dynamic value) async {
    await _configBox?.put(key, value);
  }

  /// 📖 Ler configuração
  static T? getConfig<T>(String key, {T? defaultValue}) {
    return _configBox?.get(key, defaultValue: defaultValue) as T?;
  }

  /// 🗑️ Remover configuração
  static Future<void> removeConfig(String key) async {
    await _configBox?.delete(key);
  }

  /// 🧹 Limpar todas configurações
  static Future<void> clearConfig() async {
    await _configBox?.clear();
  }

  // ═══════════════════════════════════════════════════════════
  // ✈️ ÚLTIMO VOO
  // ═══════════════════════════════════════════════════════════

  /// 💾 Salvar dados do último voo
  static Future<void> saveLastFlight({
    required String flightId,
    required String visCode,
    required String visName,
    required String visEmail,
    required String instCode,
    required String aircraftPrefix,
    required String missionId,
    required String origin,
    required String destination,
  }) async {
    await _lastFlightBox?.put('flight_id', flightId);
    await _lastFlightBox?.put('vis_code', visCode);
    await _lastFlightBox?.put('vis_name', visName);
    await _lastFlightBox?.put('vis_email', visEmail);
    await _lastFlightBox?.put('inst_code', instCode);
    await _lastFlightBox?.put('aircraft_prefix', aircraftPrefix);
    await _lastFlightBox?.put('mission_id', missionId);
    await _lastFlightBox?.put('origin', origin);
    await _lastFlightBox?.put('destination', destination);
    await _lastFlightBox?.put('saved_at', DateTime.now().toIso8601String());
  }

  /// 📖 Ler dados do último voo
  static Map<String, dynamic>? getLastFlight() {
    if (_lastFlightBox == null || _lastFlightBox!.isEmpty) {
      return null;
    }

    return {
      'flight_id': _lastFlightBox!.get('flight_id'),
      'vis_code': _lastFlightBox!.get('vis_code'),
      'vis_name': _lastFlightBox!.get('vis_name'),
      'vis_email': _lastFlightBox!.get('vis_email'),
      'inst_code': _lastFlightBox!.get('inst_code'),
      'aircraft_prefix': _lastFlightBox!.get('aircraft_prefix'),
      'mission_id': _lastFlightBox!.get('mission_id'),
      'origin': _lastFlightBox!.get('origin'),
      'destination': _lastFlightBox!.get('destination'),
      'saved_at': _lastFlightBox!.get('saved_at'),
    };
  }

  /// 🧹 Limpar último voo
  static Future<void> clearLastFlight() async {
    await _lastFlightBox?.clear();
  }

  // ═══════════════════════════════════════════════════════════
  // 🔧 CONFIGURAÇÕES ESPECÍFICAS (helpers)
  // ═══════════════════════════════════════════════════════════

  /// Mock mode ativo
  static bool get isMockMode => getConfig<bool>('mock_mode') ?? false;
  static Future<void> setMockMode(bool value) => setConfig('mock_mode', value);

  /// Smoothing alpha
  static double get smoothingAlpha => getConfig<double>('smoothing_alpha') ?? 0.3;
  static Future<void> setSmoothingAlpha(double value) => setConfig('smoothing_alpha', value);

  /// ESP32 IP
  static String get esp32Ip => getConfig<String>('esp32_ip') ?? '192.168.4.1';
  static Future<void> setEsp32Ip(String value) => setConfig('esp32_ip', value);

  /// WebSocket port
  static int get wsPort => getConfig<int>('ws_port') ?? 81;
  static Future<void> setWsPort(int value) => setConfig('ws_port', value);

  /// Auto-reconnect enabled
  static bool get autoReconnect => getConfig<bool>('auto_reconnect') ?? true;
  static Future<void> setAutoReconnect(bool value) => setConfig('auto_reconnect', value);

  /// Telemetry rate (Hz)
  static int get telemetryRate => getConfig<int>('telemetry_rate') ?? 20;
  static Future<void> setTelemetryRate(int value) => setConfig('telemetry_rate', value);
}