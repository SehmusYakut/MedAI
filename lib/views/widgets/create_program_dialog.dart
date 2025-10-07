import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/medicine_program_view_model.dart';
import 'weekly_schedule.dart';
import 'reminder_time_picker.dart';

class CreateProgramDialog extends StatefulWidget {
  const CreateProgramDialog({super.key});

  @override
  State<CreateProgramDialog> createState() => _CreateProgramDialogState();
}

class _CreateProgramDialogState extends State<CreateProgramDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<bool> _selectedDays = List.filled(7, false);
  final List<TimeOfDay> _reminderTimes = [];
  final _scrollController = ScrollController();

  static const _daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<String> _getSelectedDaysAsStrings() {
    return _selectedDays
        .asMap()
        .entries
        .where((entry) => entry.value)
        .map((entry) => _daysOfWeek[entry.key])
        .toList();
  }

  void _createProgram() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a program name'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final selectedDays = _getSelectedDaysAsStrings();
    if (selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one day'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_reminderTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one reminder time'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    context.read<MedicineProgramViewModel>().createProgram(
          name: _nameController.text,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          days: selectedDays,
          reminderTimes: _reminderTimes,
        );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: colorScheme.onSurface.withValues(alpha: 0.1)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.medical_services,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create Program',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Set up your medicine schedule',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Flexible(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Program Name *',
                          hintText: 'Enter program name',
                          prefixIcon: Icon(Icons.edit),
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description (Optional)',
                          hintText: 'Enter program description',
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Schedule',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      WeeklySchedule(
                        selectedDays: _selectedDays,
                        onChanged: (index, value) {
                          setState(() => _selectedDays[index] = value);
                        },
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Reminders',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ReminderTimePicker(
                        times: _reminderTimes,
                        onChanged: (times) {
                          setState(
                            () => _reminderTimes
                              ..clear()
                              ..addAll(times),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _createProgram,
                    icon: const Icon(Icons.add),
                    label: const Text('Create Program'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
