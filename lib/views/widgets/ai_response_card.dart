import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/ai_response.dart';
import '../../l10n/app_localizations.dart';

class AIResponseCard extends StatefulWidget {
  final AIResponse response;

  const AIResponseCard({
    super.key,
    required this.response,
  });

  @override
  State<AIResponseCard> createState() => _AIResponseCardState();
}

class _AIResponseCardState extends State<AIResponseCard> {
  bool _isExpanded = false;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
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
          ],
        ),
      ),
    );
  }
}

// ── Header with Expand and Copy Buttons ────────────────────────────────────────

class _Header extends StatelessWidget {
  final AIResponse response;
  final String timestamp;
  final AppLocalizations l10n;
  final ColorScheme cs;
  final VoidCallback onExpandPressed;
  final bool isExpanded;

  const _Header({
    required this.response,
    required this.timestamp,
    required this.l10n,
    required this.cs,
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
      child: Row(
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
              icon: isExpanded ? Icons.expand_less : Icons.expand_more,
              tooltip: isExpanded ? 'Collapse' : 'Expand',
              color: _fgColor,
              onPressed: onExpandPressed,
              size: 18,
            ),
          ],
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

// ── Action Button (Copy, Expand) ──────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback? onPressed;
  final double size;

  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.color,
    this.onPressed,
    this.size = 18,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: size),
      padding: const EdgeInsets.all(4),
      constraints: const BoxConstraints(),
      tooltip: tooltip,
      color: color,
      onPressed: onPressed,
    );
  }
}

// ── Body with Rich Content ─────────────────────────────────────────────────────

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
