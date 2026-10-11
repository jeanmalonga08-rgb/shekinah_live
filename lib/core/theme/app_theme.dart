import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Palette logo Shekinah — layout inspiré de rst_mobile.
///
/// Les getters adaptatifs suivent [ThemeController] (clair / sombre).
/// Le mode sombre conserve la palette actuelle.
class AppTheme {
  /// Or de référence (mode sombre). En clair, [accentGold]/[goldLight] suivent [royalBlue].
  static const Color _darkAccentGold = Color(0xFFD4A017);
  static const Color _darkGoldLight = Color(0xFFF0C75E);
  /// Or plus lumineux sur fond sombre (meilleur contraste que accentGold).
  static const Color _darkAccentOnSurface = Color(0xFFF5C842);
  static const Color _darkGoldHighlight = Color(0xFFF0D78C);
  static const Color royalBlue = Color(0xFF1B4F9C);
  static const Color crossRed = Color(0xFFC62828);
  static const Color live = Color(0xFFFF1744);
  static const Color errorRed = Color(0xFFE53935);
  static const Color successGreen = Color(0xFF2E7D4F);

  static const double cardRadius = 16;
  static const double buttonRadius = 12;

  // —— Sombre (actuel) ——
  static const Color _darkPrimaryDark = Color(0xFF071428);
  static const Color _darkBackground = Color(0xFF0A1628);
  static const Color _darkSurface = Color(0xFF12263F);
  static const Color _darkSurfaceElevated = Color(0xFF1A3352);
  static const Color _darkWhite = Color(0xFFF8FAFC);
  static const Color _darkSoftWhite = Color(0xFFE8EEF7);
  static const Color _darkGrey = Color(0xFF94A3B8);
  static const Color _darkMuted = Color(0xFF64748B);

