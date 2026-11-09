import 'package:logger/logger.dart';

abstract class AppLogger {
  void w(dynamic message);
  void e(dynamic message);
}

class AppLoggerManager implements AppLogger {
  AppLoggerManager({required this.loggers});

  final List<AppLogger> loggers;

  @override
  void e(dynamic message) {
    for (final l in loggers) {
      l.e(message);
    }
  }

  @override
  void w(dynamic message) {
    for (final l in loggers) {
      l.w(message);
    }
  }
}

class TerminalLogger implements AppLogger {
  final logger = Logger(
    printer: PrefixPrinter(
      PrettyPrinter(
        colors: true,
        errorMethodCount: 3,
        methodCount: 3,
      ),
    ),
  );

  @override
  void e(message) => logger.e(message);

  @override
  void w(message) => logger.w(message);
}
