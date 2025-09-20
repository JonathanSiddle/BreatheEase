import 'dart:convert';

import 'package:logger/logger.dart';

abstract class LoggingFactory {
  Logger getLogger(String className);
}

class DefaultLoggingFactory extends LoggingFactory {
  @override
  Logger getLogger(String className) {
    return Logger(printer: SimplePrintWithClassName(className: className));
  }
}

// class SimplePrintWithClassName extends LogPrinter {
//   final String className;

//   SimplePrintWithClassName(this.className);

//   @override
//   List<String> log(LogEvent) {
//     var color = PrettyPrinter.levelColors[level];
//     var emoji = PrettyPrinter.levelEmojis[level];
//     println(color('$emoji $className - $message'));
//     return [];
//   }
// import 'dart:convert';

/// Outputs simple log messages:
/// ```
/// [E] Log message  ERROR: Error info
/// ```
class SimplePrintWithClassName extends LogPrinter {
  SimplePrintWithClassName(
      {required this.className, this.printTime = false, this.colors = true});

  static final levelPrefixes = {
    Level.trace: '[T]',
    Level.debug: '[D]',
    Level.info: '[I]',
    Level.warning: '[W]',
    Level.error: '[E]',
    Level.fatal: '[FATAL]',
  };

  static final levelColors = {
    Level.trace: AnsiColor.fg(AnsiColor.grey(0.5)),
    Level.debug: const AnsiColor.none(),
    Level.info: const AnsiColor.fg(12),
    Level.warning: const AnsiColor.fg(208),
    Level.error: const AnsiColor.fg(196),
    Level.fatal: const AnsiColor.fg(199),
  };

  final String className;
  final bool printTime;
  final bool colors;

  @override
  List<String> log(LogEvent event) {
    final messageStr = _stringifyMessage(event.message);
    final errorStr = event.error != null ? '  ERROR: ${event.error}' : '';
    final timeStr = printTime ? 'TIME: ${event.time.toIso8601String()}' : '';
    return [
      '${_labelFor(event.level)} $timeStr [$className]  $messageStr$errorStr'
    ];
  }

  String _labelFor(Level level) {
    final prefix = levelPrefixes[level]!;
    final color = levelColors[level]!;

    return colors ? color(prefix) : prefix;
  }

  String _stringifyMessage(dynamic message) {
    // ignore: avoid_dynamic_calls
    final finalMessage = message is Function ? message() : message;
    if (finalMessage is Map || finalMessage is Iterable) {
      const encoder = JsonEncoder.withIndent(null);
      return encoder.convert(finalMessage);
    } else {
      return finalMessage.toString();
    }
  }
}
