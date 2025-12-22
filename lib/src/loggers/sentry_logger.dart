import 'package:sentry/sentry.dart';

import '../log_event.dart';
import 'stream_logger.dart';

class SentryLogger extends StreamLogger {
  SentryLogger({
    required super.level,
    super.onLog,
  });

  Future<LogEvent> logEvent(LogEvent event) async {
    final sentryLevel = SentryLevel.fromName(event.level.name);

    return event;
  }
}
