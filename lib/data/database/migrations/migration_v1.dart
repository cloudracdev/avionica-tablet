/// 🗄️ DATABASE SCHEMA V1
/// 
/// Schema inicial para persistência offline de voos
/// Estrutura otimizada para:
/// - Telemetria 20Hz (72k pontos/hora)
/// - Offline-first
/// - Sync posterior WiFi/4G
/// - 1 database por voo

class MigrationV1 {
  /// 📅 Versão do schema
  static const int version = 1;

  /// 🏗️ SQL completo para criação inicial
  static const String create = '''
    -- ==========================================
    -- 📋 FLIGHT SESSION (Metadata do Voo)
    -- ==========================================
    CREATE TABLE flight_session (
      id TEXT PRIMARY KEY NOT NULL,
      
      -- 👥 Participantes
      instructor_id TEXT NOT NULL,
      student_id TEXT,
      aircraft_id TEXT NOT NULL,
      
      -- ⏰ Timestamps (epoch milliseconds)
      start_time INTEGER NOT NULL,
      end_time INTEGER,
      created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000),
      updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000),
      
      -- 🔄 Sync Control
      status TEXT NOT NULL DEFAULT 'active',
      -- Possíveis valores: 'active', 'completed', 'syncing', 'synced', 'failed'
      
      sync_status TEXT NOT NULL DEFAULT 'pending',
      -- Possíveis valores: 'pending', 'in_progress', 'completed', 'failed'
      
      sync_attempts INTEGER NOT NULL DEFAULT 0,
      last_sync_attempt INTEGER,
      sync_error TEXT,
      
      -- 📊 Estatísticas do Voo
      total_points INTEGER NOT NULL DEFAULT 0,
      duration_seconds INTEGER,
      max_altitude REAL,
      max_velocity REAL,
      distance_km REAL,
      
      -- 🎯 Metadados
      mission_type TEXT,
      weather_conditions TEXT,
      notes TEXT,
      
      -- 🔧 Device Info
      device_id TEXT,
      app_version TEXT,
      
      -- 🔋 Tablet Battery Monitoring
      tablet_battery_start INTEGER,
      -- Bateria inicial (%) no início do voo [0-100]
      
      tablet_battery_end INTEGER,
      -- Bateria final (%) no fim do voo [0-100]
      
      tablet_battery_drain_rate REAL,
      -- Taxa drain calculada (%/hora)
      
      -- ⚠️ Quality Metrics
      data_loss_percent REAL DEFAULT 0.0,
      connection_drops INTEGER DEFAULT 0
    );

    -- ==========================================
    -- 📡 TELEMETRY POINTS (Dados Sensores)
    -- ==========================================
    CREATE TABLE telemetry_points (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      
      -- ⏰ Timestamp (epoch milliseconds)
      timestamp INTEGER NOT NULL,
      
      -- 📍 GPS (7+ decimais precisão)
      lat REAL NOT NULL,
      lng REAL NOT NULL,
      gps_altitude REAL,
      gps_speed REAL,
      gps_heading REAL,
      gps_satellites INTEGER,
      gps_hdop REAL,
      
      -- 📏 Barômetro
      baro_altitude REAL,
      baro_pressure REAL,
      baro_temperature REAL,
      
      -- 🧭 Compass/Magnetometer
      mag_heading REAL,
      mag_x REAL,
      mag_y REAL,
      mag_z REAL,
      
      -- 📐 Acelerômetro (m/s²)
      accel_x REAL,
      accel_y REAL,
      accel_z REAL,
      
      -- 🔄 Giroscópio (deg/s)
      gyro_x REAL,
      gyro_y REAL,
      gyro_z REAL,
      
      -- 🎯 IMU (Integrated Motion Unit)
      imu_pitch REAL,
      imu_roll REAL,
      imu_yaw REAL,
      
      -- 📊 Dados Calculados
      velocity REAL,
      altitude REAL,
      heading REAL,
      vertical_speed REAL,
      
      -- 🔧 Quality Indicators
      data_quality TEXT DEFAULT 'valid',
      -- Possíveis valores: 'valid', 'interpolated', 'fallback', 'invalid'
      
      sensor_status TEXT,
      -- JSON com status individual de cada sensor
      
      -- 💾 Backup JSON Completo
      raw_json TEXT,
      -- JSON completo do pacote para debug/recovery
      
      -- 🆔 Foreign Key
      flight_session_id TEXT NOT NULL,
      
      FOREIGN KEY (flight_session_id) REFERENCES flight_session(id) ON DELETE CASCADE
    );

    -- ==========================================
    -- 📝 EVALUATION (Avaliação FAP)
    -- ==========================================
    CREATE TABLE evaluation (
      id TEXT PRIMARY KEY NOT NULL,
      flight_session_id TEXT NOT NULL,
      
      -- ⏰ Timestamps
      created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000),
      updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000),
      
      -- 📋 Avaliação FAP (JSON)
      fap_data TEXT NOT NULL,
      -- JSON completo com todas as habilidades avaliadas
      -- Estrutura: {skills: [{name, grade, notes}], overall_grade, recommendations}
      
      -- 📊 Métricas Gerais
      overall_grade REAL,
      flight_hours_logged REAL,
      
      -- 📝 Observações
      instructor_notes TEXT,
      student_notes TEXT,
      
      -- ✅ Status
      status TEXT NOT NULL DEFAULT 'draft',
      -- Possíveis valores: 'draft', 'completed', 'synced'
      
      signed_at INTEGER,
      signature_data TEXT,
      -- Base64 da assinatura digital (pós-MVP)
      
      FOREIGN KEY (flight_session_id) REFERENCES flight_session(id) ON DELETE CASCADE
    );

    -- ==========================================
    -- 📸 PHOTOS (Fotos do Voo)
    -- ==========================================
    CREATE TABLE photos (
      id TEXT PRIMARY KEY NOT NULL,
      flight_session_id TEXT NOT NULL,
      
      -- 📁 Arquivo
      file_path TEXT NOT NULL,
      file_name TEXT NOT NULL,
      file_size_bytes INTEGER,
      mime_type TEXT DEFAULT 'image/jpeg',
      
      -- ⏰ Timestamps
      taken_at INTEGER NOT NULL,
      created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000),
      
      -- 📍 Geolocalização (se disponível)
      lat REAL,
      lng REAL,
      altitude REAL,
      
      -- 🏷️ Metadados
      category TEXT,
      -- Possíveis valores: 'pre_flight', 'cockpit', 'exterior', 'post_flight', 'damage', 'other'
      
      description TEXT,
      tags TEXT,
      -- JSON array de tags
      
      -- 🔄 Sync
      synced INTEGER NOT NULL DEFAULT 0,
      -- 0 = pending, 1 = synced
      
      sync_attempts INTEGER NOT NULL DEFAULT 0,
      last_sync_attempt INTEGER,
      
      -- 🖼️ Thumbnail
      thumbnail_path TEXT,
      
      FOREIGN KEY (flight_session_id) REFERENCES flight_session(id) ON DELETE CASCADE
    );

    -- ==========================================
    -- 🚀 PERFORMANCE INDEXES
    -- ==========================================
    
    -- Índice para queries por timestamp (replay, análise)
    CREATE INDEX idx_telemetry_timestamp 
    ON telemetry_points(timestamp);
    
    -- Índice composto para queries filtradas por voo + tempo
    CREATE INDEX idx_telemetry_session_time 
    ON telemetry_points(flight_session_id, timestamp);
    
    -- Índice para localizar pontos geográficos (mapa)
    CREATE INDEX idx_telemetry_location 
    ON telemetry_points(lat, lng);
    
    -- Índice para quality checks
    CREATE INDEX idx_telemetry_quality 
    ON telemetry_points(data_quality);
    
    -- Índice para status de sync (queries de pendências)
    CREATE INDEX idx_session_sync_status 
    ON flight_session(sync_status);
    
    -- Índice para fotos não sincronizadas
    CREATE INDEX idx_photos_sync 
    ON photos(synced, flight_session_id);
    
    -- Índice para avaliações por voo
    CREATE INDEX idx_evaluation_session 
    ON evaluation(flight_session_id);

    -- ==========================================
    -- ✅ CONSTRAINTS & VALIDATIONS
    -- ==========================================
    
    -- Validar status do voo
    CREATE TRIGGER validate_flight_session_status
    BEFORE INSERT ON flight_session
    BEGIN
      SELECT CASE
        WHEN NEW.status NOT IN ('active', 'completed', 'syncing', 'synced', 'failed')
        THEN RAISE(ABORT, 'Invalid flight_session.status')
      END;
    END;
    
    -- Validar sync_status
    CREATE TRIGGER validate_sync_status
    BEFORE INSERT ON flight_session
    BEGIN
      SELECT CASE
        WHEN NEW.sync_status NOT IN ('pending', 'in_progress', 'completed', 'failed')
        THEN RAISE(ABORT, 'Invalid sync_status')
      END;
    END;
    
    -- Validar coordenadas GPS (latitude: -90 a 90, longitude: -180 a 180)
    CREATE TRIGGER validate_telemetry_coordinates
    BEFORE INSERT ON telemetry_points
    BEGIN
      SELECT CASE
        WHEN NEW.lat < -90 OR NEW.lat > 90
        THEN RAISE(ABORT, 'Invalid latitude: must be between -90 and 90')
        WHEN NEW.lng < -180 OR NEW.lng > 180
        THEN RAISE(ABORT, 'Invalid longitude: must be between -180 and 180')
      END;
    END;
    
    -- Validar bateria tablet (0-100%)
    CREATE TRIGGER validate_tablet_battery
    BEFORE INSERT ON flight_session
    BEGIN
      SELECT CASE
        WHEN NEW.tablet_battery_start IS NOT NULL 
          AND (NEW.tablet_battery_start < 0 OR NEW.tablet_battery_start > 100)
        THEN RAISE(ABORT, 'Invalid tablet_battery_start: must be between 0 and 100')
        WHEN NEW.tablet_battery_end IS NOT NULL 
          AND (NEW.tablet_battery_end < 0 OR NEW.tablet_battery_end > 100)
        THEN RAISE(ABORT, 'Invalid tablet_battery_end: must be between 0 and 100')
      END;
    END;
    
    -- Auto-update do updated_at
    CREATE TRIGGER update_flight_session_timestamp
    AFTER UPDATE ON flight_session
    BEGIN
      UPDATE flight_session 
      SET updated_at = strftime('%s', 'now') * 1000
      WHERE id = NEW.id;
    END;
    
    -- Auto-update contador de pontos
    CREATE TRIGGER increment_total_points
    AFTER INSERT ON telemetry_points
    BEGIN
      UPDATE flight_session 
      SET total_points = total_points + 1
      WHERE id = NEW.flight_session_id;
    END;
  ''';

