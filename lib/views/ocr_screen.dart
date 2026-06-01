import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import '../viewmodels/ocr_view_model.dart';
import '../services/usage_limit_service.dart';
import '../l10n/app_localizations.dart';

class OCRScreen extends StatelessWidget {
  const OCRScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = context.watch<OCRViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.ocrScan),
        actions: [
          if (vm.hasSessionText)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: l10n.edit,
              onPressed: () => _showEditDialog(context, vm),
            ),
          if (vm.sessionPhase != OcrSessionPhase.idle)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: l10n.retry,
              onPressed: vm.resetSession,
            ),
        ],
      ),
      body: _OcrBody(vm: vm, l10n: l10n),
      floatingActionButton: _OcrFab(vm: vm, l10n: l10n),
    );
  }

  void _showEditDialog(BuildContext context, OCRViewModel vm) {
    showDialog<void>(
      context: context,
      builder: (_) => _EditTextDialog(
        initialText: vm.sessionText,
        onSave: vm.updateSessionText,
      ),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _OcrBody extends StatelessWidget {
  final OCRViewModel vm;
  final AppLocalizations l10n;

  const _OcrBody({required this.vm, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return switch (vm.sessionPhase) {
      OcrSessionPhase.idle => _IdleState(l10n: l10n),
      OcrSessionPhase.picking ||
      OcrSessionPhase.recognizing =>
        _RecognizingState(vm: vm, l10n: l10n),
      OcrSessionPhase.askingAi => _AiLoadingState(vm: vm, l10n: l10n),
      OcrSessionPhase.complete => _CompleteState(vm: vm, l10n: l10n),
      OcrSessionPhase.error => _ErrorState(vm: vm, l10n: l10n),
    };
  }
}

// ── Idle ──────────────────────────────────────────────────────────────────────

class _IdleState extends StatelessWidget {
  final AppLocalizations l10n;
  const _IdleState({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.document_scanner,
                  size: 56, color: cs.onPrimaryContainer),
            ),
            const SizedBox(height: 24),
            Text(l10n.scanMedicalQuestion,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(l10n.tapToScan,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: cs.onSurface.withValues(alpha: 0.6)),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ── Recognizing (skeleton) ────────────────────────────────────────────────────

class _RecognizingState extends StatelessWidget {
  final OCRViewModel vm;
  final AppLocalizations l10n;
  const _RecognizingState({required this.vm, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image preview placeholder or actual image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: vm.sessionImage != null
                ? Image.file(vm.sessionImage!, fit: BoxFit.contain)
                : const _SkeletonBox(height: 220),
          ),
          const SizedBox(height: 24),
          _SectionLabel(
            icon: Icons.text_snippet_outlined,
            label: l10n.recognizedText,
          ),
          const SizedBox(height: 12),
          const _SkeletonBox(height: 20),
          const SizedBox(height: 8),
          const _SkeletonBox(height: 20, widthFactor: 0.75),
          const SizedBox(height: 8),
          const _SkeletonBox(height: 20, widthFactor: 0.9),
          const SizedBox(height: 8),
          const _SkeletonBox(height: 20, widthFactor: 0.6),
        ],
      ),
    );
  }
}

// ── AI Loading (skeleton responses) ──────────────────────────────────────────

class _AiLoadingState extends StatelessWidget {
  final OCRViewModel vm;
  final AppLocalizations l10n;
  const _AiLoadingState({required this.vm, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (vm.sessionImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(vm.sessionImage!, fit: BoxFit.contain),
            ),
          const SizedBox(height: 16),
          _RecognizedTextCard(vm: vm, l10n: l10n),
          const SizedBox(height: 24),
          _SectionLabel(
            icon: Icons.psychology_outlined,
            label: l10n.analyzingWithAi,
          ),
          const SizedBox(height: 12),
          // Show completed responses as they stream in
          ...vm.sessionAiResponses.entries.map((e) =>
              _AiResponseTile(serviceName: e.key, text: e.value, l10n: l10n)),
          // Skeleton for next pending response
          const SizedBox(height: 8),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SkeletonBox(height: 18, widthFactor: 0.4),
                  SizedBox(height: 16),
                  _SkeletonBox(height: 14),
                  SizedBox(height: 8),
                  _SkeletonBox(height: 14, widthFactor: 0.85),
                  SizedBox(height: 8),
                  _SkeletonBox(height: 14, widthFactor: 0.7),
                  SizedBox(height: 8),
                  _SkeletonBox(height: 14, widthFactor: 0.9),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Complete ──────────────────────────────────────────────────────────────────

class _CompleteState extends StatelessWidget {
  final OCRViewModel vm;
  final AppLocalizations l10n;
  const _CompleteState({required this.vm, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (vm.sessionImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(vm.sessionImage!, fit: BoxFit.contain),
            ),
          const SizedBox(height: 16),
          if (vm.hasSessionText) ...[
            _RecognizedTextCard(vm: vm, l10n: l10n),
            const SizedBox(height: 16),
            if (!vm.hasAiResponses)
              FilledButton.icon(
                onPressed: () async {
                  final limitService = Provider.of<UsageLimitService>(context, listen: false);
                  await limitService.checkAndResetDailyLimit();
                  if (!context.mounted) return;
                  if (limitService.getRemainingRights() <= 0) {
                    Navigator.pushNamed(context, '/premium-paywall');
                  } else {
                    context.read<OCRViewModel>().analyzeWithAI(limitService);
                  }
                },
                icon: const Icon(Icons.psychology),
                label: Text(l10n.askAI),
              ),
          ] else
            _NoTextFound(l10n: l10n),
          if (vm.hasAiResponses) ...[
            const SizedBox(height: 24),
            _SectionLabel(
                icon: Icons.psychology_outlined, label: l10n.aiResponses),
            const SizedBox(height: 12),
            ...vm.sessionAiResponses.entries.map((e) =>
                _AiResponseTile(serviceName: e.key, text: e.value, l10n: l10n)),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ── Error ─────────────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final OCRViewModel vm;
  final AppLocalizations l10n;
  const _ErrorState({required this.vm, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isPremiumRequired = vm.sessionError == 'premium_required';
    final isNoAiServices = vm.sessionError == 'no_ai_services';

    String errorMsg = vm.sessionError ?? '';
    if (isPremiumRequired) {
      errorMsg = 'You have reached your daily free limit. Upgrade to Premium for uninterrupted clinical insights!';
    } else if (isNoAiServices) {
      errorMsg = l10n.noAiConfigured;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPremiumRequired
                  ? Icons.star_rounded
                  : (isNoAiServices ? Icons.info_outline : Icons.error_outline),
              size: 56,
              color: isPremiumRequired ? Colors.amber : cs.error,
            ),
            const SizedBox(height: 16),
            Text(
              errorMsg,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: cs.onSurface.withValues(alpha: 0.7)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: context.read<OCRViewModel>().clearSessionError,
                  child: Text(l10n.retry),
                ),
                if (isPremiumRequired) ...[
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: () => Navigator.pushNamed(context, '/premium-paywall'),
                    child: const Text('Upgrade Now'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable sub-widgets ──────────────────────────────────────────────────────

class _RecognizedTextCard extends StatelessWidget {
  final OCRViewModel vm;
  final AppLocalizations l10n;
  const _RecognizedTextCard({required this.vm, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionLabel(
                icon: Icons.text_snippet_outlined, label: l10n.recognizedText),
            const SizedBox(height: 12),
            SelectableText(
              vm.sessionText,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: cs.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiResponseTile extends StatelessWidget {
  final String serviceName;
  final String text;
  final AppLocalizations l10n;

  const _AiResponseTile({
    required this.serviceName,
    required this.text,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: cs.secondaryContainer,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(Icons.psychology,
                    size: 18, color: cs.onSecondaryContainer),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(serviceName,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: cs.onSecondaryContainer)),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  tooltip: l10n.copyResponse,
                  color: cs.onSecondaryContainer,
                  onPressed: () => _copyToClipboard(context, text, l10n),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: MarkdownBody(
              data: text,
              selectable: true,
              styleSheet: _medicalMarkdownStyle(context),
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(
      BuildContext context, String content, AppLocalizations l10n) {
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.copied),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _NoTextFound extends StatelessWidget {
  final AppLocalizations l10n;
  const _NoTextFound({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cs.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_outlined, color: cs.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(l10n.noTextInImage,
                style: TextStyle(color: cs.onErrorContainer)),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: cs.primary),
        const SizedBox(width: 8),
        Text(label,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(color: cs.primary, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ── FAB ───────────────────────────────────────────────────────────────────────

class _OcrFab extends StatelessWidget {
  final OCRViewModel vm;
  final AppLocalizations l10n;
  const _OcrFab({required this.vm, required this.l10n});

  bool get _disabled =>
      vm.sessionPhase == OcrSessionPhase.recognizing ||
      vm.sessionPhase == OcrSessionPhase.askingAi;

  @override
  Widget build(BuildContext context) {
    final ocrVm = context.read<OCRViewModel>();
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: 'ocr_camera',
          tooltip: l10n.takePhoto,
          onPressed: _disabled
              ? null
              : () => ocrVm.captureAndRecognize(fromCamera: true),
          child: const Icon(Icons.camera_alt),
        ),
        const SizedBox(height: 12),
        FloatingActionButton(
          heroTag: 'ocr_gallery',
          tooltip: l10n.selectImage,
          onPressed: _disabled
              ? null
              : () => ocrVm.captureAndRecognize(fromCamera: false),
          child: const Icon(Icons.photo_library),
        ),
      ],
    );
  }
}

// ── Skeleton loader ───────────────────────────────────────────────────────────

class _SkeletonBox extends StatefulWidget {
  final double height;
  final double widthFactor;

  const _SkeletonBox({
    this.height = 16,
    this.widthFactor = 1.0,
  });

  @override
  State<_SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<_SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.25, end: 0.55)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => FractionallySizedBox(
        widthFactor: widget.widthFactor,
        alignment: Alignment.centerLeft,
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: _anim.value * 2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}

// ── Medical Markdown stylesheet ───────────────────────────────────────────────

MarkdownStyleSheet _medicalMarkdownStyle(BuildContext context) {
  final tt = Theme.of(context).textTheme;
  final cs = Theme.of(context).colorScheme;
  return MarkdownStyleSheet(
    h2: tt.titleMedium?.copyWith(
        fontWeight: FontWeight.bold, color: cs.primary, height: 1.8),
    h3: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600, height: 1.6),
    p: tt.bodyMedium?.copyWith(height: 1.6),
    strong: TextStyle(
        fontWeight: FontWeight.w700,
        color: cs.error,
        inherit: true),
    listBullet: tt.bodyMedium?.copyWith(color: cs.primary),
    blockquoteDecoration: BoxDecoration(
      color: cs.errorContainer.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(4),
      border: Border(left: BorderSide(color: cs.error, width: 4)),
    ),
    blockquotePadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    tableHead: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurface),
    tableBody: tt.bodySmall,
    tableBorder: TableBorder.all(
        color: cs.outlineVariant, width: 1, borderRadius: BorderRadius.circular(4)),
    tableCellsDecoration: BoxDecoration(color: cs.surface),
    codeblockDecoration: BoxDecoration(
      color: cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
    ),
  );
}

// ── Edit dialog ───────────────────────────────────────────────────────────────

class _EditTextDialog extends StatefulWidget {
  final String initialText;
  final ValueChanged<String> onSave;

  const _EditTextDialog({required this.initialText, required this.onSave});

  @override
  State<_EditTextDialog> createState() => _EditTextDialogState();
}

class _EditTextDialogState extends State<_EditTextDialog> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialText);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.recognizedText),
      content: TextField(
        controller: _ctrl,
        maxLines: 10,
        decoration: InputDecoration(hintText: l10n.recognizedText),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel)),
        FilledButton(
          onPressed: () {
            widget.onSave(_ctrl.text);
            Navigator.pop(context);
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}
