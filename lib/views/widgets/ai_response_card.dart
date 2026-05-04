import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/ai_response.dart';
import '../../viewmodels/home_view_model.dart';
import '../../l10n/app_localizations.dart';

class AIResponseCard extends StatefulWidget {
  final AIResponse response;
  final List<MedicalSnippet>? quickReviewSnippets;
  final String? generatedMnemonic;
  final VoidCallback? onGenerateMnemonic;

  const AIResponseCard({
    super.key,
    required this.response,
    this.quickReviewSnippets,
    this.generatedMnemonic,
    this.onGenerateMnemonic,
  });

  @override
  State<AIResponseCard> createState() => _AIResponseCardState();
}

class _AIResponseCardState extends State<AIResponseCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final timestamp =
        '${widget.response.timestamp.hour.toString().padLeft(2, '0')}:'
        '${widget.response.timestamp.minute.toString().padLeft(2, '0')}';

    return RepaintBoundary(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color:
                widget.response.isError ? cs.errorContainer : cs.outlineVariant,
          ),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(
              response: widget.response,
              timestamp: timestamp,
              l10n: l10n,
              cs: cs,
              onGenerateMnemonic: widget.onGenerateMnemonic,
              generatedMnemonic: widget.generatedMnemonic,
              onExpandPressed: _toggleExpanded,
              isExpanded: _isExpanded,
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: widget.response.isError
                  ? _ErrorBody(
                      message: widget.response.response,
                      cs: cs,
                      l10n: l10n,
                    )
                  : _Body(response: widget.response, cs: cs, l10n: l10n),
            ),
            // Quick-Review Snippets Section
            if (widget.quickReviewSnippets != null &&
                widget.quickReviewSnippets!.isNotEmpty &&
                _isExpanded)
              ScaleTransition(
                scale: _controller,
                child: _QuickReviewSnippetsSection(
                  snippets: widget.quickReviewSnippets!,
                  cs: cs,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Header with Mnemonic & Expand Buttons ─────────────────────────────────────

class _Header extends StatelessWidget {
  final AIResponse response;
  final String timestamp;
  final AppLocalizations l10n;
  final ColorScheme cs;
  final VoidCallback? onGenerateMnemonic;
  final String? generatedMnemonic;
  final VoidCallback onExpandPressed;
  final bool isExpanded;

  const _Header({
    required this.response,
    required this.timestamp,
    required this.l10n,
    required this.cs,
    this.onGenerateMnemonic,
    this.generatedMnemonic,
    required this.onExpandPressed,
    required this.isExpanded,
  });

  Color get _bgColor =>
      response.isError ? cs.errorContainer : cs.primaryContainer;
  Color get _fgColor =>
      response.isError ? cs.onErrorContainer : cs.onPrimaryContainer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 4),
              Icon(
                response.isError ? Icons.error_outline : Icons.psychology,
                size: 18,
                color: _fgColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  response.serviceName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _fgColor,
                  ),
                ),
              ),
              Text(
                timestamp,
                style: TextStyle(
                  fontSize: 12,
                  color: _fgColor.withValues(alpha: 0.7),
                ),
              ),
              if (!response.isError) ...[
                const SizedBox(width: 4),
                _ActionButton(
                  icon: Icons.copy,
                  tooltip: l10n.copyResponse,
                  color: _fgColor,
                  onPressed: () => _copyResponse(context, l10n),
                  size: 18,
                ),
                _ActionButton(
                  icon: Icons.menu_book,
                  tooltip: 'Generate Mnemonic',
                  color: _fgColor,
                  onPressed: onGenerateMnemonic,
                  size: 18,
                  hasBadge: generatedMnemonic != null,
                ),
                _ActionButton(
                  icon: isExpanded ? Icons.expand_less : Icons.expand_more,
                  tooltip: isExpanded ? 'Collapse' : 'Expand',
                  color: _fgColor,
                  onPressed: onExpandPressed,
                  size: 18,
                ),
              ],
            ],
          ),
          if (generatedMnemonic != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _fgColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _fgColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lightbulb_outline, size: 14, color: _fgColor),
                    const SizedBox(width: 6),
                    Text(
                      'Mnemonic: $generatedMnemonic',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: _fgColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _copyResponse(BuildContext context, AppLocalizations l10n) {
    Clipboard.setData(ClipboardData(text: response.response));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.copied),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ── Action Button (Copy, Mnemonic, Expand) ───────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback? onPressed;
  final double size;
  final bool hasBadge;

  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.color,
    this.onPressed,
    this.size = 18,
    this.hasBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        IconButton(
          icon: Icon(icon, size: size),
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(),
          tooltip: tooltip,
          color: color,
          onPressed: onPressed,
        ),
        if (hasBadge)
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }
}

// ── Body with Optimized Markdown ──────────────────────────────────────────────

class _Body extends StatelessWidget {
  final AIResponse response;
  final ColorScheme cs;
  final AppLocalizations l10n;

  const _Body({
    required this.response,
    required this.cs,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SelectableText.rich(
          TextSpan(
            children: [
              TextSpan(
                text: response.response,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  final String message;
  final ColorScheme cs;
  final AppLocalizations l10n;

  const _ErrorBody(
      {required this.message, required this.cs, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_outlined, color: cs.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: cs.error),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick-Review Snippets Section ─────────────────────────────────────────────

class _QuickReviewSnippetsSection extends StatelessWidget {
  final List<MedicalSnippet> snippets;
  final ColorScheme cs;

  const _QuickReviewSnippetsSection({
    required this.snippets,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: cs.outlineVariant)),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🚨 Quick Review',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: cs.error,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            ...snippets.map((snippet) => _SnippetCard(
                  snippet: snippet,
                  cs: cs,
                )),
          ],
        ),
      ),
    );
  }
}

// ── Individual Snippet Card ───────────────────────────────────────────────────

class _SnippetCard extends StatelessWidget {
  final MedicalSnippet snippet;
  final ColorScheme cs;

  const _SnippetCard({
    required this.snippet,
    required this.cs,
  });

  Color _getSnippetColor() {
    switch (snippet.type) {
      case 'contraindication':
        return cs.error;
      case 'warning':
        return cs.tertiary;
      default:
        return cs.secondary;
    }
  }

  IconData _getSnippetIcon() {
    switch (snippet.type) {
      case 'contraindication':
        return Icons.block;
      case 'warning':
        return Icons.warning_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getSnippetColor();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: color, width: 4)),
        color: color.withValues(alpha: 0.08),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_getSnippetIcon(), size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  snippet.content,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (snippet.source != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'From: ${snippet.source}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: color.withValues(alpha: 0.6),
                          ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Medical Markdown stylesheet ───────────────────────────────────────────────
// Note: Markdown styling is handled in ocr_screen.dart
