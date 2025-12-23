import 'log_event.dart';
import 'logger.dart';

/// Global instance to use across all packages
late MultiLogger log;

/// Provides an unfied way to log into multiple sources
final class MultiLogger extends Logger {
  MultiLogger({
    super.beforeLog,
    super.afterLog,
    this.loggers = const [],
  });

  /// List of loggers events to be logged into
  final List<Logger> loggers;

  Future<void> logEvent(LogEvent event) async {
    loggers.forEach((logger) async {
      await logger.processEvent(event);
    });
  }
}

  // late ConsoleLogger _messageLogger;
  // late ConsoleLogger _errorLogger;
  // late ConsoleLogger _noEmojiLogger;

  // void _init() {
  //   final excludedPathsFull = [
  //     ...stackExcludePaths,
  //     ...stackExcludePaths.map((path) => 'package:$path'),
  //   ];

  //   final defaultOutput = DefaultLogOutput(
  //     onLogEvent: (event) => _eventsController.add(event),
  //   );
  //   final defaultFilter = DefaultLogFilter();

  //   _messageLogger = ConsoleLogger(
  //     printer: _defaultPrinter,
  //     filter: defaultFilter,
  //     output: defaultOutput,
  //     level: ConsoleLevel.all,
  //   );

  //   _errorLogger = ConsoleLogger(
  //     printer: PrettyPrinter(
  //       methodCount: 4,
  //       errorMethodCount: 8,
  //       excludePaths: excludedPathsFull,
  //     ),
  //     filter: defaultFilter,
  //     output: defaultOutput,
  //     level: ConsoleLevel.all,
  //   );

  //   _noEmojiLogger = ConsoleLogger(
  //     printer: PrettyPrinter(
  //       methodCount: 4,
  //       errorMethodCount: 8,
  //       printEmojis: false,
  //       excludePaths: excludedPathsFull,
  //     ),
  //     filter: defaultFilter,
  //     output: defaultOutput,
  //     level: ConsoleLevel.all,
  //   );
  // }

  // Future<void> _logMessageToSentry(
  //   dynamic message,
  //   [SentryLevel level = SentryLevel.info,]
  // ) async {
  //   if (dispatchToSentry) {
  //     await Sentry.captureMessage(message, level: level);
  //   }
  // }

  // Future<void> _logError(
  //   LogLevel level,
  //   dynamic message, {
  //   DateTime? time,
  //   Object? error,
  //   StackTrace? stackTrace,
  // }) async {
  //   if (this.level <= level) {
  //     final consoleLevel = level.toConsoleLevel();
  //     final sentryLevel = level.toSentryLevel();

  //     final exception = (message is Exception) ? message : error;

  //     _errorLogger.log(
  //       consoleLevel,
  //       message,
  //       time: time,
  //       error: error,
  //       stackTrace: _toTrace(stackTrace),
  //     );

  //     if (exception is Exception) {
  //       await _logExceptionToSentry(exception, stackTrace);
  //     } else if (sentryLevel != null) {
  //       await _logMessageToSentry(message, sentryLevel);
  //     }
  //   }
  // }

  // Future<void> _logExceptionToSentry(
  //   dynamic exception,
  //   [StackTrace? stackTrace,]
  // ) async {
  //   if (dispatchToSentry) {
  //     await Sentry.captureException(
  //       exception,
  //       stackTrace: stackTrace,
  //     );
  //   }
  // }

  // void _logDioException(DioException exception) {
  //   String statusError = (exception.response?.statusCode != null)
  //     ? '[${exception.response?.statusCode}] ${exception.response?.statusMessage}' : '';
  //   String summary = '${exception.requestOptions.method} ${exception.requestOptions.uri}';

  //   List<String?> messages = [
  //     '⛔ $summary',
  //   ];

  //   if (level <= LogLevel.debug) {
  //     messages.add(
  //       _apiCallDetails(
  //         exception.requestOptions,
  //         exception.response,
  //       ),
  //     );
  //   }

  //   _noEmojiLogger.e(
  //     messages.nonNulls.join('\n'),
  //     stackTrace: _toTrace(exception.stackTrace),
  //     error: exception.error ?? statusError,
  //   );
  // }

  // void _logRichException(
  //   RichException exception,
  //   StackTrace? stackTrace,
  // ) {
  //   List<String?> messages = [
  //     '⛔ ${exception.message}',
  //   ];

  //   if (level <= LogLevel.debug) {
  //     messages.addAll([
  //       _extraDetails(exception.extra),
  //       if (exception is RichApiException)
  //         _apiCallDetails(
  //           exception.response.requestOptions,
  //           exception.response,
  //           includeUrl: true,
  //         ),
  //     ]);
  //   }

  //   if (exception.stackTrace != null) {
  //     stackTrace = _toTrace(exception.stackTrace);
  //   }

  //   _noEmojiLogger.e(
  //     messages.nonNulls.join('\n'),
  //     stackTrace: stackTrace,
  //     error: exception.error,
  //   );
  // }

  // String? _apiCallDetails(
  //   RequestOptions requestOptions,
  //   Response? response, {
  //   bool includeUrl = false,
  // }) {
  //   String details = '';

  //   if (includeUrl) {
  //     details += '$_headerColor  • url:\n';
  //     details += '$_detailColor    ${requestOptions.method} ${requestOptions.uri}\n';
  //   }

  //   if (requestOptions.queryParameters.isNotEmpty) {
  //     details += '$_headerColor  → params:\n';
  //     requestOptions.queryParameters.forEach((key, value) {
  //       details += '$_detailColor    $key: $value\n';
  //     });
  //   }

  //   if (requestOptions.data != null) {
  //     String requestData = '${requestOptions.data}';
  //     if (requestData.length > _maxDataLength) {
  //       requestData = '${requestData.substring(0, _maxDataLength)}...';
  //     }

  //     details += '$_headerColor  → data:\n';
  //     details += '$_detailColor    $requestData\n';
  //   }

  //   if (requestOptions.headers.isNotEmpty) {
  //     details += '$_headerColor  → headers:\n';
  //     requestOptions.headers.forEach((key, value) {
  //       details += '$_detailColor    $key: $value\n';
  //     });
  //   }

  //   if (response != null) {
  //     String responseData = '${response.data}';
  //     if (responseData.length > _maxDataLength) {
  //       responseData = '${responseData.substring(0, _maxDataLength)}...';
  //     }

  //     details += '$_headerColor  ← data:\n';
  //     details += '$_detailColor    $responseData\n';

  //     if (response.headers.map.isNotEmpty) {
  //       details += '$_headerColor  ← headers:\n';
  //       response.headers.map.forEach((key, value) {
  //         details += '$_detailColor    $key: ${value.join(', ')}\n';
  //       });
  //     }
  //   }

  //   return details.isNotEmpty ? details.trimRight() : null;
  // }

  // String? _extraDetails(Map<String, dynamic>? extra) {
  //   String details = '';

  //   if (extra != null) {
  //     details += '$_headerColor  • extra:\n';

  //     for (final key in extra.keys) {
  //       details += '$_detailColor    $key: ${extra[key]}\n';
  //     }
  //   }

  //   return details.isNotEmpty ? details.trimRight() : null;
  // }

  // StackTrace? _toTrace(StackTrace? stackTrace) {
  //   if ((stackTrace != null) && (stackTrace.runtimeType.toString() == '_StackTrace')) {
  //     return Trace.from(stackTrace);
  //   } else {
  //     return stackTrace;
  //   }
  // }

  // AnsiColor? get _headerColor => const AnsiColor.fg(221);
  // AnsiColor? get _detailColor => AnsiColor.fg(AnsiColor.grey(0.5));
