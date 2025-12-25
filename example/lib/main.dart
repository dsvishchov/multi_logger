import 'package:multi_logger/multi_logger.dart';

Future<void> main() async {
  logger = MultiLogger(
    loggers: [
      ConsoleLogger(
        level: LogLevel.trace,
        logTimestamp: false,
        beforeLog: (event) {
          return event;
        },
      ),
      SentryLogger(
        level: LogLevel.error,
      ),
    ]
  );

  final exception = new Exception('Test exception');

  logger.trace(exception);
}