import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/features/goals/presentation/providers/goals_provider.dart';

/// Search field for filtering goals by text.
class GoalSearchBar extends ConsumerWidget {
  const GoalSearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(goalsSearchQueryProvider);

    return TextField(
      decoration: InputDecoration(
        hintText: 'Search goals...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: query.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () =>
                    ref.read(goalsSearchQueryProvider.notifier).state = '',
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
        ),
        isDense: true,
      ),
      onChanged: (value) =>
          ref.read(goalsSearchQueryProvider.notifier).state = value,
    );
  }
}
