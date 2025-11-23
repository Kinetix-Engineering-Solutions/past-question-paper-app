import 'package:flutter/material.dart';

/// Model for practice mode options
class ModeOption {
  final String name;
  final String description;
  final IconData icon;
  final Color color;

  ModeOption({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
  });
}

/// Traditional list view for practice modes (alternative to 3D carousel)
class ModeListView extends StatelessWidget {
  final List<ModeOption> modes;
  final Function(ModeOption mode, int index) onModeSelected;

  const ModeListView({
    Key? key,
    required this.modes,
    required this.onModeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        // Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            children: [
              Text(
                'Choose Practice Mode',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select how you want to practice',
                style: textTheme.bodyMedium?.copyWith(
                  color: textTheme.bodyMedium?.color?.withOpacity(0.75),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        // Mode list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: modes.length,
            itemBuilder: (context, index) {
              final mode = modes[index];

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: mode.color.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => onModeSelected(mode, index),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Icon
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: mode.color.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(mode.icon, size: 32, color: mode.color),
                          ),
                          const SizedBox(height: 16),
                          // Mode name
                          Text(
                            mode.name,
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: mode.color,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          // Description
                          Text(
                            mode.description,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
