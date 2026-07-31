import 'package:flutter/material.dart';

class AppPalette {
  final String name;
  final Color seedColor;
  final ColorScheme scheme;

  AppPalette({
    required this.name,
    required this.seedColor,
    required Brightness brightness,
  }) : scheme = ColorScheme.fromSeed(seedColor: seedColor, brightness: brightness);
}

class ThemeProvider extends ChangeNotifier {
  int _activeIndex = 0;

  final List<AppPalette> palettes = [
    AppPalette(name: 'Aurora', seedColor: const Color(0xFF5764FF), brightness: Brightness.light),
    AppPalette(name: 'Citrus', seedColor: const Color(0xFFFFB74D), brightness: Brightness.light),
    AppPalette(name: 'Emerald', seedColor: const Color(0xFF4CAF50), brightness: Brightness.light),
    AppPalette(name: 'Slate', seedColor: const Color(0xFF607D8B), brightness: Brightness.light),
    AppPalette(name: 'Rose', seedColor: const Color(0xFFEC407A), brightness: Brightness.light),
    AppPalette(name: 'Ocean', seedColor: const Color(0xFF00B8D4), brightness: Brightness.light),
    // Dark themes
    AppPalette(name: 'AMOLED Black', seedColor: const Color(0xFF6C5CE7), brightness: Brightness.dark),
    AppPalette(name: 'Midnight Black', seedColor: const Color(0xFF1A1A2E), brightness: Brightness.dark),
  ];

  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: currentPalette.scheme,
      scaffoldBackgroundColor: currentPalette.scheme.background,
      fontFamily: '.SF UI Text',
      appBarTheme: AppBarTheme(
        backgroundColor: currentPalette.scheme.surface.withOpacity(0.92),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: currentPalette.scheme.onSurface),
      ),
      cardTheme: CardThemeData(
        color: currentPalette.scheme.surfaceVariant,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      bottomAppBarTheme: BottomAppBarThemeData(color: currentPalette.scheme.surface.withOpacity(0.92)),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: currentPalette.scheme.primary,
        foregroundColor: currentPalette.scheme.onPrimary,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: currentPalette.scheme.surface.withOpacity(0.96),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
    );
  }

  ThemeData get darkTheme {
    final isAmoled = currentPalette.name == 'AMOLED Black';
    final isMidnight = currentPalette.name == 'Midnight Black';
    final Color bgColor = isAmoled ? const Color(0xFF000000) : (isMidnight ? const Color(0xFF0A0A0F) : currentPalette.scheme.background);
    final Color surfaceColor = isAmoled ? const Color(0xFF000000) : (isMidnight ? const Color(0xFF0D0D14) : currentPalette.scheme.surface);

    final darkScheme = ColorScheme.fromSeed(
      seedColor: currentPalette.seedColor,
      brightness: Brightness.dark,
    ).copyWith(
      background: bgColor,
      surface: surfaceColor,
      onBackground: Colors.white,
      onSurface: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: darkScheme,
      scaffoldBackgroundColor: bgColor,
      fontFamily: '.SF UI Text',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor.withOpacity(0.85),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        indicatorColor: darkScheme.primary,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return const TextStyle(color: Colors.white, fontSize: 12);
          return const TextStyle(color: Colors.white60, fontSize: 12);
        }),
      ),
    );
  }

  AppPalette get currentPalette => palettes[_activeIndex];

  int get activeIndex => _activeIndex;

  void updateTheme(int index) {
    if (index >= 0 && index < palettes.length) {
      _activeIndex = index;
      notifyListeners();
    }
  }
}
