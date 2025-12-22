enum LogLevel {
  all(0),
  trace(10),
  debug(20),
  info(30),
  warning(40),
  error(50),
  fatal(60),
  off(100);

  final int value;
  const LogLevel(this.value);

  bool operator <=(LogLevel level) => value <= level.value;
  bool operator <(LogLevel level) => value < level.value;
  bool operator >=(LogLevel level) => value >= level.value;
  bool operator >(LogLevel level) => value > level.value;
}
