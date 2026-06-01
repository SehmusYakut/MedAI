import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import '../viewmodels/ocr_view_model.dart';
import '../models/question.dart';
import '../l10n/app_localizations.dart';

class QuestionBankScreen extends StatefulWidget {
  const QuestionBankScreen({super.key});

  @override
  State<QuestionBankScreen> createState() => _QuestionBankScreenState();
}

class _QuestionBankScreenState extends State<QuestionBankScreen> {
  String _selectedSubject = 'All';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = context.watch<OCRViewModel>();
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter questions
    final filteredQuestions = _selectedSubject == 'All'
        ? vm.questions
        : vm.getQuestionsBySubject(_selectedSubject);

    // Calculate overall stats
    final allAttempts = vm.questions.expand((q) => q.attempts).toList();
    final totalCorrect = allAttempts.where((a) => a.isCorrect).length;
    final successRate = allAttempts.isEmpty ? 0.0 : totalCorrect / allAttempts.length;

    final totalSeconds = allAttempts.fold<int>(0, (sum, a) => sum + a.timeSpent.inSeconds);
    final avgSeconds = allAttempts.isEmpty ? 0 : (totalSeconds / allAttempts.length).round();
    final avgTimeStr = avgSeconds > 60
        ? '${(avgSeconds / 60).floor()}m ${avgSeconds % 60}s'
        : '${avgSeconds}s';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.questionBank),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background Gradient matching app aesthetics
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [const Color(0xFF0A192F), const Color(0xFF020617)]
                    : [const Color(0xFFF1F5F9), Colors.white],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Performance Statistics Section
                _buildStatsHeader(context, vm.questions.length, successRate, avgTimeStr, cs, isDark, l10n),
                
                // Subject Filter Row
                _buildSubjectFilterRow(context, vm, cs, isDark),

                // Question List
                Expanded(
                  child: filteredQuestions.isEmpty
                      ? _buildEmptyState(context, cs, isDark, l10n)
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          physics: const BouncingScrollPhysics(),
                          itemCount: filteredQuestions.length,
                          itemBuilder: (context, index) {
                            final question = filteredQuestions[index];
                            return _buildQuestionCard(context, question, vm, cs, isDark, l10n);
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader(
    BuildContext context,
    int totalQuestions,
    double successRate,
    String avgTimeStr,
    ColorScheme cs,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF0F1E36), const Color(0xFF060D1A)]
                : [Colors.white, Colors.grey.shade50],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.grey.shade200,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(context, l10n.totalQuestions, totalQuestions.toString(), Icons.folder_zip_outlined, cs.primary, isDark),
            _buildStatItem(
              context,
              l10n.successRate,
              '${(successRate * 100).toStringAsFixed(0)}%',
              Icons.check_circle_outline,
              successRate >= 0.7 ? Colors.green : (successRate > 0.4 ? Colors.orange : cs.primary),
              isDark,
            ),
            _buildStatItem(context, l10n.avgTime, avgTimeStr, Icons.timer_outlined, cs.primary, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? Colors.white60 : Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectFilterRow(
    BuildContext context,
    OCRViewModel vm,
    ColorScheme cs,
    bool isDark,
  ) {
    final subjects = ['All', ...OCRViewModel.medicalSubjects];
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          final subject = subjects[index];
          final isSelected = _selectedSubject == subject;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(subject),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedSubject = subject;
                  });
                }
              },
              backgroundColor: isDark ? const Color(0xFF0F1F2E) : Colors.white,
              selectedColor: cs.primary.withValues(alpha: 0.2),
              side: BorderSide(
                color: isSelected
                    ? cs.primary
                    : (isDark ? Colors.white10 : Colors.grey.shade300),
              ),
              labelStyle: TextStyle(
                color: isSelected
                    ? cs.primary
                    : (isDark ? Colors.white70 : Colors.black87),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ColorScheme cs,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.collections_bookmark_outlined,
              size: 72,
              color: cs.primary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noQuestionsSaved,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noQuestionsSavedDesc,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(
    BuildContext context,
    Question question,
    OCRViewModel vm,
    ColorScheme cs,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final successRate = question.attempts.isEmpty
        ? 0.0
        : question.attempts.where((a) => a.isCorrect).length / question.attempts.length;
    final dateStr = '${question.createdAt.day}/${question.createdAt.month}/${question.createdAt.year}';
    final hasImage = question.imagePath != null && question.imagePath!.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _showQuestionDetailsSheet(context, question, vm, cs, isDark, l10n),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: cs.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                question.subject ?? 'Unassigned',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: cs.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              dateStr,
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          question.text,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (hasImage)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(question.imagePath!),
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 60,
                            height: 60,
                            color: cs.surfaceContainerHighest,
                            child: const Icon(Icons.broken_image_outlined, size: 20),
                          );
                        },
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1, color: Colors.white12),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${question.attempts.length} ${l10n.attempts}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                  if (question.attempts.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: successRate >= 0.7
                            ? Colors.green.withValues(alpha: 0.1)
                            : (successRate > 0.4
                                ? Colors.orange.withValues(alpha: 0.1)
                                : Colors.red.withValues(alpha: 0.1)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${l10n.successRate}: ${(successRate * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: successRate >= 0.7
                              ? Colors.green
                              : (successRate > 0.4 ? Colors.orange : Colors.red),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuestionDetailsSheet(
    BuildContext context,
    Question question,
    OCRViewModel vm,
    ColorScheme cs,
    bool isDark,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _QuestionDetailSheet(
          question: question,
          vm: vm,
          cs: cs,
          isDark: isDark,
          l10n: l10n,
        );
      },
    );
  }
}

class _QuestionDetailSheet extends StatefulWidget {
  final Question question;
  final OCRViewModel vm;
  final ColorScheme cs;
  final bool isDark;
  final AppLocalizations l10n;

  const _QuestionDetailSheet({
    required this.question,
    required this.vm,
    required this.cs,
    required this.isDark,
    required this.l10n,
  });

  @override
  State<_QuestionDetailSheet> createState() => _QuestionDetailSheetState();
}

class _QuestionDetailSheetState extends State<_QuestionDetailSheet> {
  String? _selectedSubject;
  final _timerWatch = Stopwatch();
  late Question _currentQuestion;

  @override
  void initState() {
    super.initState();
    _currentQuestion = widget.question;
    _selectedSubject = _currentQuestion.subject;
    _timerWatch.start();
  }

  void _logAttempt(bool isCorrect) {
    _timerWatch.stop();
    final elapsed = _timerWatch.elapsed;
    final attempt = QuestionAttempt(
      timestamp: DateTime.now(),
      timeSpent: elapsed,
      isCorrect: isCorrect,
    );
    widget.vm.addQuestionAttempt(_currentQuestion.id, attempt);
    
    // Reload state local to sheet
    setState(() {
      final updatedQ = widget.vm.questions.firstWhere((q) => q.id == _currentQuestion.id);
      _currentQuestion = updatedQ;
    });

    _timerWatch.reset();
    _timerWatch.start();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCorrect ? 'Correct! Attempt logged.' : 'Attempt logged.'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _changeSubject(String? newSubject) {
    if (newSubject == null) return;
    setState(() {
      _selectedSubject = newSubject;
      final updatedQ = _currentQuestion.copyWith(subject: newSubject);
      _currentQuestion = updatedQ;
      widget.vm.updateQuestion(updatedQ);
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = _currentQuestion.imagePath != null && _currentQuestion.imagePath!.isNotEmpty;
    final successRate = _currentQuestion.attempts.isEmpty
        ? 0.0
        : _currentQuestion.attempts.where((a) => a.isCorrect).length / _currentQuestion.attempts.length;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: widget.isDark ? const Color(0xFF0F1F2E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
              )
            ],
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: widget.isDark ? Colors.white24 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  children: [
                    // Title/Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.l10n.questionDetails,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () {
                            _confirmDelete();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Scanned Image View
                    if (hasImage) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 250),
                          width: double.infinity,
                          child: Image.file(
                            File(_currentQuestion.imagePath!),
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 120,
                              color: widget.cs.surfaceContainerHighest,
                              child: const Icon(Icons.broken_image_outlined),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Question Text Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: widget.isDark
                            ? const Color(0xFF0A192F).withValues(alpha: 0.4)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: widget.isDark ? Colors.white10 : Colors.grey.shade200,
                        ),
                      ),
                      child: SelectableText(
                        _currentQuestion.text,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Categorization Settings
                    Row(
                      children: [
                        Text(
                          'Subject: ',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedSubject,
                            hint: const Text('Assign subject'),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            items: OCRViewModel.medicalSubjects.map((s) {
                              return DropdownMenuItem(value: s, child: Text(s));
                            }).toList(),
                            onChanged: _changeSubject,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Practice / Stats Logging Section
                    Text(
                      widget.l10n.performance,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _logAttempt(false),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                              foregroundColor: Colors.red,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.cancel_outlined),
                            label: Text(widget.l10n.markIncorrect),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _logAttempt(true),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.green),
                              foregroundColor: Colors.green,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.check_circle_outline),
                            label: Text(widget.l10n.markCorrect),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (_currentQuestion.attempts.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Success Rate: ${(successRate * 100).toStringAsFixed(0)}%'),
                          Text('Attempts: ${_currentQuestion.attempts.length}'),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    // AI Analysis Section
                    if (_currentQuestion.explanation != null && _currentQuestion.explanation!.isNotEmpty) ...[
                      const Divider(height: 24, color: Colors.white12),
                      Row(
                        children: [
                          Icon(Icons.psychology, color: widget.cs.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            widget.l10n.aiAnalysis,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: widget.cs.primary,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      MarkdownBody(
                        data: _currentQuestion.explanation!,
                        selectable: true,
                        styleSheet: _medicalMarkdownStyle(context),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Question?'),
        content: const Text('Are you sure you want to permanently delete this question from your bank?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(widget.l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () {
              widget.vm.deleteQuestion(_currentQuestion.id);
              Navigator.pop(dialogCtx); // Close dialog
              Navigator.pop(context); // Close details sheet
            },
            child: Text(widget.l10n.delete),
          ),
        ],
      ),
    );
  }

  MarkdownStyleSheet _medicalMarkdownStyle(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return MarkdownStyleSheet(
      h2: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: cs.primary, height: 1.8),
      h3: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600, height: 1.6),
      p: tt.bodyMedium?.copyWith(height: 1.6),
      strong: TextStyle(fontWeight: FontWeight.w700, color: cs.error, inherit: true),
      listBullet: tt.bodyMedium?.copyWith(color: cs.primary),
      blockquoteDecoration: BoxDecoration(
        color: cs.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
        border: Border(left: BorderSide(color: cs.error, width: 4)),
      ),
      blockquotePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      tableHead: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurface),
      tableBody: tt.bodySmall,
      tableBorder: TableBorder.all(color: cs.outlineVariant, width: 1, borderRadius: BorderRadius.circular(4)),
      tableCellsDecoration: BoxDecoration(color: cs.surface),
      codeblockDecoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
