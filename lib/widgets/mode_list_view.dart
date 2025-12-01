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
                      color: Colors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => onModeSelected(mode, index),
                    child: Row(
                      children: [
                        // Colored vertical bar
                        Container(
                          width: 4,
                          height: 80,
                          decoration: BoxDecoration(
                            color: mode.color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Icon
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: mode.color.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(mode.icon, size: 24, color: mode.color),
                        ),
                        const SizedBox(width: 16),
                        // Mode name and description
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mode.name,
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  mode.description,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: mode.color,
                          size: 18,
                        ),
                        const SizedBox(width: 16),
                      ],
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
