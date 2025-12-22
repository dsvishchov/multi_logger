import 'package:multi_logger/multi_logger.dart';

Future<void> main() async {
  log = MultiLogger(
    loggers: [
      ConsoleLogger(
        level: LogLevel.trace,
        logTimestamp: false,
        onLog: (event) {
          // Here we can post-process log event after log has been
          // actually printed to the console and we have an output
        }
      ),
      SentryLogger(
        level: LogLevel.error,
      ),
    ]
  );

  final exception = new Exception('Test exception');

  log.trace(exception);
}