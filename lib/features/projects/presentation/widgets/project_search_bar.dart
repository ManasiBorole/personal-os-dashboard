import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/features/projects/presentation/providers/projects_provider.dart';

class ProjectSearchBar extends ConsumerWidget {
  const ProjectSearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(projectsSearchQueryProvider);

    return TextField(
      decoration: InputDecoration(
        hintText: 'Search projects, clients...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: query.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () =>
                    ref.read(projectsSearchQueryProvider.notifier).state = '',
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
        ),
        isDense: true,
      ),
      onChanged: (v) =>
          ref.read(projectsSearchQueryProvider.notifier).state = v,
    );
  }
}
