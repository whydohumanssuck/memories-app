import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/frosted_bar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  flexibleSpace: TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 200),
                    builder: (context, value, child) {
                      return ClipRRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: 8 * value,
                            sigmaY: 8 * value,
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
                    ),
                  ),
                ),
                // iOS-style top spacer with rounded corners
                SliverToBoxAdapter(
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      color: Theme.of(context).colorScheme.surface.withOpacity(0.95),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Theme', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: theme.palettes.map((palette) {
                            final index = theme.palettes.indexOf(palette);
                            final isSelected = theme.activeIndex == index;
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
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: palette.scheme.brightness == Brightness.dark
                                    ? Colors.white
                                    : null,
                              ),
                            ),
                                    const SizedBox(height: 6),
                                    Text(
                              'Tap to apply',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: palette.scheme.brightness == Brightness.dark
                                    ? Colors.white70
                                    : null,
                              ),
                            ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 26),
                        const Text('App Icon Picker', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
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
                                      const Text('Custom app icon', style: TextStyle(fontWeight: FontWeight.w600)),
                                        const Text('Android does not support changing app icons at runtime', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                        const SizedBox(height: 4),
                                        Text('Use a custom launcher like Nova to change icons', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                                      const SizedBox(height: 4),
                                      Text(
                                        settings.customIconFile != null ? 'Selected from gallery' : 'Choose an image to personalize',
                                        style: Theme.of(context).textTheme.bodySmall,
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
                        ),
                        const SizedBox(height: 26),
                        const Text('Motion Effects', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        SwitchListTile(
                          title: const Text('Enable motion animations'),
                          subtitle: const Text('Use subtle transitions and hero effects.'),
                          value: settings.useSystemMotion,
                          onChanged: settings.toggleMotion,
                        ),
                      ],
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
