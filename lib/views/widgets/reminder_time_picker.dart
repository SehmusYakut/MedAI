import 'package:flutter/material.dart';

class ReminderTimePicker extends StatelessWidget {
  final List<TimeOfDay> times;
  final ValueChanged<List<TimeOfDay>> onChanged;

  const ReminderTimePicker({
    super.key,
    required this.times,
    required this.onChanged,
  });

  void _addTime(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      final updatedTimes = List<TimeOfDay>.from(times);
      if (!updatedTimes.any(
        (t) => t.hour == time.hour && t.minute == time.minute,
      )) {
        updatedTimes.add(time);
        updatedTimes.sort((a, b) {
          final aMinutes = a.hour * 60 + a.minute;
          final bMinutes = b.hour * 60 + b.minute;
          return aMinutes.compareTo(bMinutes);
        });
        onChanged(updatedTimes);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This time is already added'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Reminder Times',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: TextButton.icon(
                onPressed: () => _addTime(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
          ],
        ),
        if (times.isEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Please add at least one reminder time',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 12,
            ),
          ),
        ] else ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: times.map((time) {
              return Chip(
                label: Text(_formatTime(time)),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  final updatedTimes = List<TimeOfDay>.from(times)
                    ..removeWhere(
                      (t) => t.hour == time.hour && t.minute == time.minute,
                    );
                  onChanged(updatedTimes);
                },
                backgroundColor:
                    Theme.of(context).colorScheme.secondaryContainer,
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
                deleteIconColor:
                    Theme.of(context).colorScheme.onSecondaryContainer,
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
