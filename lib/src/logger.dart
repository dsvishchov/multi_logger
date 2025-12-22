import 'dart:async';

import 'log_event.dart';
import 'log_level.dart';

abstract class Logger {
  const Logger({
    this.level = LogLevel.all,
    this.beforeLog,
    this.afterLog,
  });

  /// Log level above which (including) events are dispatched
  final LogLevel level;

  /// Callback to be executed before every log,
  /// allows to modify [LogEvent] before actually logging it
  final BeforeLogCallback? beforeLog;

  /// Callback to be executed after every log,
  /// allows to get the actual output of the logging
  final AfterLogCallback? afterLog;

  /// Log at level [LogLevel.trace]
  Future<void> trace(
    dynamic message, {
    DateTime? dateTime,
    Object? error,
    StackTrace? stackTrace,
    Map<Object, dynamic>? extra,
  }) async {
    await log(
      LogLevel.trace,
      message,
      dateTime: dateTime,
      error: error,
      stackTrace: stackTrace,
      extra: extra,
    );
  }

  /// Log at level [LogLevel.debug]
  Future<void> debug(
    dynamic message, {
    DateTime? dateTime,
    Object? error,
    StackTrace? stackTrace,
    Map<Object, dynamic>? extra,
  }) async {
    await log(
      LogLevel.debug,
      message,
      dateTime: dateTime,
      error: error,
      stackTrace: stackTrace,
      extra: extra,
    );
  }

  /// Log at level [LogLevel.info]
  Future<void> info(
    dynamic message, {
    DateTime? dateTime,
    Object? error,
    StackTrace? stackTrace,
    Map<Object, dynamic>? extra,
  }) async {
    await log(
      LogLevel.info,
      message,
      dateTime: dateTime,
      error: error,
      stackTrace: stackTrace,
      extra: extra,
    );
  }

  /// Log at level [LogLevel.warning]
  Future<void> warning(
    dynamic message, {
    DateTime? dateTime,
    Object? error,
    StackTrace? stackTrace,
    Map<Object, dynamic>? extra,
  }) async {
    await log(
      LogLevel.warning,
      message,
      dateTime: dateTime,
      error: error,
      stackTrace: stackTrace,
      extra: extra,
    );
  }

  /// Log at level [LogLevel.error].
  Future<void> error(
    dynamic message, {
    DateTime? dateTime,
    Object? error,
    StackTrace? stackTrace,
    Map<Object, dynamic>? extra,
  }) async {
    await log(
      LogLevel.error,
      message,
      dateTime: dateTime,
      error: error,
      stackTrace: stackTrace,
      extra: extra,
    );
  }

  /// Log at level [LogLevel.fatal]
  Future<void> fatal(
    dynamic message, {
    DateTime? dateTime,
    Object? error,
    StackTrace? stackTrace,
    Map<Object, dynamic>? extra,
  }) async {
    await log(
      LogLevel.fatal,
      message,
      dateTime: dateTime,
      error: error,
      stackTrace: stackTrace,
      extra: extra,
    );
  }

  /// Log at specific level
  Future<void> log(
    LogLevel level,
    dynamic message, {
    DateTime? dateTime,
    Object? error,
    StackTrace? stackTrace,
    Map<Object, dynamic>? extra,
  }) {
    LogEvent? event = LogEvent(
      level: level,
      message: message,
      dateTime: dateTime,
      error: error,
      stackTrace: stackTrace,
      extra: extra,
    );

    return processEvent(event);
  }

  /// Process specific event through level checks and callbacks
  Future<void> processEvent(LogEvent event) async {
    if (event.level < level) return;

    LogEvent? modifiedEvent = event;

    if (beforeLog != null) {
      modifiedEvent = await beforeLog!(event);
      if (modifiedEvent == null) {
        return;
      }
    }

    final output = await logEvent(modifiedEvent);

    if (afterLog != null) {
      await afterLog!(modifiedEvent, output);
    }
  }

  /// Log specific event, should be implemented by subclasses
  /// and return optional output/result of logging
  Future<dynamic> logEvent(LogEvent event);
}

typedef BeforeLogCallback = FutureOr<LogEvent?> Function(
  LogEvent event,
);

typedef AfterLogCallback = FutureOr<void> Function(
  LogEvent event,
  dynamic output,
);