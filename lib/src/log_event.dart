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

  Object? output;
}