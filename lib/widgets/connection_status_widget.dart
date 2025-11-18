import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/websocket_provider.dart';
import '../providers/telemetry_provider.dart';
import '../providers/connection_watchdog_provider.dart';

/// 📡 WIDGET: Indicador visual de status de conexão
/// 
/// Mostra estado atual da conexão com ESP32:
/// - 🟢 Verde: Conectado + Hz
/// - 🟡 Amarelo: Reconectando + tentativas
/// - 🔴 Vermelho: Desconectado
class ConnectionStatusWidget extends ConsumerWidget {
  const ConnectionStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isConnected = ref.watch(connectionStateProvider);
    final hz = ref.watch(telemetryHzProvider);
    final watchdog = ref.watch(connectionWatchdogProvider);
    final watchdogNotification = ref.watch(watchdogNotificationProvider);
    
    // Determinar estado
    final isReconnecting = watchdogNotification != null && 
                          watchdogNotification.contains('Reconectando');
    
    // Cores semafóricas
    Color statusColor;
    IconData statusIcon;
    String statusText;
    
    if (isReconnecting) {
      // 🟡 RECONECTANDO
      statusColor = Colors.orange;
      statusIcon = Icons.sync;
      statusText = 'Reconectando #${watchdog.currentAttempt}';
    } else if (isConnected && hz > 0) {
      // 🟢 CONECTADO
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = '$hz Hz';
    } else {
      // 🔴 DESCONECTADO
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
      statusText = 'Desconectado';
    }
    
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ícone pulsante se reconectando
          isReconnecting
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                )
              : Icon(
                  statusIcon,
                  color: statusColor,
                  size: 16,
                ),
          const SizedBox(width: 8),
          
          // Texto status
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}