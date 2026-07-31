import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'screens/bin_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';

class MemoriesApp extends StatelessWidget {
  const MemoriesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Memories!',
          theme: theme.lightTheme,
          darkTheme: theme.darkTheme,
          themeMode: theme.activeIndex >= 6 ? ThemeMode.dark : ThemeMode.light,
          home: const AppShell(),
        );
      },
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  final List<Widget> _screens = const [
    HomeScreen(),
    BinScreen(),
    SettingsScreen(),
  ];

  void _onNavTap(int index) {
    if (index == _selectedIndex) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _selectedIndex = index),
        children: _screens,
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(36),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(36),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(36),
              color: isDark
                  ? const Color(0xFF0D0D14).withOpacity(0.96)
                  : Theme.of(context).colorScheme.surface.withOpacity(0.96),
              border: Border.all(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.08),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            child: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onNavTap,
              backgroundColor: Colors.transparent,
              elevation: 0,
              shadowColor: Colors.transparent,
              indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.photo_library_outlined),
                  selectedIcon: Icon(Icons.photo_library),
                  label: 'Gallery',
                ),
                NavigationDestination(
                  icon: Icon(Icons.delete_outline),
                  selectedIcon: Icon(Icons.delete),
                  label: 'Bin',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
