import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Consumer2<SettingsProvider, ThemeProvider>(
      builder: (context, settings, theme, child) {
        return SafeArea(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  floating: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  flexibleSpace: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface.withOpacity(0.75),
                          border: Border(
                            bottom: BorderSide(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.06),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    'Settings',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                      color: isDark ? Colors.white : null,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      color: isDark
                          ? const Color(0xFF0D0D14).withOpacity(0.95)
                          : Theme.of(context).colorScheme.surface.withOpacity(0.95),
                      border: Border(
                        top: BorderSide(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.06),
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Theme',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : null,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: theme.palettes.map((palette) {
                              final index = theme.palettes.indexOf(palette);
                              final isSelected = theme.activeIndex == index;
                              final bool isDarkPalette = palette.name == 'AMOLED Black' || palette.name == 'Midnight Black';
                              final Color? cardTextColor = isDarkPalette ? Colors.white : null;
                              final Color? cardSubColor = isDarkPalette ? Colors.white70 : null;
                              return GestureDetector(
                                onTap: () => theme.updateTheme(index),
                                child: Container(
                                  width: 140,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: palette.scheme.surface,
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(
                                      color: isSelected ? palette.scheme.primary : palette.scheme.onSurface.withOpacity(0.12),
                                      width: 2,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: palette.scheme.primary,
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        palette.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: cardTextColor,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Tap to apply',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: cardSubColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 26),
                          Text('Motion Effects',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : null,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E1E24).withOpacity(0.6)
                                  : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.06),
                              ),
                            ),
                            child: SwitchListTile(
                              title: Text('Enable motion animations',
                                style: TextStyle(color: isDark ? Colors.white : null),
                              ),
                              subtitle: Text('Use subtle transitions and hero effects.',
                                style: TextStyle(color: isDark ? Colors.white60 : null),
                              ),
                              value: settings.useSystemMotion,
                              onChanged: settings.toggleMotion,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
