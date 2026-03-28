import 'package:flutter/material.dart';
import 'package:multi_logger/multi_logger.dart';

void main() async {
  initLogging();

 final exception = Exception('Test exception');
 logger.error(exception);

  runApp(const MyApp());
}

void initLogging() {
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
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('multi_logger example'),
        ),
      ),
    );
  }
}
