import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../l10n/app_localizations.dart';
import '../viewmodels/medicine_program_view_model.dart';
import '../models/medicine_program.dart';
import 'widgets/language_selector.dart';
import 'ocr_screen.dart';
import 'medicine_program_screen.dart';
import 'ask_ai_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 60,
        leading: const _LogoBadge(),
        title: Text(l10n.appTitle),
        actions: const [
          LanguageSelector(),
          _ThemeToggleButton(),
          _ApiKeyButton(),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _TodayScheduleSection(l10n: l10n),
          const SizedBox(height: 20),
          _SectionHeader(label: l10n.tools),
          const SizedBox(height: 12),
          _PrimaryToolsRow(l10n: l10n),
          const SizedBox(height: 12),
          _MedicineProgramsCard(l10n: l10n),
        ],
      ),
    );
  }
}

// ── Logo Badge (Polished circular design with custom medical logo) ──────────────

class _LogoBadge extends StatelessWidget {
  const _LogoBadge();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return RepaintBoundary(
      child: Center(
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      cs.primary.withValues(alpha: 0.9),
                      cs.primary.withValues(alpha: 0.7),
                    ]
                  : [cs.primary, cs.primary.withValues(alpha: 0.8)],
            ),
            boxShadow: [
              BoxShadow(
                color: cs.primary.withValues(alpha: isDark ? 0.4 : 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 1,
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: cs.onPrimary.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: _MedicalLogo(color: cs.onPrimary),
          ),
        ),
      ),
    );
  }
}

// ── Custom Medical Logo (AI + Medical Cross) ──────────────────────────────────

class _MedicalLogo extends StatelessWidget {
  final Color color;
  const _MedicalLogo({required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MedicalLogoPainter(color: color),
      size: const Size.square(48),
    );
  }
}

class _MedicalLogoPainter extends CustomPainter {
  final Color color;
  _MedicalLogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Draw medical cross (plus sign) with rounded corners
    const crossWidth = 6.0;
    const crossLength = 16.0;

    // Vertical bar of cross
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX, centerY),
          width: crossWidth,
          height: crossLength,
        ),
        const Radius.circular(2),
      ),
      paint,
    );

    // Horizontal bar of cross
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX, centerY),
          width: crossLength,
          height: crossWidth,
        ),
        const Radius.circular(2),
      ),
      paint,
    );

    // Draw a subtle circular background for the cross
    canvas.drawCircle(
      Offset(centerX, centerY),
      10.5,
      strokePaint,
    );
  }

  @override
  bool shouldRepaint(_MedicalLogoPainter oldDelegate) =>
      oldDelegate.color != color;
}

// ── Theme Toggle Button ───────────────────────────────────────────────────────

class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Theme.of(context).brightness == Brightness.dark
            ? Icons.light_mode
            : Icons.dark_mode,
      ),
      onPressed: () => MyApp.toggleTheme(context),
      tooltip: 'Toggle Theme',
    );
  }
}

// ── API Key Button ────────────────────────────────────────────────────────────

class _ApiKeyButton extends StatelessWidget {
  const _ApiKeyButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.key_outlined),
      onPressed: () => Navigator.pushNamed(context, '/api-key'),
      tooltip: AppLocalizations.of(context).apiKeyManagement,
    );
  }
}

// ── Today's Schedule ──────────────────────────────────────────────────────────

class _TodayScheduleSection extends StatelessWidget {
  final AppLocalizations l10n;
  const _TodayScheduleSection({required this.l10n});

  static const _dayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  String get _todayName => _dayNames[DateTime.now().weekday - 1];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final programs = context
        .watch<MedicineProgramViewModel>()
        .activePrograms
        .where((p) => p.days.contains(_todayName))
        .toList();

    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [cs.primaryContainer, cs.secondaryContainer],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.today_outlined,
                    color: cs.onPrimaryContainer, size: 20),
                const SizedBox(width: 8),
                Text(
                  l10n.todaySchedule,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.onPrimaryContainer),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (programs.isEmpty)
              Text(
                l10n.noProgramsToday,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onPrimaryContainer.withValues(alpha: 0.7)),
              )
            else
              ...programs.map(
                (p) => _ProgramRow(program: p, cs: cs),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProgramRow extends StatelessWidget {
  final MedicineProgram program;
  final ColorScheme cs;

  const _ProgramRow({required this.program, required this.cs});

  String get _nextReminder {
    if (program.reminderTimes.isEmpty) return '';
    final now = TimeOfDay.now();
    final nowMins = now.hour * 60 + now.minute;
    final sorted = [...program.reminderTimes]
      ..sort((a, b) => (a.hour * 60 + a.minute) - (b.hour * 60 + b.minute));
    final next = sorted.firstWhere(
      (t) => t.hour * 60 + t.minute > nowMins,
      orElse: () => sorted.first,
    );
    return '${next.hour.toString().padLeft(2, '0')}:${next.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: cs.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              program.name,
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: cs.onPrimaryContainer),
            ),
          ),
          if (_nextReminder.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.alarm_outlined, size: 12, color: cs.primary),
                  const SizedBox(width: 4),
                  Text(_nextReminder,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: cs.primary)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context)
          .textTheme
          .labelLarge
          ?.copyWith(color: Theme.of(context).colorScheme.primary),
    );
  }
}

// ── Primary tool cards (OCR + Ask AI) ────────────────────────────────────────

class _PrimaryToolsRow extends StatelessWidget {
  final AppLocalizations l10n;
  const _PrimaryToolsRow({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ToolCard(
            icon: Icons.document_scanner,
            label: l10n.ocrScan,
            description: l10n.scanMedicalQuestion,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OCRScreen()),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ToolCard(
            icon: Icons.psychology_outlined,
            label: l10n.askAI,
            description: l10n.noAiConfigured.split('.').first,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AskAIScreen()),
            ),
          ),
        ),
      ],
    );
  }
}

class _ToolCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;

  const _ToolCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: cs.surfaceContainerHighest,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: cs.onPrimaryContainer, size: 24),
              ),
              const SizedBox(height: 12),
              Text(label,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Medicine Programs card (secondary, full-width) ────────────────────────────

class _MedicineProgramsCard extends StatelessWidget {
  final AppLocalizations l10n;
  const _MedicineProgramsCard({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final totalActive =
        context.watch<MedicineProgramViewModel>().activePrograms.length;

    return Card(
      elevation: 0,
      color: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MedicineProgramScreen()),
        ),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cs.tertiaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.medication_outlined,
                    color: cs.onTertiaryContainer, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.medicinePrograms,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    if (totalActive > 0)
                      Text(
                        '$totalActive ${l10n.activeToday}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.6)),
                      ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: cs.onSurface.withValues(alpha: 0.4)),
            ],
          ),
        ),
      ),
    );
  }
}