  static const LinearGradient _darkHeaderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF06101F),
      Color(0xFF0F2744),
      Color(0xFF1B4F9C),
      Color(0xFF0A2A5C),
    ],
  );

  // —— Clair ——
  static const Color _lightPrimaryDark = Color(0xFF0F2744);
  static const Color _lightBackground = Color(0xFFF3F6FB);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightSurfaceElevated = Color(0xFFE8EEF7);
  /// Équivalent clair du blanc sombre : bleu royal (comme « Tout télécharger »).
  static const Color _lightWhite = royalBlue;
  /// Équivalent clair du soft-white sombre : bleu royal un peu plus doux.
  static const Color _lightSoftWhite = Color(0xFF3A6DB5);
  static const Color _lightGrey = Color(0xFF5B6B7C);
  static const Color _lightMuted = Color(0xFF8A97A8);

  /// Header Accueil en mode clair — fond aéré, texte marine.
  static const LinearGradient _lightHeaderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFF5F9FD),
      Color(0xFFE9F1FA),
      Color(0xFFD9E8F6),
    ],
  );

  static const LinearGradient _darkLiveBannerOfflineGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0A1F3D),
      Color(0xFF1B4F9C),
      Color(0xFF071428),
    ],
  );

  static const LinearGradient _lightLiveBannerOfflineGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF8FAFD),
      Color(0xFFEDF4FC),
      Color(0xFFE0ECFA),
      Color(0xFFD2E4F7),
    ],
  );

  static bool get isLight => ThemeController.isLight;

  static Color get primaryDark =>
      isLight ? _lightPrimaryDark : _darkPrimaryDark;
  static Color get background => isLight ? _lightBackground : _darkBackground;
  static Color get surface => isLight ? _lightSurface : _darkSurface;
  static Color get surfaceElevated =>
      isLight ? _lightSurfaceElevated : _darkSurfaceElevated;

  /// Fond SnackBar contrasté (lisible en mode clair).
  static Color get snackBarBackground =>
      isLight ? _lightPrimaryDark : _darkSurfaceElevated;

  /// Texte / icônes sur [snackBarBackground] — toujours clair.
  static const Color snackBarForeground = _darkWhite;

  static Color get white => isLight ? _lightWhite : _darkWhite;
  static Color get softWhite => isLight ? _lightSoftWhite : _darkSoftWhite;
  static Color get grey => isLight ? _lightGrey : _darkGrey;
  static Color get muted => isLight ? _lightMuted : _darkMuted;

  /// Accent texte/icônes : bleu royal en clair (comme « Tout Télécharger »), or en sombre.
  static Color get accentOnSurface =>
      isLight ? royalBlue : _darkAccentOnSurface;

  /// Accent secondaire (sous-titres, badges) — même logique clair/sombre.
  static Color get goldOnSurface =>
      isLight ? royalBlue : _darkGoldHighlight;

  /// Accent historique : bleu en clair, or en sombre.
  static Color get accentGold => isLight ? royalBlue : _darkAccentGold;

  /// Variante claire de l’accent : bleu en clair, or en sombre.
  static Color get goldLight => isLight ? royalBlue : _darkGoldLight;

  /// Texte / icônes toujours clairs (headers, overlays sombres).
  static const Color onDark = _darkWhite;

  /// Texte sur boutons et badges dorés.
  static Color get onAccent => isLight ? _lightPrimaryDark : _darkPrimaryDark;

  /// Séparateurs et bordures discrètes.
  static Color get divider =>
      isLight ? const Color(0x1A0F1C2E) : Colors.white.withValues(alpha: 0.12);

  static Color get borderSubtle =>
      isLight ? const Color(0x260F1C2E) : Colors.white.withValues(alpha: 0.12);

  static LinearGradient get headerGradient =>
      isLight ? _lightHeaderGradient : _darkHeaderGradient;

  static LinearGradient get liveBannerOfflineGradient =>
      isLight ? _lightLiveBannerOfflineGradient : _darkLiveBannerOfflineGradient;

  /// Texte et icônes sur le header Accueil.
  static Color get headerOnSurface =>
      isLight ? royalBlue : _darkWhite;

  static Color get headerOnSurfaceMuted =>
      isLight ? _lightGrey : _darkSoftWhite.withValues(alpha: 0.85);

  static Color get headerOnSurfaceSubtle =>
      isLight ? _lightMuted : _darkSoftWhite.withValues(alpha: 0.65);

  static Color get headerSearchFill =>
      isLight ? royalBlue.withValues(alpha: 0.07) : Colors.white.withValues(alpha: 0.15);

  static Color get headerSearchBorder =>
      isLight ? royalBlue.withValues(alpha: 0.2) : Colors.white24;

  static Color get headerSearchIcon =>
      isLight ? royalBlue.withValues(alpha: 0.72) : Colors.white.withValues(alpha: 0.8);

  static Color get headerSearchHint =>
      isLight ? _lightGrey : Colors.white.withValues(alpha: 0.7);

  static Color get headerToolbarFill =>
      isLight ? royalBlue.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.11);

  static Color get headerToolbarBorder =>
      isLight ? royalBlue.withValues(alpha: 0.16) : Colors.white.withValues(alpha: 0.22);

  static Color get headerToolbarIcon =>
      isLight ? royalBlue : _darkWhite;

  /// Accent principal sur fond clair (bleu royal) ; or conservé en sombre.
  static Color get brandAccent => isLight ? royalBlue : _darkGoldHighlight;

  /// Carte live hors diffusion.
  static Color get liveBannerTitle =>
      isLight ? royalBlue : _darkWhite;

  static Color get liveBannerSubtitle =>
      isLight ? royalBlue : _darkAccentOnSurface.withValues(alpha: 0.95);

  static Color get liveBannerChronoBg => isLight
      ? royalBlue.withValues(alpha: 0.08)
      : Colors.black.withValues(alpha: 0.28);

  static Color get liveBannerChronoBorder => isLight
      ? royalBlue.withValues(alpha: 0.22)
      : _darkAccentOnSurface.withValues(alpha: 0.4);

  static Color get liveBannerChronoLabel => isLight ? royalBlue : _darkGoldHighlight;

  static Color get liveBannerChronoValue =>
      isLight ? royalBlue : _darkGoldHighlight;

  static Color get liveBannerChronoTime =>
      isLight ? _lightSoftWhite : _darkWhite;

  static Color get liveBannerDecorCircle => isLight
      ? royalBlue.withValues(alpha: 0.06)
      : _darkAccentOnSurface.withValues(alpha: 0.08);

  /// Boutons d'action principaux (ex. Soutenir la reconstruction).
  static Color get ctaBackground =>
      isLight ? royalBlue : _darkAccentOnSurface;

  static Color get ctaForeground =>
      isLight ? _darkWhite : _darkPrimaryDark;

  static LinearGradient get goldGradient => isLight
      ? const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D3A7A), royalBlue, Color(0xFF3A6DB5)],
        )
      : const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFB8860B), _darkAccentOnSurface, _darkGoldHighlight],
        );

  static LinearGradient get playerGradient => isLight
      ? LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_lightSurfaceElevated, _lightSurface, _lightBackground],
        )
      : const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF071428),
            Color(0xFF12263F),
            Color(0xFF0A1A30),
          ],
        );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [royalBlue, Color(0xFF0D3A7A)],
  );

  static const LinearGradient liveGradient = LinearGradient(
    colors: [Color(0xFFE53935), crossRed],
  );

  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData get lightTheme => _buildTheme(Brightness.light);

  static ThemeData _buildTheme(Brightness brightness) {
    final light = brightness == Brightness.light;
    final bg = light ? _lightBackground : _darkBackground;
    final surf = light ? _lightSurface : _darkSurface;
    final onSurf = light ? _lightWhite : _darkWhite;
    final soft = light ? _lightSoftWhite : _darkSoftWhite;
    final g = light ? _lightGrey : _darkGrey;
    final primaryInk = light ? _lightPrimaryDark : _darkPrimaryDark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: light ? royalBlue : _darkAccentOnSurface,
        onPrimary: light ? _darkWhite : _darkPrimaryDark,
        secondary: royalBlue,
        onSecondary: _darkWhite,
        tertiary: light ? royalBlue : _darkGoldHighlight,
        onTertiary: light ? _darkWhite : _darkPrimaryDark,
        error: errorRed,
        onError: _darkWhite,
        surface: surf,
        onSurface: onSurf,
      ),
      scaffoldBackgroundColor: bg,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: onSurf,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle:
            light ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          color: onSurf,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surf,
        indicatorColor: (light ? royalBlue : _darkAccentOnSurface)
            .withValues(alpha: 0.14),
        elevation: 8,
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 9.5,
            height: 1.1,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected
                ? (light ? royalBlue : _darkAccentOnSurface)
                : g,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 22,
            color: selected
                ? (light ? royalBlue : _darkAccentOnSurface)
                : g,
          );
        }),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: light ? royalBlue : _darkAccentOnSurface,
          foregroundColor: light ? _darkWhite : primaryInk,
          elevation: 0,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      cardTheme: CardThemeData(
        color: surf,
        elevation: light ? 0 : 1,
        shadowColor: Colors.black.withValues(alpha: light ? 0.08 : 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: royalBlue.withValues(alpha: light ? 0.1 : 0.2),
        labelStyle: TextStyle(
          fontSize: 12,
          color: light ? royalBlue : _darkGoldHighlight,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: onSurf,
          fontSize: 32,
          fontWeight: FontWeight.w700,
        ),
        headlineLarge: TextStyle(
          color: onSurf,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: TextStyle(
          color: onSurf,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: onSurf,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: onSurf,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(color: soft, fontSize: 16, height: 1.5),
        bodyMedium: TextStyle(color: soft, fontSize: 14, height: 1.5),
        bodySmall: TextStyle(color: g, fontSize: 12, height: 1.4),
        labelLarge: TextStyle(
          color: onSurf,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      iconTheme: IconThemeData(color: onSurf, size: 24),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: light ? royalBlue : _darkAccentOnSurface,
      ),
      dividerColor: light ? const Color(0x1A0F1C2E) : Colors.white.withValues(alpha: 0.12),
      listTileTheme: ListTileThemeData(
        iconColor: light ? royalBlue : _darkAccentOnSurface,
        textColor: onSurf,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surf,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: light ? _lightPrimaryDark : _darkSurfaceElevated,
        contentTextStyle: const TextStyle(
          color: _darkWhite,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        actionTextColor: light ? _darkGoldHighlight : _darkAccentOnSurface,
        behavior: SnackBarBehavior.floating,
        elevation: 6,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surf,
        titleTextStyle: TextStyle(
          color: onSurf,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: TextStyle(color: soft, fontSize: 14),
      ),
    );
  }
}

/// Synchronise le mode clair/sombre pour les getters [AppTheme].
class ThemeController {
  static ThemeMode mode = ThemeMode.light;
  static Brightness platformBrightness = Brightness.light;

  static bool get isLight {
    switch (mode) {
      case ThemeMode.light:
        return true;
      case ThemeMode.dark:
        return false;
      case ThemeMode.system:
        return platformBrightness == Brightness.light;
    }
  }

  /// Applique le mode avant la construction des routes [MaterialApp].
  static void sync({
    required ThemeMode themeMode,
    required Brightness platform,
  }) {
    mode = themeMode;
    platformBrightness = platform;
  }
}
