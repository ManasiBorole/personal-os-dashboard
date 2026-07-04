import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:personal_os_dashboard/core/constants/route_constants.dart';
import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/core/utils/extensions/context_extensions.dart';
import 'package:personal_os_dashboard/core/widgets/feedback/empty_state_view.dart';
import 'package:personal_os_dashboard/core/widgets/feedback/error_view.dart';
import 'package:personal_os_dashboard/core/widgets/feedback/loading_view.dart';
import 'package:personal_os_dashboard/features/notes/domain/entities/note.dart';
import 'package:personal_os_dashboard/features/notes/domain/entities/note_params.dart';
import 'package:personal_os_dashboard/features/notes/presentation/providers/notes_provider.dart';
import 'package:personal_os_dashboard/features/notes/presentation/widgets/note_card.dart';
import 'package:personal_os_dashboard/features/notes/presentation/widgets/note_filters_bar.dart';
import 'package:personal_os_dashboard/features/notes/presentation/widgets/note_search_bar.dart';

class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesListProvider);
    final pinned = ref.watch(pinnedNotesProvider);
    final unpinned = ref.watch(unpinnedNotesProvider);
    final tab = ref.watch(notesListTabProvider);
    final isDesktop = context.isDesktop;
    final crossAxisCount = isDesktop ? 3 : 2;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteConstants.noteCreate),
        icon: const Icon(Icons.note_add_outlined),
        label: const Text('New Note'),
      ),
      body: notesAsync.when(
        loading: () => const LoadingView(message: 'Loading notes...'),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.read(notesListProvider.notifier).refresh(),
        ),
        data: (_) => RefreshIndicator(
          onRefresh: () => ref.read(notesListProvider.notifier).refresh(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    isDesktop ? AppSpacing.xl : AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!isDesktop)
                        Text(
                          'Notes',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      if (!isDesktop) const SizedBox(height: AppSpacing.lg),
                      const NoteSearchBar(),
                      const SizedBox(height: AppSpacing.md),
                      SegmentedButton<NotesListTab>(
                        segments: [
                          for (final t in NotesListTab.values)
                            ButtonSegment(value: t, label: Text(t.label)),
                        ],
                        selected: {tab},
                        onSelectionChanged: (selection) {
                          ref.read(notesListTabProvider.notifier).state =
                              selection.first;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const NoteFiltersBar(),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '${pinned.length + unpinned.length} note${pinned.length + unpinned.length == 1 ? '' : 's'}',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              if (pinned.isEmpty && unpinned.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyStateView(
                    title: tab == NotesListTab.archived
                        ? 'No archived notes'
                        : 'No notes yet',
                    message: tab == NotesListTab.archived
                        ? 'Archived notes will appear here.'
                        : 'Capture your ideas, checklists, and more.',
                    icon: Icons.note_alt_outlined,
                    actionLabel: 'Create Note',
                    onAction: () => context.push(RouteConstants.noteCreate),
                  ),
                )
              else ...[
                if (pinned.isNotEmpty && tab == NotesListTab.active) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        0,
                        AppSpacing.lg,
                        AppSpacing.sm,
                      ),
                      child: Text(
                        'Pinned',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: AppSpacing.md,
                        crossAxisSpacing: AppSpacing.md,
                        childAspectRatio: 0.85,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => NoteCard(
                          note: pinned[index],
                          onTap: () => _openNote(context, pinned[index].id),
                          onPin: () => _togglePin(ref, pinned[index]),
                          onArchive: () => _toggleArchive(ref, pinned[index]),
                          onDelete: () =>
                              _confirmDelete(context, ref, pinned[index]),
                        ),
                        childCount: pinned.length,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
                ],
                if (unpinned.isNotEmpty && tab == NotesListTab.active)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        0,
                        AppSpacing.lg,
                        AppSpacing.sm,
                      ),
                      child: Text(
                        pinned.isNotEmpty ? 'All notes' : 'Notes',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.xxl,
                  ),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: AppSpacing.md,
                      crossAxisSpacing: AppSpacing.md,
                      childAspectRatio: 0.85,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final note = unpinned[index];
                        return NoteCard(
                          note: note,
                          onTap: () => _openNote(context, note.id),
                          onPin: () => _togglePin(ref, note),
                          onArchive: () => _toggleArchive(ref, note),
                          onDelete: () => _confirmDelete(context, ref, note),
                        );
                      },
                      childCount: unpinned.length,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _openNote(BuildContext context, String id) {
    context.push(RouteConstants.noteEdit.replaceFirst(':id', id));
  }

  Future<void> _togglePin(WidgetRef ref, Note note) async {
    await ref.read(noteFormControllerProvider.notifier).togglePin(
          note.id,
          !note.isPinned,
        );
  }

  Future<void> _toggleArchive(WidgetRef ref, Note note) async {
    await ref.read(noteFormControllerProvider.notifier).toggleArchive(
          note.id,
          !note.isArchived,
        );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Note note,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete note?'),
        content: Text(
          'Permanently delete "${note.title.isEmpty ? 'Untitled' : note.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final success =
        await ref.read(noteFormControllerProvider.notifier).deleteNote(note.id);
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note deleted')),
      );
    }
  }
}
