import 'package:logging/logging.dart';
import 'package:mobx/mobx.dart';

part 'log_console_store.g.dart';

class LogConsoleStore = _LogConsoleStore with _$LogConsoleStore;

abstract class _LogConsoleStore with Store {
  // TODO: implement as an ObservableDeque
  final logs = ObservableList<LogRecord>();
  static const _bufferSize = 200;

  @action
  void addLog(LogRecord logRecord) {
    if (logs.length == _bufferSize) {
      logs.removeAt(0);
    }

    logs.add(logRecord);
  }

  List<String> stringified() {
    return logs.map(
      (log) {
        var str = '${log.time} $log';

        if (log.stackTrace != null) str += '\n${log.stackTrace}';

        return str;
      },
    ).toList();
  }
}
