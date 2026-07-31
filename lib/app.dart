import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'screens/albums_screen.dart';
import 'screens/bin_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/frosted_bar.dart';

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

  final List<Widget> _screens = const [
    HomeScreen(),
    AlbumsScreen(),
    BinScreen(),
    SettingsScreen(),
  ];

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: FrostedBar(
        borderRadius: BorderRadius.circular(32),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onNavTap,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.photo_library_outlined),
              selectedIcon: Icon(Icons.photo_library),
              label: 'Gallery',
            ),
            NavigationDestination(
              icon: Icon(Icons.album_outlined),
              selectedIcon: Icon(Icons.album),
              label: 'Albums',
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
    );
  }
}
