import 'log_level.dart';
import 'logger.dart';

/// Global instance to use across all packages
late MultiLogger log;

/// Provides an unfied way to log into multiple sources
final class MultiLogger extends Logger {
  MultiLogger({
    this.loggers = const [],
  });

  /// List of loggers events to be logged into
  final List<Logger> loggers;

  Future<void> log(
    LogLevel level,
    dynamic message,{
    DateTime? dateTime,
    Object? error,
    StackTrace? stackTrace,
    Map<Object, dynamic>? extra,
  }) async {
    loggers.forEach((logger) {
      logger.log(
        level,
        message,
        dateTime: dateTime,
        error: error,
        stackTrace: stackTrace,
        extra: extra,
      );
    });
  }
}