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
    AppPalette(name: 'Aurora', seedColor: const Color(0xFF5A5AFF), brightness: Brightness.light),
    AppPalette(name: 'Citrus', seedColor: const Color(0xFFFFB746), brightness: Brightness.light),
    AppPalette(name: 'Emerald', seedColor: const Color(0xFF3EA55D), brightness: Brightness.light),
    AppPalette(name: 'Slate', seedColor: const Color(0xFF607D8B), brightness: Brightness.light),
    AppPalette(name: 'Rose', seedColor: const Color(0xFFEC407A), brightness: Brightness.light),
    AppPalette(name: 'Ocean', seedColor: const Color(0xFF0097A7), brightness: Brightness.light),
    // Dark themes
    AppPalette(name: 'AMOLED Black', seedColor: const Color(0xFF6C5CE7), brightness: Brightness.dark),
  ];

  ThemeData get lightTheme {
    final scheme = currentPalette.scheme;
    final typography = Typography.material2021(platform: TargetPlatform.iOS);
    final textTheme = typography.black;

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      typography: typography,
      textTheme: textTheme,
      fontFamily: '.SF UI Text',
      scaffoldBackgroundColor: scheme.background,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface.withOpacity(0.94),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: scheme.onSurface),
        titleTextStyle: textTheme.titleLarge?.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w700),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface.withOpacity(0.92),
        indicatorColor: scheme.primaryContainer,
        labelTextStyle: MaterialStateProperty.all(textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
        iconTheme: MaterialStateProperty.all(IconThemeData(color: scheme.onSurfaceVariant)),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceVariant,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface.withOpacity(0.96),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface.withOpacity(0.90),
        modalBackgroundColor: scheme.surface.withOpacity(0.90),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
    );
  }

  ThemeData get darkTheme {
    final bool isAmoled = currentPalette.name == 'AMOLED Black';
    final Color bgColor = isAmoled ? const Color(0xFF000000) : currentPalette.scheme.background;
    final Color surfaceColor = isAmoled ? const Color(0xFF000000) : currentPalette.scheme.surface;

    final scheme = ColorScheme.fromSeed(
      seedColor: currentPalette.seedColor,
      brightness: Brightness.dark,
    ).copyWith(
      background: bgColor,
      surface: surfaceColor,
      onBackground: Colors.white,
      onSurface: Colors.white,
    );
    final typography = Typography.material2021(platform: TargetPlatform.iOS);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      typography: typography,
      fontFamily: '.SF UI Text',
      scaffoldBackgroundColor: bgColor,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        indicatorColor: scheme.primary,
        labelTextStyle: MaterialStateProperty.all(
          const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        iconTheme: MaterialStateProperty.all(const IconThemeData(color: Colors.white70)),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor.withOpacity(0.85),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: const Color(0xFF1E1E24).withOpacity(0.92),
        modalBackgroundColor: const Color(0xFF1E1E24).withOpacity(0.92),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: Colors.white,
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
