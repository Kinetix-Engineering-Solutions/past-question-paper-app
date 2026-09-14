import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/theme_mode_provider.dart';

class AppearanceSetting extends ConsumerStatefulWidget {
  const AppearanceSetting({super.key});

  @override
  ConsumerState<AppearanceSetting> createState() => _AppearanceSettingState();
}

class _AppearanceSettingState extends ConsumerState<AppearanceSetting> {
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(themeModeProvider);
    return ListTile(
      leading: const Icon(Icons.brightness_6_outlined),
      title: const Text('Appearance'),
      trailing: DropdownButton<ThemeMode>(
        value: mode,
        underline: const SizedBox.shrink(),
        items: const [
          DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
          DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
          DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
        ],
        onChanged: _saving
            ? null
            : (value) async {
                if (value == null) return;
                setState(() => _saving = true);
                try {
                  await ref.read(themeModeProvider.notifier).setMode(value);
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Could not save appearance. Try again.'),
                      ),
                    );
                  }
                } finally {
                  if (mounted) setState(() => _saving = false);
                }
              },
      ),
    );
  }
}
