import 'log_event.dart';
import 'logger.dart';

/// Global instance to use across all packages
late MultiLogger logger;

/// Provides an unfied way to log into multiple sources
final class MultiLogger extends Logger {
  MultiLogger({
    super.beforeLog,
    this.loggers = const [],
  });

  /// List of loggers events to be logged into
  final List<Logger> loggers;

  @override
  Future<void> logEvent(LogEvent event) async {
    for (final logger in loggers) {
      await logger.processEvent(event);
    }
  }
}
