import 'package:flutter/foundation.dart';

/// Centralized logging utility.
///
/// Replaces print() statements with leveled logging that can be
/// easily disabled in production and filtered during debugging.
class Logger {
  /// Log level for filtering messages
  static LogLevel _minLevel = LogLevel.debug;

  /// Sets minimum log level (messages below this won't be shown)
  static void setMinLevel(LogLevel level) {
    _minLevel = level;
  }

  /// Debug messages (verbose, technical details)
  static void debug(String message, [String? tag]) {
    _log(LogLevel.debug, message, tag);
  }

  /// Info messages (general information)
  static void info(String message, [String? tag]) {
    _log(LogLevel.info, message, tag);
  }

  /// Warning messages (potential issues)
  static void warning(String message, [String? tag]) {
    _log(LogLevel.warning, message, tag);
  }

  /// Error messages (actual problems)
  static void error(String message, [Object? error, StackTrace? stackTrace, String? tag]) {
    _log(LogLevel.error, message, tag, error, stackTrace);
  }

  /// Internal logging implementation
  static void _log(
    LogLevel level,
    String message,
    String? tag, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    // Skip if below minimum level
    if (level.index < _minLevel.index) return;

    // Only log in debug mode
    if (!kDebugMode) return;

    final timestamp = DateTime.now().toString().substring(11, 23);
    final levelStr = level.name.toUpperCase().padRight(7);
    final tagStr = tag != null ? '[$tag] ' : '';

    // Format: [HH:MM:SS.mmm] LEVEL [TAG] message
    final output = '[$timestamp] $levelStr $tagStr$message';

    // Use debugPrint to avoid truncation in Flutter
    debugPrint(output);

    if (error != null) {
      debugPrint('  └─ Error: $error');
    }

    if (stackTrace != null) {
      debugPrint('  └─ Stack: ${stackTrace.toString().split('\n').take(3).join('\n    ')}');
    }
  }
}

/// Log level enumeration
enum LogLevel {
  debug,
  info,
  warning,
  error,
}