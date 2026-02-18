import 'package:aura/features/settings/presentation/manager/theme_cubit.dart';
import 'package:aura/features/settings/presentation/widgets/settings_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 140)), // For TopBar

            // Theme Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text("Appearance", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary)),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                _buildThemeTile(context),
              ]),
            ),

            const SliverToBoxAdapter(child: Divider(thickness: 0.5)),

            // Playback Section (Visual Only)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text("Playback", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary)),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                ListTile(
                  leading: const Icon(Icons.compare_arrows_rounded),
                  title: const Text("Crossfade"),
                  subtitle: const Text("5 seconds"),
                  trailing: Switch(value: true, onChanged: (v) {}), // Dummy
                ),
                ListTile(
                  leading: const Icon(Icons.graphic_eq_rounded),
                  title: const Text("Equalizer"),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {}, // Dummy
                ),
                ListTile(
                  leading: const Icon(Icons.skip_next_rounded),
                  title: const Text("Gapless Playback"),
                  trailing: Switch(value: true, onChanged: (v) {}), // Dummy
                ),
              ]),
            ),

            const SliverToBoxAdapter(child: Divider(thickness: 0.5)),

            // About Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text("About", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary)),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded),
                  title: const Text("About Aura"),
                  subtitle: const Text("Version & Licenses"),
                  onTap: () => _showAboutDialog(context),
                ),
              ]),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)), // Bottom padding
          ],
        ),

        // Top Bar
        const Positioned(top: 20, left: 20, right: 20, height: 100, child: SettingsTopBar()),
      ],
    );
  }

  Widget _buildThemeTile(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, currentMode) {
        String modeText;
        IconData icon;
        switch (currentMode) {
          case ThemeMode.system:
            modeText = "System Default";
            icon = Icons.brightness_auto_rounded;
            break;
          case ThemeMode.light:
            modeText = "Light Mode";
            icon = Icons.light_mode_rounded;
            break;
          case ThemeMode.dark:
            modeText = "Dark Mode";
            icon = Icons.dark_mode_rounded;
            break;
        }

        return ListTile(
          leading: Icon(icon),
          title: const Text("Theme Mode"),
          subtitle: Text(modeText),
          onTap: () => _showThemeDialog(context, currentMode),
        );
      },
    );
  }

  void _showThemeDialog(BuildContext context, ThemeMode currentMode) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Choose Theme"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: const Text("System Default"),
                value: ThemeMode.system,
                // ignore: deprecated_member_use
                groupValue: currentMode,
                // ignore: deprecated_member_use
                onChanged: (value) {
                  context.read<ThemeCubit>().setTheme(value!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text("Light Mode"),
                value: ThemeMode.light,
                // ignore: deprecated_member_use
                groupValue: currentMode,
                // ignore: deprecated_member_use
                onChanged: (value) {
                  context.read<ThemeCubit>().setTheme(value!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text("Dark Mode"),
                value: ThemeMode.dark,
                // ignore: deprecated_member_use
                groupValue: currentMode,
                // ignore: deprecated_member_use
                onChanged: (value) {
                  context.read<ThemeCubit>().setTheme(value!);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Aura Music Player"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Version: ${packageInfo.version}"),
              Text("Build Number: ${packageInfo.buildNumber}"),
              const SizedBox(height: 10),
              const Text("A stylish music player built with Flutter."),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }
}
