import 'dart:ui';
import 'dart:io';
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
                  flexibleSpace: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 200),
                    builder: (context, value, child) {
                      return ClipRRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: 4 * value,
                            sigmaY: 4 * value,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface.withOpacity(0.72 * value),
                              border: Border(
                                bottom: BorderSide(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.06 * value),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
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
                // Liquid glass content area with iOS rounded corners
                SliverToBoxAdapter(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF0D0D14).withOpacity(0.85)
                              : Theme.of(context).colorScheme.surface.withOpacity(0.88),
                          border: Border(
                            top: BorderSide(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.06),
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Theme section
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
                                  final Color cardTextColor = isDarkPalette ? Colors.white : null;
                                  final Color cardSubColor = isDarkPalette ? Colors.white70 : Colors.grey.shade600;
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

                              // App Icon Picker section
                              Text('App Icon Picker',
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
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Stack(
                                      children: [
                                        CircleAvatar(
                                          radius: 28,
                                          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                                          backgroundImage: settings.customIconFile != null ? FileImage(settings.customIconFile!) : null,
                                          child: settings.customIconFile == null
                                            ? const Icon(Icons.photo, size: 28)
                                            : null,
                                        ),
                                        if (settings.customIconFile != null)
                                          Positioned(
                                            right: 0,
                                            bottom: 0,
                                            child: Container(
                                              padding: const EdgeInsets.all(3),
                                              decoration: BoxDecoration(
                                                color: Colors.green,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(Icons.check, color: Colors.white, size: 12),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Custom app icon',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: isDark ? Colors.white : null,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Android does not support changing app icons at runtime',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: isDark ? Colors.white60 : Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Use a custom launcher like Nova to change icons',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: isDark ? Colors.white38 : Colors.grey.shade500,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            settings.customIconFile != null ? 'Selected from gallery' : 'Choose an image to personalize',
                                            style: TextStyle(
                                              color: isDark ? Colors.white70 : null,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: settings.pickCustomIcon,
                                      child: const Text('Pick'),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 26),

                              // Motion Effects section
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
