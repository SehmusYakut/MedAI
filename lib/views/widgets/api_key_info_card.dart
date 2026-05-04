import 'package:flutter/material.dart';
import '../api_key_tour_screen.dart';

class ApiKeyInfoCard extends StatelessWidget {
  final String title;
  final String description;
  final String buttonLabel;
  final Color? backgroundColor;
  final VoidCallback? onViewTour;

  const ApiKeyInfoCard({
    super.key,
    this.title = 'API Keys Required',
    this.description = 'Set up AI service API keys to use advanced features',
    this.buttonLabel = 'Learn How',
    this.backgroundColor,
    this.onViewTour,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bgColor = backgroundColor ?? cs.errorContainer;
    final textColor = Theme.of(context).brightness == Brightness.dark
        ? cs.onErrorContainer
        : cs.onErrorContainer;

    return Card(
      color: bgColor.withValues(alpha: 0.7),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.key_outlined,
                  color: textColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: textColor,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: textColor,
                  ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: onViewTour ??
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ApiKeyTourScreen(),
                        ),
                      );
                    },
                icon: const Icon(Icons.school_outlined, size: 18),
                label: Text(buttonLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
