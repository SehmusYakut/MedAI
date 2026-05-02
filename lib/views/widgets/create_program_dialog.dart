import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/medicine_program_view_model.dart';
import '../../l10n/app_localizations.dart';
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
  bool _showDescription = false;
  String? _activePreset;

  static const _daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  // Preset definitions: label key → day indices
  static const _presets = {
    'daily': [0, 1, 2, 3, 4, 5, 6],
    'weekdays': [0, 1, 2, 3, 4],
    'weekends': [5, 6],
    'mwf': [0, 2, 4],
  };

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _applyPreset(String key) {
    final indices = _presets[key]!;
    setState(() {
      _activePreset = key;
      for (var i = 0; i < 7; i++) {
        _selectedDays[i] = indices.contains(i);
      }
    });
  }

  void _addQuickTime(TimeOfDay time) {
    final isDuplicate = _reminderTimes
        .any((t) => t.hour == time.hour && t.minute == time.minute);
    if (isDuplicate) return;
    setState(() {
      _reminderTimes.add(time);
      _reminderTimes
          .sort((a, b) => (a.hour * 60 + a.minute) - (b.hour * 60 + b.minute));
    });
  }

  List<String> get _selectedDayNames => _selectedDays
      .asMap()
      .entries
      .where((e) => e.value)
      .map((e) => _daysOfWeek[e.key])
      .toList();

  void _createProgram(AppLocalizations l10n) {
    if (_nameController.text.trim().isEmpty) {
      _showSnackBar(l10n.translate('enter_program_name'));
      return;
    }
    if (_selectedDayNames.isEmpty) {
      _showSnackBar(l10n.translate('select_one_day'));
      return;
    }
    if (_reminderTimes.isEmpty) {
      _showSnackBar(l10n.translate('add_one_reminder'));
      return;
    }
    context.read<MedicineProgramViewModel>().createProgram(
          name: _nameController.text.trim(),
          description:
              _showDescription && _descriptionController.text.isNotEmpty
                  ? _descriptionController.text.trim()
                  : null,
          days: _selectedDayNames,
          reminderTimes: _reminderTimes,
        );
    Navigator.pop(context);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Dialog(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          maxWidth: MediaQuery.of(context).size.width * 0.92,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DialogHeader(l10n: l10n, cs: cs),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Program name
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: '${l10n.programName} *',
                        prefixIcon: const Icon(Icons.edit_outlined),
                      ),
                      textCapitalization: TextCapitalization.words,
                      autofocus: true,
                    ),
                    const SizedBox(height: 8),

                    // Description toggle
                    TextButton.icon(
                      icon: Icon(
                          _showDescription
                              ? Icons.remove_circle_outline
                              : Icons.add_circle_outline,
                          size: 18),
                      label: Text(l10n.addDescription),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: () =>
                          setState(() => _showDescription = !_showDescription),
                    ),
                    if (_showDescription) ...[
                      TextField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: l10n.programDescription,
                          prefixIcon: const Icon(Icons.description_outlined),
                        ),
                        maxLines: 2,
                      ),
                    ],
                    const SizedBox(height: 20),

                    // Schedule section
                    _SectionLabel(
                        icon: Icons.calendar_today_outlined,
                        label: l10n.schedule),
                    const SizedBox(height: 12),
                    _QuickPresets(
                        activePreset: _activePreset,
                        onSelect: _applyPreset,
                        l10n: l10n,
                        cs: cs),
                    const SizedBox(height: 12),
                    WeeklySchedule(
                      selectedDays: _selectedDays,
                      onChanged: (index, value) {
                        setState(() {
                          _selectedDays[index] = value;
                          _activePreset = null;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Reminders section
                    _SectionLabel(
                        icon: Icons.alarm_outlined, label: l10n.reminders),
                    const SizedBox(height: 12),
                    _QuickTimesRow(
                        times: _reminderTimes,
                        onTap: _addQuickTime,
                        l10n: l10n,
                        cs: cs),
                    const SizedBox(height: 12),
                    ReminderTimePicker(
                      times: _reminderTimes,
                      onChanged: (times) => setState(() {
                        _reminderTimes
                          ..clear()
                          ..addAll(times);
                      }),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _DialogActions(
              l10n: l10n,
              onCancel: () => Navigator.pop(context),
              onCreate: () => _createProgram(l10n),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Dialog header ─────────────────────────────────────────────────────────────

class _DialogHeader extends StatelessWidget {
  final AppLocalizations l10n;
  final ColorScheme cs;
  const _DialogHeader({required this.l10n, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.medical_services_outlined,
                color: cs.onPrimaryContainer),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.createProgram,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                Text(
                  l10n.schedule,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: cs.onSurface.withValues(alpha: 0.6)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick schedule presets ────────────────────────────────────────────────────

class _QuickPresets extends StatelessWidget {
  final String? activePreset;
  final ValueChanged<String> onSelect;
  final AppLocalizations l10n;
  final ColorScheme cs;

  const _QuickPresets({
    required this.activePreset,
    required this.onSelect,
    required this.l10n,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    final presets = [
      ('daily', l10n.presetDaily),
      ('weekdays', l10n.presetWeekdays),
      ('weekends', l10n.presetWeekends),
      ('mwf', l10n.presetMwf),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.quickPresets,
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: cs.onSurface.withValues(alpha: 0.6))),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: presets.map((p) {
            final isActive = activePreset == p.$1;
            return FilterChip(
              label: Text(p.$2),
              selected: isActive,
              onSelected: (_) => onSelect(p.$1),
              showCheckmark: false,
              selectedColor: cs.primaryContainer,
              labelStyle: TextStyle(
                color: isActive ? cs.onPrimaryContainer : null,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ── Quick time chips ──────────────────────────────────────────────────────────

class _QuickTimesRow extends StatelessWidget {
  final List<TimeOfDay> times;
  final ValueChanged<TimeOfDay> onTap;
  final AppLocalizations l10n;
  final ColorScheme cs;

  static const _quickTimes = [
    TimeOfDay(hour: 8, minute: 0),
    TimeOfDay(hour: 13, minute: 0),
    TimeOfDay(hour: 20, minute: 0),
  ];

  const _QuickTimesRow({
    required this.times,
    required this.onTap,
    required this.l10n,
    required this.cs,
  });

  bool _isAdded(TimeOfDay t) =>
      times.any((x) => x.hour == t.hour && x.minute == t.minute);

  String _label(int index) => switch (index) {
        0 => l10n.timeMorning,
        1 => l10n.timeNoon,
        _ => l10n.timeEvening,
      };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.quickTimes,
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: cs.onSurface.withValues(alpha: 0.6))),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: List.generate(_quickTimes.length, (i) {
            final t = _quickTimes[i];
            final added = _isAdded(t);
            return ActionChip(
              avatar: Icon(
                added ? Icons.check : Icons.add,
                size: 16,
                color: added ? cs.onSecondaryContainer : cs.primary,
              ),
              label: Text(_label(i)),
              backgroundColor:
                  added ? cs.secondaryContainer : cs.surfaceContainerHighest,
              labelStyle: TextStyle(
                  color: added ? cs.onSecondaryContainer : null,
                  fontWeight: added ? FontWeight.bold : FontWeight.normal),
              onPressed: added ? null : () => onTap(t),
            );
          }),
        ),
      ],
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: cs.primary),
        const SizedBox(width: 8),
        Text(label,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.bold, color: cs.onSurface)),
      ],
    );
  }
}

// ── Dialog actions ────────────────────────────────────────────────────────────

class _DialogActions extends StatelessWidget {
  final AppLocalizations l10n;
  final VoidCallback onCancel;
  final VoidCallback onCreate;

  const _DialogActions({
    required this.l10n,
    required this.onCancel,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: TextButton(
              onPressed: onCancel,
              child: Text(l10n.cancel),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add, size: 10),
              label: Text(l10n.createProgram),
            ),
          ),
        ],
      ),
    );
  }
}
