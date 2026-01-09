/// 🌐 SUPABASE SYNC SERVICE
///
/// Implementação real do ISyncRemoteService
/// Envia dados para Supabase (voos + telemetria)

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';
import '../../data/database/models/flight_session_entity.dart';
import '../../data/database/models/telemetry_point_entity.dart';
import '../../core/utils/logger.dart';
import 'i_sync_remote_service.dart';

class SupabaseSyncService implements ISyncRemoteService {
  SupabaseClient get _client => SupabaseConfig.client;

  /// 📤 Criar voo no Supabase (tabela voos)
  /// 
  /// Retorna o UUID do voo criado no Supabase
  Future<String?> createFlight(FlightSessionEntity session) async {
    try {
      final data = {
        'local_id': session.id,
        'aeroclube_id': '11111111-1111-1111-1111-111111111111',
        'instrutor_id': '22222222-2222-2222-2222-222222222222',
        'aeronave_id': '44444444-4444-4444-4444-444444444444',
        'device_id': session.deviceId,
        'inicio_voo': DateTime.fromMillisecondsSinceEpoch(session.startTime).toIso8601String(),
        'fim_voo': session.endTime != null 
            ? DateTime.fromMillisecondsSinceEpoch(session.endTime!).toIso8601String()
            : null,
        'duracao_minutos': session.durationSeconds != null 
            ? (session.durationSeconds! / 60).round() 
            : null,
        'status': _mapStatus(session.status),
        'sync_status': 'synced',
        'metadata': {
          'total_points': session.totalPoints,
          'max_altitude': session.maxAltitude,
          'max_velocity': session.maxVelocity,
          'tablet_battery_start': session.tabletBatteryStart,
          'tablet_battery_end': session.tabletBatteryEnd,
          'data_loss_percent': session.dataLossPercent,
          'connection_drops': session.connectionDrops,
        },
      };

      final response = await _client
          .from('voos')
          .insert(data)
          .select('id')
          .single();

      final vooId = response['id'] as String;
      Logger.info('✅ Voo criado no Supabase: $vooId', 'SupabaseSync');
      return vooId;

    } catch (e) {
      Logger.error('❌ Erro ao criar voo no Supabase', e, null, 'SupabaseSync');
      return null;
    }
  }

  /// 📤 Enviar batch de telemetria
  /// 
  /// Envia lista de pontos para tabela telemetria
  /// Retorna quantidade de pontos inseridos com sucesso
  Future<int> uploadTelemetryBatch(
    String supabaseVooId,
    List<TelemetryPointEntity> points,
  ) async {
    if (points.isEmpty) return 0;

    try {
      final data = points.map((p) => p.toSupabaseMap(supabaseVooId)).toList();

      final response = await _client.from('telemetria').insert(data).select(); print('📤 Telemetria response: $response');

      Logger.debug(
        '📤 Enviou ${points.length} pontos para Supabase',
        'SupabaseSync',
      );

      return points.length;

    } catch (e) {
      print('❌ ERRO TELEMETRIA: $e'); Logger.error('❌ Erro ao enviar telemetria', e, null, 'SupabaseSync');
      return 0;
    }
  }

  /// 📤 Enviar ponto único (para live tracking)
  Future<bool> uploadSinglePoint(
    String supabaseVooId,
    TelemetryPointEntity point,
  ) async {
    try {
      await _client
          .from('telemetria')
          .insert(point.toSupabaseMap(supabaseVooId));

      return true;

    } catch (e) {
      Logger.error('❌ Erro ao enviar ponto', e, null, 'SupabaseSync');
      return false;
    }
  }

  /// 🔍 Buscar voo pelo local_id
  Future<String?> getVooIdByLocalId(String localId) async {
    try {
      final response = await _client
          .from('voos')
          .select('id')
          .eq('local_id', localId)
          .maybeSingle();

      return response?['id'] as String?;

    } catch (e) {
      Logger.error('❌ Erro ao buscar voo', e, null, 'SupabaseSync');
      return null;
    }
  }

  /// �� Atualizar status do voo
  Future<bool> updateFlightStatus(String supabaseVooId, String status) async {
    try {
      await _client
          .from('voos')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', supabaseVooId);

      return true;

    } catch (e) {
      Logger.error('❌ Erro ao atualizar status', e, null, 'SupabaseSync');
      return false;
    }
  }

  /// 🗺️ Converter status local para status Supabase
  String _mapStatus(String localStatus) {
    switch (localStatus) {
      case 'active':
        return 'flying';
      case 'completed':
        return 'completed';
      case 'syncing':
        return 'flying';
      case 'synced':
        return 'completed';
      default:
        return 'scheduled';
    }
  }

  // ============================================
  // 🔌 ISyncRemoteService Interface
  // ============================================

  @override
  Future<SyncResult> uploadFlightSession(FlightSessionEntity session) async {
    final vooId = await createFlight(session);
    
    if (vooId != null) {
      return SyncResult.ok(
        remoteId: vooId,
        serverTimestamp: DateTime.now().millisecondsSinceEpoch,
      );
    }
    
    return SyncResult.error('Falha ao criar voo no Supabase');
  }

  @override
  Future<SyncResult> uploadTelemetry(
    String flightId,
    List<Map<String, dynamic>> points,
  ) async {
    try {
      await _client.from('telemetria').insert(points);
      return SyncResult.ok(
        serverTimestamp: DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      return SyncResult.error(e.toString());
    }
  }

  @override
  Future<bool> existsOnServer(String flightId) async {
    final vooId = await getVooIdByLocalId(flightId);
    return vooId != null;
  }

  @override
  Future<int?> getServerVersion(String flightId) async {
    try {
      final response = await _client
          .from('voos')
          .select('updated_at')
          .eq('local_id', flightId)
          .maybeSingle();

      if (response == null) return null;

      final updatedAt = DateTime.parse(response['updated_at'] as String);
      return updatedAt.millisecondsSinceEpoch;

    } catch (e) {
      return null;
    }
  }
}
