import 'package:sentry/sentry.dart';

import '../log_event.dart';
import '../logger.dart';

class SentryLogger extends Logger {
  SentryLogger({
    super.level,
    super.beforeLog,
  });

  @override
  Future<dynamic> logEvent(LogEvent event) async {
    final sentryLevel = SentryLevel.fromName(event.level.name);

    ScopeCallback scope = (scope) async {
      if ((event.extra != null) && event.extra!.isNotEmpty) {
        await scope.setContexts(
          'Extra',
          event.extra!.map((k, v) => MapEntry(k.toString(), v.toString())),
        );
      }
    };

    if (event.error != null) {
      await Sentry.captureException(
        event.error,
        stackTrace: event.stackTrace,
        withScope: scope,
      );
    } else {
      await Sentry.captureMessage(
        event.message.toString(),
        level: sentryLevel,
        withScope: scope,
      );
    }

    return event;
  }
}
