import 'dart:async';

import 'package:sentry/sentry.dart';

import '../log_event.dart';
import '../log_level.dart';
import '../logger.dart';
import '../utils/name_transform_utils.dart';

class SentryLogger extends Logger {
  SentryLogger({
    super.level,
    super.beforeLog,
    this.useBreadcrumbs = true,
    this.capitalizeExtraKeys = true,
  });

  final bool useBreadcrumbs;
  final bool capitalizeExtraKeys;

  @override
  Future<dynamic> logEvent(LogEvent event) async {
    final isException = (event.level >= LogLevel.error) && (event.error != null);

    final Map<String, dynamic> extra = {
      if (isException) ...{
        'Message': ?event.message,
      },
      if ((event.extra != null) && event.extra!.isNotEmpty) ...{
        ...event.extra!.map((k, v) => MapEntry(
          capitalizeExtraKeys ? camelToCapitalized(k.toString()) : k.toString(),
          v.toString()
        )),
      }
    };

    FutureOr<void> scope(Scope scope) async {
      if (extra.isNotEmpty) {
        await scope.setContexts('Extra', extra);
      }

      // TODO: implement fingerprinting for log events
      // scope.fingerprint = [
      //   event.message.toString(),
      // ];
    }

    if (isException) {
      await Sentry.captureException(
        event.error,
        stackTrace: event.stackTrace,
        withScope: scope,
      );
    } else {
      final sentryLevel = SentryLevel.fromName(event.level.name);
      final message = ((event.error != null) ? '${event.error.toString()}\n' : '')
        + ((event.message != null) ? event.message.toString() : '');

      if (useBreadcrumbs) {
        await Sentry.addBreadcrumb(
          Breadcrumb(
            message: message,
            timestamp: event.dateTime,
            category: 'Log',
            data: extra,
            level: sentryLevel,
          ),
        );
      } else {
        await Sentry.captureMessage(
          message,
          level: sentryLevel,
          withScope: scope,
        );
      }
    }

    return event;
  }
}
