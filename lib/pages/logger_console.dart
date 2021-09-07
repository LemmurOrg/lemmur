import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class LoggerConsole extends StatelessWidget {
  // TODO: make reactive by moving to a mobx store once mobx is merged
  static final _recentLogs = ListQueue<LogRecord>();
  static const _bufferSize = 200;

  const LoggerConsole({Key? key}) : super(key: key);

  static void addRecord(LogRecord logRecord) {
    if (_recentLogs.length == _bufferSize) {
      _recentLogs.removeFirst();
    }

    _recentLogs.add(logRecord);
  }

  // TODO: render logs
  @override
  Widget build(BuildContext context) => Container();
}
