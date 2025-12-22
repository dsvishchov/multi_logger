import 'dart:async';

import 'log_level.dart';

abstract class Logger {
  const Logger();

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

  /// Log at specified level, should be implemented by subclasses
  Future<void> log(
    LogLevel level,
    dynamic message, {
    DateTime? dateTime,
    Object? error,
    StackTrace? stackTrace,
    Map<Object, dynamic>? extra,
  });
}