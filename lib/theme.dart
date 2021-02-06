import 'package:flutter/material.dart';

ThemeData _themeFactory({bool dark = false, bool amoled = false}) {
  assert(dark || !amoled, "Can't have amoled without dark mode");

  final theme = dark ? ThemeData.dark() : ThemeData.light();
  final maybeAmoledColor = amoled ? Colors.black : null;

  return theme.copyWith(
    scaffoldBackgroundColor: maybeAmoledColor,
    backgroundColor: maybeAmoledColor,
    canvasColor: maybeAmoledColor,
    cardColor: maybeAmoledColor,
    splashColor: maybeAmoledColor,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        primary: theme.accentColor,
        onPrimary: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        primary: theme.colorScheme.onSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: TextButton.styleFrom(
        primary: theme.colorScheme.onSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),
  );
}

final lightTheme = _themeFactory();
final darkTheme = _themeFactory(dark: true);
final amoledTheme = _themeFactory(dark: true, amoled: true);
