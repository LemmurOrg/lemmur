import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'app_config.dart';
import 'stores/accounts_store.dart';
import 'stores/config_store.dart';

Future<void> mainCommon(AppConfig appConfig) async {
  WidgetsFlutterBinding.ensureInitialized();

  _setupLogger(appConfig);

  final configStore = await ConfigStore.load();
  final accountsStore = await AccountsStore.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: configStore),
        ChangeNotifierProvider.value(value: accountsStore),
      ],
      child: const MyApp(),
    ),
  );
}

void _setupLogger(AppConfig appConfig) {
  Logger.root.level = Level.ALL;

  Logger.root.onRecord.listen((logEvent) {
    // ignore: avoid_print
    print(logEvent);
    // TODO: add to global log registery
  });

  final flutterErrorLogger = Logger('FlutterError');

  FlutterError.onError = (details) {
    if (appConfig.debugMode) {
      FlutterError.dumpErrorToConsole(details);
    } else {
      flutterErrorLogger.warning(
        details.summary.name,
        details.exception,
        details.stack,
      );
    }
  };
}
