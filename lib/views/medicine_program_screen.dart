import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/medicine_program_view_model.dart';
import '../models/medicine_program.dart';
import '../l10n/app_localizations.dart';
import 'widgets/create_program_dialog.dart';
import 'widgets/medicine_program_card.dart';
import 'program_details_screen.dart';

class MedicineProgramScreen extends StatelessWidget {
  const MedicineProgramScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).medicinePrograms),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => const CreateProgramDialog(),
            ),
          ),
        ],
      ),
      body: Consumer<MedicineProgramViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.programs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.medication_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppLocalizations.of(context).noPrograms,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context).createFirstProgram,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) => const CreateProgramDialog(),
                    ),
                    icon: const Icon(Icons.add),
                    label: Text(AppLocalizations.of(context).createProgram),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              if (viewModel.activePrograms.isNotEmpty) ...[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Active Programs',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final program = viewModel.activePrograms[index];
                      return MedicineProgramCard(
                        program: program,
                        onTap: () => _showProgramDetails(context, program),
                        onToggle: () =>
                            viewModel.toggleProgramStatus(program.id),
                        onDelete: () => _confirmDelete(context, program),
                      );
                    }, childCount: viewModel.activePrograms.length),
                  ),
                ),
              ],
              if (viewModel.programs.where((p) => !p.isActive).isNotEmpty) ...[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.pause_circle,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Inactive Programs',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final program = viewModel.programs
                            .where((p) => !p.isActive)
                            .toList()[index];
                        return MedicineProgramCard(
                          program: program,
                          onTap: () => _showProgramDetails(context, program),
                          onToggle: () =>
                              viewModel.toggleProgramStatus(program.id),
                          onDelete: () => _confirmDelete(context, program),
                        );
                      },
                      childCount:
                          viewModel.programs.where((p) => !p.isActive).length,
                    ),
                  ),
                ),
              ],
              const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => const CreateProgramDialog(),
        ),
        icon: const Icon(Icons.add),
        label: const Text('New Program'),
      ),
    );
  }

  void _showProgramDetails(BuildContext context, MedicineProgram program) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProgramDetailsScreen(program: program),
      ),
    );
  }

  void _confirmDelete(BuildContext context, MedicineProgram program) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Theme.of(context).colorScheme.error),
            const SizedBox(width: 12),
            const Text('Delete Program'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${program.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () {
              context.read<MedicineProgramViewModel>().deleteProgram(
                    program.id,
                  );
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            icon: const Icon(Icons.delete_forever),
            label: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
