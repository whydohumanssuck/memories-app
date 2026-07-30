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
                  backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.92),
                  title: const Text('Settings'),
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
                                    Text(palette.name, style: Theme.of(context).textTheme.titleMedium),
                                    const SizedBox(height: 6),
                                    Text('Tap to apply', style: Theme.of(context).textTheme.bodySmall),
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
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                                  backgroundImage: settings.customIconFile != null ? FileImage(settings.customIconFile!) : null,
                                  child: settings.customIconFile == null ? const Icon(Icons.photo, size: 28) : null,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Custom app icon', style: TextStyle(fontWeight: FontWeight.w600)),
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
