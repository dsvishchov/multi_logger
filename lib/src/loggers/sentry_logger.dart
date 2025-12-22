import 'package:sentry/sentry.dart';

import '../log_event.dart';
import '../logger.dart';

class SentryLogger extends Logger {
  SentryLogger({
    super.level,
    super.beforeLog,
    super.afterLog,
  });

  @override
  Future<dynamic> logEvent(LogEvent event) async {
    // final sentryLevel = SentryLevel.fromName(event.level.name);

    return event;
  }
}
