import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/features/notes/presentation/providers/notes_provider.dart';

class NoteSearchBar extends ConsumerWidget {
  const NoteSearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(notesSearchQueryProvider);

    return TextField(
      decoration: InputDecoration(
        hintText: 'Search notes...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: query.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () =>
                    ref.read(notesSearchQueryProvider.notifier).state = '',
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        isDense: true,
      ),
      onChanged: (value) =>
          ref.read(notesSearchQueryProvider.notifier).state = value,
    );
  }
}
