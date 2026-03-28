import 'dart:developer' as developer;
import 'dart:io' show stderr;

import 'package:logger/logger.dart' as console;
import 'package:stack_trace/stack_trace.dart';
import 'package:universal_platform/universal_platform.dart';

import '../log_event.dart';
import '../logger.dart';
import '../utils/name_casing.dart';

enum ConsoleWriter {
  print,
  stderr,
  log,
}

class ConsoleLogger extends Logger {
  ConsoleLogger({
    super.level,
    super.beforeLog,
    this.name,
    this.excludePaths = const [],
    this.logTimestamp = false,
    this.logErrorType = true,
    this.capitalizeExtraKeys = true,
    this.colorize = true,
    ConsoleWriter? writer,
  }) {
    _logFilter = _ConsoleLogFilter();
    _logOutput = _ConsoleLogOutput(
      name: name,
      logTimestamp: logTimestamp,
      colorize: colorize,
      writer: writer ??
        ((UniversalPlatform.isAndroid || UniversalPlatform.isIOS) ? .log : .print),
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

  final String? name;
  final List<String> excludePaths;
  final bool logTimestamp;
  final bool logErrorType;
  final bool capitalizeExtraKeys;
  final bool colorize;

  @override
  Future<dynamic> logEvent(LogEvent event) async {
    bool hasError = event.error != null;
    bool hasMessage = event.message != null;

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

    final error = hasError && logErrorType
      ? '[${event.error.runtimeType}]\n${event.error}'
      : event.error;

    final message = hasError && hasMessage && ('$error'.contains('${event.message}'))
      ? ''
      : event.message;

    final messageWithExtra = StringBuffer(message ?? '');
    if ((event.extra != null) && event.extra!.isNotEmpty) {
      _logExtra(event.extra!, messageWithExtra);
    }

    final logger = event.error != null
      ? _errorLogger
      : _messageLogger;

    final logPrinter = event.error != null
      ? _errorLogPrinter
      : _messageLogPrinter;

    logger.log(
      consoleLevel,
      messageWithExtra.toString().trim(),
      time: event.dateTime,
      error: error,
      stackTrace: stackTrace,
    );

    // Unfortunately there is no other way to get output after
    // actual logging to console. We cannot use a listener here
    // cause we need the output immediatelly.
    return logPrinter.log(
      console.LogEvent(
        consoleLevel,
        messageWithExtra.toString().trim(),
        time: event.dateTime,
        error: error,
        stackTrace: stackTrace,
      ),
    ).join('\n');
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
      colors: colorize,
      dateTimeFormat: logTimestamp
        ? console.DateTimeFormat.onlyTimeAndSinceStart
        : console.DateTimeFormat.none,
      excludePaths: excludePaths,
    );
  }

  void _logExtra(
    Map<Object, dynamic> extra,
    StringBuffer buffer,
  ) {
    final headerColor = colorize ? '${const console.AnsiColor.fg(221)}' : '';
    final detailColor = colorize ? '${console.AnsiColor.fg(console.AnsiColor.grey(0.5))}' : '';

    buffer.writeln();
    extra.forEach((key, value) {
      if (capitalizeExtraKeys) {
        key = key.toString().toHumanReadable();
      }
      buffer.writeln('$headerColor• $key:');

      if (value is Map) {
        value.forEach((key, value) {
          buffer.writeln('  $detailColor$key: $value');
        });
      } else {
        for (final (line) in '$value'.trim().split('\n')) {
          buffer.writeln('  $detailColor$line');
        }
      }
    });
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
    this.name,
    required this.writer,
    required this.logTimestamp,
    required this.colorize,
  });

  final String? name;
  final ConsoleWriter writer;
  final bool logTimestamp;
  final bool colorize;

  @override
  void output(console.OutputEvent event) {
    final levelColor = colorize ? '${console.PrettyPrinter.defaultLevelColors[event.level]}' : '';
    final levelName = _levelName(event);

    final levelPadding = ''.padLeft(writer != .log ? levelName.length + 3 : 0, ' ');
    final lines = event.lines.indexed.map((value) {
      return '${value.$1 > 0 ? levelPadding : ''}${value.$2}';
    });

    final buffer = StringBuffer(name != null ? '[$name] ' : '');
    lines.forEach(buffer.writeln);

    final output = writer == .log
      ? '$levelColor$buffer'
      : '$levelColor[$levelName] $buffer';

    switch (writer) {
      case .print:
        // ignore: avoid_print
        print(output);
        break;

      case .log:
        developer.log(output, name: levelName);
        break;

      case .stderr:
        stderr.write(output);
        break;
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
