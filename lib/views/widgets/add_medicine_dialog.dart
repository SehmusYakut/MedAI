import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/medicine.dart';
import '../../models/medicine_program.dart' show MedicineSource;
import '../../viewmodels/medicine_program_view_model.dart';
import 'package:uuid/uuid.dart';

class AddMedicineDialog extends StatefulWidget {
  final String programId;

  const AddMedicineDialog({super.key, required this.programId});

  @override
  State<AddMedicineDialog> createState() => _AddMedicineDialogState();
}

class _AddMedicineDialogState extends State<AddMedicineDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dosageController = TextEditingController();
  final _instructionsController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  MedicineSource? _selectedSource;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _dosageController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (date != null) {
      setState(() {
        _startDate = date;
        if (_endDate != null && _endDate!.isBefore(_startDate)) {
          _endDate = null;
        }
      });
    }
  }

  void _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 30)),
      firstDate: _startDate,
      lastDate: _startDate.add(const Duration(days: 365 * 2)),
    );
    if (date != null) {
      setState(() => _endDate = date);
    }
  }

  void _addMedicine() {
    if (_nameController.text.isEmpty || _dosageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final medicine = Medicine(
      id: const Uuid().v4(),
      name: _nameController.text,
      description:
          _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
      dosage: _dosageController.text,
      startDate: _startDate,
      endDate: _endDate,
      instructions:
          _instructionsController.text.isEmpty
              ? null
              : _instructionsController.text,
      source: _selectedSource?.name,
    );

    context.read<MedicineProgramViewModel>().addMedicine(
      widget.programId,
      medicine,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final sources = MedicineProgramViewModel.commonSources;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.medication, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          const Text('Add Medicine'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Medicine Name *',
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
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _dosageController,
              decoration: const InputDecoration(
                labelText: 'Dosage *',
                border: OutlineInputBorder(),
                hintText: 'e.g., 1 tablet, 5ml, etc.',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _instructionsController,
              decoration: const InputDecoration(
                labelText: 'Instructions (Optional)',
                border: OutlineInputBorder(),
                hintText: 'e.g., Take with food',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<MedicineSource>(
              value: _selectedSource,
              decoration: const InputDecoration(
                labelText: 'Medical Department/Source',
                border: OutlineInputBorder(),
              ),
              items:
                  sources.map((source) {
                    return DropdownMenuItem(
                      value: source,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(source.name),
                          if (source.description != null)
                            Text(
                              source.description!,
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
              onChanged: (source) => setState(() => _selectedSource = source),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Start Date *',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      FilledButton.icon(
                        onPressed: _selectStartDate,
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'End Date',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      FilledButton.icon(
                        onPressed: _selectEndDate,
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          _endDate == null
                              ? 'Not set'
                              : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _addMedicine,
          icon: const Icon(Icons.add),
          label: const Text('Add Medicine'),
        ),
      ],
    );
  }
}
