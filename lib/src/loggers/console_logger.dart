import 'dart:developer' as developer;
import 'dart:io' show Platform;

import 'package:logger/logger.dart' as console;
import 'package:stack_trace/stack_trace.dart';

import '../log_event.dart';
import '../logger.dart';

class ConsoleLogger extends Logger {
  ConsoleLogger({
    super.level,
    super.beforeLog,
    super.afterLog,
    this.excludePaths = const [],
    this.logTimestamp = false,
  }) {
    _logFilter = _ConsoleLogFilter();
    _logOutput = _ConsoleLogOutput(
      logTimestamp: logTimestamp,
    );

    // We have to have two different console loggers and printers
    // since we want to have boxing for all levels but only if
    // there is an error, and logger package doesn't provide this
    // functionality out of the box.
    _messageLogPrinter = _logPrinter(noBoxing: true);
    _messageLogger = _logger(logPrinter: _messageLogPrinter);

    _errorLogPrinter = _logPrinter(noBoxing: false);
    _errorLogger = _logger(logPrinter: _errorLogPrinter);
  }

  final List<String> excludePaths;
  final bool logTimestamp;

  @override
  Future<dynamic> logEvent(LogEvent event) async {
    final consoleLevel = console.Level.values.firstWhere(
      (value) => value.name == event.level.name,
      orElse: () => .debug,
    );

    // Check if it's a default StackTrace object then convert it
    // to more user friendly and readable [Trace]
    var stackTrace = event.stackTrace ?? StackTrace.current;
    stackTrace = stackTrace.runtimeType.toString() == '_StackTrace'
      ? Trace.from(stackTrace)
      : stackTrace;

    final logger = event.error != null
      ? _errorLogger
      : _messageLogger;

    final logPrinter = event.error != null
      ? _errorLogPrinter
      : _messageLogPrinter;

    logger.log(
      consoleLevel,
      event.message,
      time: event.dateTime,
      error: event.error,
      stackTrace: stackTrace,
    );

    // Unfortunately there is no other way to get output after
    // actual logging to console. We cannot use a listener here
    // cause we need the output immediatelly.
    return logPrinter.log(
      console.LogEvent(
        consoleLevel,
        event.message,
        time: event.dateTime,
        error: event.error,
        stackTrace: stackTrace,
      ),
    );
  }

  late console.LogFilter _logFilter;
  late console.LogOutput _logOutput;

  late console.PrettyPrinter _messageLogPrinter;
  late console.Logger _messageLogger;

  late console.PrettyPrinter _errorLogPrinter;
  late console.Logger _errorLogger;

  console.Logger _logger({
    required console.PrettyPrinter logPrinter,
  }) {
    return console.Logger(
      printer: logPrinter,
      filter: _logFilter,
      output: _logOutput,
      level: console.Level.all,
    );
  }

  console.PrettyPrinter _logPrinter({
    bool noBoxing = true,
  }) {
    return console.PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      noBoxingByDefault: noBoxing,
      printEmojis: false,
      dateTimeFormat: logTimestamp
        ? console.DateTimeFormat.onlyTimeAndSinceStart
        : console.DateTimeFormat.none,
      excludePaths: [
        ...excludePaths,
        ...excludePaths.map((path) => 'package:$path')
      ],
    );
  }
}

class _ConsoleLogFilter extends console.LogFilter {
  @override
  bool shouldLog(console.LogEvent event) {
    return event.level.value >= level!.value;
  }
}

class _ConsoleLogOutput extends console.LogOutput {
  _ConsoleLogOutput({
    this.logTimestamp = false,
  });

  final bool logTimestamp;

  @override
  void output(console.OutputEvent event) {
    final levelColor = console.PrettyPrinter.defaultLevelColors[event.level];
    final levelName = _levelName(event);

    final usePrintForOutput = !Platform.isAndroid && !Platform.isIOS;
    final levelPadding = ''.padLeft(usePrintForOutput ? levelName.length + 3 : 0, ' ');
    final lines = event.lines.indexed.map((value) {
      return '${value.$1 > 0 ? levelPadding : ''}${value.$2}';
    });

    final buffer = StringBuffer();
    lines.forEach(buffer.writeln);

    final output = '$levelColor${buffer.toString()}';

    if (!usePrintForOutput) {
      developer.log(output, name: levelName);
    } else {
      // ignore: avoid_print
      print('$levelColor[${_levelName(event)}] $output');
    }
  }

  String _levelName(console.OutputEvent event) {
    return switch (event.level) {
      .trace => 'T',
      .debug => 'D',
      .info => 'I',
      .warning => 'W',
      .error => 'E',
      .fatal => 'F',
      _ => '•',
    };
  }
}
