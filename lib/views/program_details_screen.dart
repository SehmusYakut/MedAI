import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/medicine_program_view_model.dart';
import '../models/medicine_program.dart' show MedicineProgram;
import '../models/medicine.dart';
import 'widgets/weekly_schedule.dart';
import 'widgets/reminder_time_picker.dart';
import 'widgets/add_medicine_dialog.dart';

class ProgramDetailsScreen extends StatefulWidget {
  final MedicineProgram program;

  const ProgramDetailsScreen({super.key, required this.program});

  @override
  State<ProgramDetailsScreen> createState() => _ProgramDetailsScreenState();
}

class _ProgramDetailsScreenState extends State<ProgramDetailsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late List<bool> _selectedDays;
  late List<TimeOfDay> _reminderTimes;

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
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.program.name);
    _descriptionController = TextEditingController(
      text: widget.program.description,
    );
    // Convert string days to boolean array
    _selectedDays = List.generate(
      7,
      (index) => widget.program.days.contains(_daysOfWeek[index]),
    );
    _reminderTimes = List.from(widget.program.reminderTimes);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
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

  void _saveChanges() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a program name'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final viewModel = context.read<MedicineProgramViewModel>();
    final updatedProgram = widget.program.copyWith(
      name: _nameController.text,
      description:
          _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
      days: _getSelectedDaysAsStrings(),
      reminderTimes: _reminderTimes,
    );

    viewModel.updateProgram(updatedProgram);
    Navigator.pop(context);
  }

  void _addMedicine() {
    showDialog(
      context: context,
      builder: (context) => AddMedicineDialog(programId: widget.program.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Program Details'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveChanges),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Basic Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Program Name',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Schedule',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  WeeklySchedule(
                    selectedDays: _selectedDays,
                    onChanged: (index, value) {
                      setState(() => _selectedDays[index] = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  ReminderTimePicker(
                    times: _reminderTimes,
                    onChanged:
                        (times) => setState(() => _reminderTimes = times),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Medicines',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: _addMedicine,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Medicine'),
                      ),
                    ],
                  ),
                  if (widget.program.medicines.isEmpty) ...[
                    const SizedBox(height: 24),
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.medication_outlined,
                            size: 48,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.2),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No medicines added yet',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 16),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.program.medicines.length,
                      separatorBuilder:
                          (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final medicine = widget.program.medicines[index];
                        return ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.medication),
                          ),
                          title: Text(medicine.name),
                          subtitle: Text(medicine.dosage),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () {
                              context
                                  .read<MedicineProgramViewModel>()
                                  .removeMedicine(
                                    widget.program.id,
                                    medicine.id,
                                  );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
