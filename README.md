[multi_logger] provides a unified way to log messages and events to multiple locations.

There are some loggers provided out of the box: `ConsoleLogger` and `SentryLogger`, but there
is also a flexible and easy-to-use interface to create your own loggers.

# How to use

## Install

To use [multi_logger], simply add it to your `pubspec.yaml` file:

```console
dart pub add multi_logger
```

## Initialize

``` dart
logger = MultiLogger(
  loggers: [
    ConsoleLogger(
      level: LogLevel.trace,
    ),
    SentryLogger(
      level: LogLevel.error,
    ),
  ]
);
```

It is also possible to use any logger separately. `MultiLogger` is just an another type of logger
implementing logging to multiple sources and sharing absolutely the same interface.

## Use

There are 5 levels and corresponding methods to use:  `trace`, `debug`, `info`,
`warning`, `error` and `fatal`. All of them use the same set of parameters:
- `message`: this might be anything, usually logger will use `toString()` to get a string representation
- `dateTime`: optional date/time associated with the log event, current date/time will be used if not provided
- `error`: optional error associated with the log event, usually logger will use `toString()` to get a string representation
- `stackTrace`: optional log event stack trace, current stack trace will be used if not provided
- `extra`: an arbitrary extra data associated with the log event

```dart
logger.info('This is an informational message');

try {
  throw ...;
} catch (error, stackTrace) {
  logger.error(
    'An error happened',
    error: error,
    stackTrace: stackTrace,
  );
}
```

If you want to filter log events or modify them it's possible to provide a `beforeLog` callback
and return a modified event or `null` to drop an event completely.

```dart
ConsoleLogger(
  beforeLog: (event) {
    // Drop all events with extra data
    return (event.extra != null) ? null : event;
  },
),
```

Also you can subscribe to log events and their respective outputs from each logger using
the provided `events` stream:

```dart
consoleLogger.events.listen((data) {
  final (event, output) = data;
  ...
}
```

## Built-in loggers

There are two built-in loggers provided:
- `ConsoleLogger`: logs messages to console with colorized output based on levels,
stack traces for errors and logging of extra associated with events
- `SentryLogger`: logs messages and errors to Sentry

Note: in order to use `SentryLogger` Sentry needs to be already initialized.

## Custom loggers

You can create you own logger by simply extending `Logger` class and implementing a single method:

```dart
class MyLogger extends Logger {
  MyLogger({super.level});

  @override
  Future<dynamic> logEvent(LogEvent event) async {
    // Your implementation goes here
  }
}
```

[multi_logger]: https://pub.dartlang.org/packages/multi_logger
