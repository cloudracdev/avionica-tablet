/// 📡 CONNECTIVITY SERVICE
///
/// Detecta estado REAL da conexão de rede
/// ⚠️ Verifica internet REAL (não só WiFi conectado)
import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/utils/logger.dart';

enum ConnectivityType { none, wifi, mobile, ethernet }

class ConnectivityState {
  final ConnectivityType type;
  final bool isConnected;
  final bool hasInternet;
  final DateTime timestamp;

  const ConnectivityState({
    required this.type,
    required this.isConnected,
    required this.hasInternet,
    required this.timestamp,
  });

  factory ConnectivityState.disconnected() => ConnectivityState(
    type: ConnectivityType.none,
    isConnected: false,
    hasInternet: false,
    timestamp: DateTime.now(),
  );

  bool get canSync => isConnected && hasInternet;
}

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final _controller = StreamController<ConnectivityState>.broadcast();
  ConnectivityState _currentState = ConnectivityState.disconnected();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _internetCheckTimer;

  ConnectivityState get currentState => _currentState;
  Stream<ConnectivityState> get onConnectivityChanged => _controller.stream;
  bool get isConnected => _currentState.isConnected;
  bool get canSync => _currentState.canSync;

  Future<void> initialize() async {
    final results = await _connectivity.checkConnectivity();
    await _updateFromResults(results);
    _subscription = _connectivity.onConnectivityChanged.listen(_updateFromResults);
    _internetCheckTimer = Timer.periodic(const Duration(seconds: 10), (_) => _checkInternet());
  }

  Future<void> _updateFromResults(List<ConnectivityResult> results) async {
    ConnectivityType type = ConnectivityType.none;
    for (final result in results) {
      if (result == ConnectivityResult.mobile) type = ConnectivityType.mobile;
      if (result == ConnectivityResult.wifi && type != ConnectivityType.mobile) type = ConnectivityType.wifi;
      if (result == ConnectivityResult.ethernet) type = ConnectivityType.ethernet;
    }
    
    bool hasInternet = false;
    if (type != ConnectivityType.none) {
      hasInternet = await _checkInternet();
    }

    final newState = ConnectivityState(
      type: type,
      isConnected: type != ConnectivityType.none,
      hasInternet: hasInternet,
      timestamp: DateTime.now(),
    );
    
    if (_currentState.canSync != newState.canSync) {
      Logger.info('🌐 Conectividade: ${newState.type}, internet: ${newState.hasInternet}', 'Connectivity');
    }
    _currentState = newState;
    _controller.add(newState);
  }

  Future<bool> _checkInternet() async {
    try {
      final result = await InternetAddress.lookup('supabase.avionica.quadritech.com.br')
          .timeout(const Duration(seconds: 3));
      final hasInternet = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      if (hasInternet != _currentState.hasInternet) {
        _currentState = ConnectivityState(
          type: _currentState.type,
          isConnected: _currentState.isConnected,
          hasInternet: hasInternet,
          timestamp: DateTime.now(),
        );
        _controller.add(_currentState);
      }
      return hasInternet;
    } catch (e) {
      Logger.warning('⚠️ Sem internet real: $e', 'Connectivity');
      return false;
    }
  }

  void dispose() {
    _subscription?.cancel();
    _internetCheckTimer?.cancel();
    _controller.close();
  }
}
