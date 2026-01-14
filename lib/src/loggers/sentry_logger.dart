import 'dart:async';

import 'package:sentry/sentry.dart';

import '../log_event.dart';
import '../log_level.dart';
import '../logger.dart';

class SentryLogger extends Logger {
  SentryLogger({
    super.level,
    super.beforeLog,
    this.useBreadcrumbs = true,
  });

  final bool useBreadcrumbs;

  @override
  Future<dynamic> logEvent(LogEvent event) async {
    final extra = ((event.extra != null) && event.extra!.isNotEmpty)
      ? event.extra!.map((k, v) => MapEntry(k.toString(), v.toString()))
      : null;

    FutureOr<void> scope(Scope scope) async {
      if (extra != null) {
        await scope.setContexts('Extra', extra);
      }

      // TODO: implement fingerprinting for log events
      // scope.fingerprint = [
      //   event.message.toString(),
      // ];
    }

    if ((event.level >= LogLevel.error) && (event.error != null)) {
      await Sentry.captureException(
        event.error,
        stackTrace: event.stackTrace,
        withScope: scope,
      );
    } else {
      final sentryLevel = SentryLevel.fromName(event.level.name);

      if (useBreadcrumbs) {
        await Sentry.addBreadcrumb(
          Breadcrumb(
            message: event.message.toString(),
            timestamp: event.dateTime,
            category: event.error?.runtimeType.toString(),
            data: extra,
            level: sentryLevel,
          ),
        );
      } else {
        await Sentry.captureMessage(
          event.message.toString(),
          level: sentryLevel,
          withScope: scope,
        );
      }
    }

    return event;
  }
}
