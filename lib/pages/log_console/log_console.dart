import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import '../../util/observer_consumers.dart';
import '../../widgets/bottom_safe.dart';
import 'log_console_store.dart';

class LogConsole extends StatelessWidget {
  const LogConsole({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ObserverBuilder<LogConsoleStore>(
          builder: (context, store) {
            final logStrings = store.stringified();

            return ListView.separated(
              padding: const EdgeInsets.all(8)
                  .copyWith(bottom: BottomSafe.fabPadding + 8),
              itemCount: store.logs.length,
              itemBuilder: (context, i) => SelectableText(
                logStrings[i],
                style: TextStyle(color: store.logs[i].level.color),
              ),
              separatorBuilder: (context, i) => const SizedBox(height: 6),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final data = context.read<LogConsoleStore>().stringified();

          await Clipboard.setData(ClipboardData(text: data.join('\n')));

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('all logs copied to the clipboard')),
            );
        },
        tooltip: 'Copy to clipboard',
        child: const Icon(Icons.copy),
      ),
    );
  }
}

extension on Level {
  Color get color {
    if (this == Level.FINEST) return Colors.lime[100]!;
    if (this == Level.FINER) return Colors.lime[300]!;
    if (this == Level.FINE) return Colors.lime;
    if (this == Level.CONFIG) return Colors.green;
    if (this == Level.INFO) return Colors.blue;
    if (this == Level.WARNING) return Colors.amber;
    if (this == Level.SEVERE) return Colors.orange;
    if (this == Level.SHOUT) return Colors.red;

    throw StateError('unreachable');
  }
}

class LogConsoleRoute extends MaterialPageRoute {
  LogConsoleRoute()
      : super(
          builder: (context) => const LogConsole(),
          fullscreenDialog: true,
        );
}