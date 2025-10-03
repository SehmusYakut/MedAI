import 'package:flutter/material.dart';

class WeeklySchedule extends StatelessWidget {
  final List<bool> selectedDays;
  final void Function(int index, bool value) onChanged;

  const WeeklySchedule({
    super.key,
    required this.selectedDays,
    required this.onChanged,
  });

  static const _daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Schedule Days *', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        if (!selectedDays.contains(true))
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Please select at least one day',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(7, (index) {
            return FilterChip(
              label: Text(_daysOfWeek[index]),
              selected: selectedDays[index],
              onSelected: (value) => onChanged(index, value),
            );
          }),
        ),
      ],
    );
  }
}
