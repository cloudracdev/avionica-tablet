/// 🗄️ DATABASE SCHEMA V1 - STATEMENTS SEPARADOS
/// 
/// Lista de SQL statements para execução individual
/// sqflite não suporta múltiplos statements em um execute()

class MigrationV1Statements {
  static const int version = 1;

  static const List<String> statements = [
    // 1. FLIGHT SESSION
    '''CREATE TABLE flight_session (
      id TEXT PRIMARY KEY NOT NULL,
      instructor_id TEXT NOT NULL,
      student_id TEXT,
      aircraft_id TEXT NOT NULL,
      start_time INTEGER NOT NULL,
      end_time INTEGER,
      created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000),
      updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000),
      status TEXT NOT NULL DEFAULT 'active',
      sync_status TEXT NOT NULL DEFAULT 'pending',
      sync_attempts INTEGER NOT NULL DEFAULT 0,
      last_sync_attempt INTEGER,
      sync_error TEXT,
      total_points INTEGER NOT NULL DEFAULT 0,
      duration_seconds INTEGER,
      max_altitude REAL,
      max_velocity REAL,
      distance_km REAL,
      mission_type TEXT,
      weather_conditions TEXT,
      notes TEXT,
      device_id TEXT,
      app_version TEXT,
      tablet_battery_start INTEGER,
      tablet_battery_end INTEGER,
      tablet_battery_drain_rate REAL,
      data_loss_percent REAL DEFAULT 0.0,
      connection_drops INTEGER DEFAULT 0
    )''',

    // 2. TELEMETRY POINTS (com campos sync)
    '''CREATE TABLE telemetry_points (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      flight_session_id TEXT NOT NULL,
      timestamp INTEGER NOT NULL,
      lat REAL NOT NULL,
      lng REAL NOT NULL,
      gps_altitude REAL,
      gps_speed REAL,
      gps_heading REAL,
      gps_satellites INTEGER,
      gps_hdop REAL,
      baro_altitude REAL,
      baro_pressure REAL,
      baro_temperature REAL,
      mag_heading REAL,
      mag_x REAL,
      mag_y REAL,
      mag_z REAL,
      accel_x REAL,
      accel_y REAL,
      accel_z REAL,
      gyro_x REAL,
      gyro_y REAL,
      gyro_z REAL,
      imu_pitch REAL,
      imu_roll REAL,
      imu_yaw REAL,
      velocity REAL,
      altitude REAL,
      heading REAL,
      vertical_speed REAL,
      data_quality TEXT DEFAULT 'valid',
      sensor_status TEXT,
      raw_json TEXT,
      synced INTEGER NOT NULL DEFAULT 0,
      synced_at INTEGER,
      FOREIGN KEY (flight_session_id) REFERENCES flight_session(id) ON DELETE CASCADE
    )''',

    // 3. EVALUATION
    '''CREATE TABLE evaluation (
      id TEXT PRIMARY KEY NOT NULL,
      flight_session_id TEXT NOT NULL,
      created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000),
      updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000),
      fap_data TEXT NOT NULL,
      overall_grade REAL,
      flight_hours_logged REAL,
      instructor_notes TEXT,
      student_notes TEXT,
      status TEXT NOT NULL DEFAULT 'draft',
      signed_at INTEGER,
      signature_data TEXT,
      FOREIGN KEY (flight_session_id) REFERENCES flight_session(id) ON DELETE CASCADE
    )''',

    // 4. PHOTOS
    '''CREATE TABLE photos (
      id TEXT PRIMARY KEY NOT NULL,
      flight_session_id TEXT NOT NULL,
      file_path TEXT NOT NULL,
      file_name TEXT NOT NULL,
      file_size_bytes INTEGER,
      mime_type TEXT DEFAULT 'image/jpeg',
      taken_at INTEGER NOT NULL,
      created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000),
      lat REAL,
      lng REAL,
      altitude REAL,
      category TEXT,
      description TEXT,
      tags TEXT,
      synced INTEGER NOT NULL DEFAULT 0,
      sync_attempts INTEGER NOT NULL DEFAULT 0,
      last_sync_attempt INTEGER,
      thumbnail_path TEXT,
      FOREIGN KEY (flight_session_id) REFERENCES flight_session(id) ON DELETE CASCADE
    )''',

    // 5. INDEXES
    'CREATE INDEX idx_telemetry_timestamp ON telemetry_points(timestamp)',
    'CREATE INDEX idx_telemetry_session_time ON telemetry_points(flight_session_id, timestamp)',
    'CREATE INDEX idx_telemetry_location ON telemetry_points(lat, lng)',
    'CREATE INDEX idx_telemetry_quality ON telemetry_points(data_quality)',
    'CREATE INDEX idx_telemetry_sync ON telemetry_points(synced, flight_session_id)',
    'CREATE INDEX idx_telemetry_pending_sync ON telemetry_points(synced, timestamp) WHERE synced = 0',
    'CREATE INDEX idx_session_sync_status ON flight_session(sync_status)',
    'CREATE INDEX idx_photos_sync ON photos(synced, flight_session_id)',
    'CREATE INDEX idx_evaluation_session ON evaluation(flight_session_id)',

    // 6. TRIGGER - increment total_points
    '''CREATE TRIGGER increment_total_points
    AFTER INSERT ON telemetry_points
    BEGIN
      UPDATE flight_session 
      SET total_points = total_points + 1
      WHERE id = NEW.flight_session_id;
    END''',
  ];
}
