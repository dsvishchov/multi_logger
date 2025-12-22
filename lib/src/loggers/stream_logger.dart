import 'dart:async';

import '../log_event.dart';
import '../log_level.dart';
import '../logger.dart';

class StreamLogger extends Logger {
  StreamLogger({
    required this.level,
    void Function(LogEvent event)? onLog,
  }) {
    if (onLog != null) {
      _eventsController.stream.listen(onLog);
    }
  }

  /// Subscribe to this stream to get notified about log events
  Stream<LogEvent> get events => _eventsController.stream;
  final _eventsController = StreamController<LogEvent>.broadcast();

  /// Log level above which (including) events are dispatched
  final LogLevel level;

  /// Log at specified level
  Future<void> log(
    LogLevel level,
    dynamic message, {
    DateTime? dateTime,
    Object? error,
    StackTrace? stackTrace,
    Map<Object, dynamic>? extra,
  }) async {
    if (level < this.level) return;

    var event = LogEvent(
      level: level,
      message: message,
      dateTime: dateTime,
      error: error,
      stackTrace: stackTrace,
      extra: extra,
    );

    event = await logEvent(event);

    _eventsController.add(event);
  }

  /// Might be overriden by subclasses to log events in a
  /// specific way but keep events stream functionality
  Future<LogEvent> logEvent(LogEvent event) async => event;
}