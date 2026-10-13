import 'package:flutter/material.dart';

extension ContextTheme on BuildContext {
  ThemeData get theme => Theme.of(this);

  ColorScheme get colors => theme.colorScheme;

  TextTheme get text => theme.textTheme;

  bool get isDark => theme.brightness == Brightness.dark;
}
