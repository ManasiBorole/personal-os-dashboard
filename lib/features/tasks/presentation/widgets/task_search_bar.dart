import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/features/tasks/presentation/providers/tasks_provider.dart';

/// Search field for filtering tasks by text.
class TaskSearchBar extends ConsumerWidget {
  const TaskSearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(tasksSearchQueryProvider);

    return TextField(
      decoration: InputDecoration(
        hintText: 'Search tasks...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: query.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () =>
                    ref.read(tasksSearchQueryProvider.notifier).state = '',
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
        ),
        isDense: true,
      ),
      onChanged: (value) =>
          ref.read(tasksSearchQueryProvider.notifier).state = value,
    );
  }
}
