import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Propage les changements de thème aux descendants via [InheritedWidget].
///
/// Appeler [ThemeSync.watch] dans le `build` des widgets qui utilisent
/// [AppTheme] pour se reconstruire immédiatement au changement de mode.
class ThemeSync extends InheritedWidget {
  const ThemeSync({
    super.key,
    required this.isLight,
    required super.child,
  });

  final bool isLight;

  static bool watch(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ThemeSync>()?.isLight ??
      ThemeController.isLight;

  @override
  bool updateShouldNotify(ThemeSync oldWidget) => isLight != oldWidget.isLight;
}
