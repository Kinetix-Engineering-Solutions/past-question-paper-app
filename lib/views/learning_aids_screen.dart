import 'package:flutter/material.dart';

class LearningAidsScreen extends StatelessWidget {
  const LearningAidsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final aids = <_AidItem>[
      _AidItem(
        title: 'Formula Sheets',
        subtitle: 'Algebra, Functions, Probability, Calculus',
        icon: Icons.functions,
        body: '''
Algebra – Common Identities:
- (a + b)^2 = a^2 + 2ab + b^2
- (a - b)^2 = a^2 - 2ab + b^2
- a^2 - b^2 = (a - b)(a + b)

Quadratic:
- x = [-b ± √(b^2 - 4ac)] / (2a)
''',
      ),
      _AidItem(
        title: 'Methods & Patterns',
        subtitle: 'Step-by-step solving playbooks',
        icon: Icons.fact_check,
        body: '''
Quadratic (Completing the Square):
1) Ensure a = 1 (divide if needed)
2) Move constant to RHS
3) Add (b/2)^2 to both sides
4) Factor LHS as (x + b/2)^2
5) Take square root and solve
''',
      ),
      _AidItem(
        title: 'Exam Tips',
        subtitle: 'Time management and common traps',
        icon: Icons.tips_and_updates,
        body: '''
Tips:
- Underline what’s asked: value, expression, or proof
- Estimate order of magnitude for sanity check
- Leave space; return to hard parts later
''',
      ),
      _AidItem(
        title: 'Tools',
        subtitle: 'Conversions and quick reference',
        icon: Icons.build,
        body: '''
Quick Conversions:
- Degrees ↔ Radians: π rad = 180°
- Log rules: log(ab) = log a + log b
- Common constants: π ≈ 3.1416
''',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Learning Aids')),
      body: ListView.separated(
        itemCount: aids.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final item = aids[i];
          return ListTile(
            leading: Icon(item.icon, color: Theme.of(context).colorScheme.primary),
            title: Text(item.title),
            subtitle: Text(item.subtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => _AidDetailScreen(item: item),
            )),
          );
        },
      ),
    );
  }
}

class _AidItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final String body;
  const _AidItem({required this.title, required this.subtitle, required this.icon, required this.body});
}

class _AidDetailScreen extends StatelessWidget {
  final _AidItem item;
  const _AidDetailScreen({required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(item.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Text(item.body, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ),
    );
  }
}
