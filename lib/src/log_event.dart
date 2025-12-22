import 'log_level.dart';

class LogEvent {
  LogEvent({
    required this.level,
    required this.message,
    this.dateTime,
    this.error,
    this.stackTrace,
    this.extra,
  });

  final LogLevel level;
  final dynamic message;
  final DateTime? dateTime;
  final Object? error;
  final StackTrace? stackTrace;
  final Map<Object, dynamic>? extra;

  LogEvent copyWith({
    LogLevel? level,
    dynamic message = _Undefined,
    Object? dateTime = _Undefined,
    Object? error = _Undefined,
    Object? stackTrace = _Undefined,
    Object? extra = _Undefined,
  }) {
    return LogEvent(
      level: level ?? this.level,
      message: message == _Undefined ? this.message : message,
      dateTime: dateTime is DateTime? ? dateTime : this.dateTime,
      error: error == _Undefined ? this.error : error,
      stackTrace: stackTrace is StackTrace? ? stackTrace : this.stackTrace,
      extra: extra is Map<Object, dynamic>? ? extra : this.extra,
    );
  }
}

class _Undefined {}
