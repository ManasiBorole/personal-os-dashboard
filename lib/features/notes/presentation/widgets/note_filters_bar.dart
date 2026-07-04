import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/features/notes/domain/entities/note.dart';
import 'package:personal_os_dashboard/features/notes/domain/entities/note_params.dart';
import 'package:personal_os_dashboard/features/notes/presentation/providers/notes_provider.dart';

class NoteFiltersBar extends ConsumerWidget {
  const NoteFiltersBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(noteFilterProvider);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          FilterChip(
            label: const Text('All'),
            selected: filter.category == null,
            onSelected: (_) {
              ref.read(noteFilterProvider.notifier).state =
                  filter.copyWith(clearCategory: true);
            },
          ),
          const SizedBox(width: AppSpacing.sm),
          for (final category in NoteCategory.values) ...[
            FilterChip(
              label: Text(category.label),
              selected: filter.category == category,
              selectedColor:
                  theme.colorScheme.primaryContainer.withValues(alpha: 0.8),
              onSelected: (selected) {
                ref.read(noteFilterProvider.notifier).state = filter.copyWith(
                  category: selected ? category : null,
                  clearCategory: !selected,
                );
              },
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          if (filter.hasActiveFilters)
            ActionChip(
              avatar: const Icon(Icons.filter_alt_off, size: 18),
              label: const Text('Clear'),
              onPressed: () {
                ref.read(noteFilterProvider.notifier).state = NoteFilter.empty;
              },
            ),
        ],
      ),
    );
  }
}