  /// 🗑️ SQL para rollback (desenvolvimento/testes)
  static const String drop = '''
    DROP TRIGGER IF EXISTS increment_total_points;
    DROP TRIGGER IF EXISTS update_flight_session_timestamp;
    DROP TRIGGER IF EXISTS validate_tablet_battery;
    DROP TRIGGER IF EXISTS validate_telemetry_coordinates;
    DROP TRIGGER IF EXISTS validate_sync_status;
    DROP TRIGGER IF EXISTS validate_flight_session_status;
    
    DROP INDEX IF EXISTS idx_evaluation_session;
    DROP INDEX IF EXISTS idx_photos_sync;
    DROP INDEX IF EXISTS idx_session_sync_status;
    DROP INDEX IF EXISTS idx_telemetry_quality;
    DROP INDEX IF EXISTS idx_telemetry_location;
    DROP INDEX IF EXISTS idx_telemetry_session_time;
    DROP INDEX IF EXISTS idx_telemetry_timestamp;
    
    DROP TABLE IF EXISTS photos;
    DROP TABLE IF EXISTS evaluation;
    DROP TABLE IF EXISTS telemetry_points;
    DROP TABLE IF EXISTS flight_session;
  ''';

  /// 📊 Estatísticas do Schema
  static const Map<String, dynamic> stats = {
    'version': 1,
    'tables': 4,
    'indexes': 7,
    'triggers': 6, // Atualizado: +1 trigger de validação bateria
    'estimated_size_per_hour': '2.5MB', // 72k pontos comprimidos
    'max_points_per_flight': 144000, // 2h voo @ 20Hz
  };
}