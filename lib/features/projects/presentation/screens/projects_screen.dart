import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:personal_os_dashboard/core/constants/route_constants.dart';
import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/core/utils/extensions/context_extensions.dart';
import 'package:personal_os_dashboard/core/widgets/feedback/empty_state_view.dart';
import 'package:personal_os_dashboard/core/widgets/feedback/error_view.dart';
import 'package:personal_os_dashboard/core/widgets/feedback/loading_view.dart';
import 'package:personal_os_dashboard/features/projects/domain/entities/project.dart';
import 'package:personal_os_dashboard/features/projects/domain/entities/project_params.dart';
import 'package:personal_os_dashboard/features/projects/presentation/providers/projects_provider.dart';
import 'package:personal_os_dashboard/features/projects/presentation/widgets/project_card.dart';
import 'package:personal_os_dashboard/features/projects/presentation/widgets/project_search_bar.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsListProvider);
    final filtered = ref.watch(filteredProjectsProvider);
    final filter = ref.watch(projectsFilterProvider);
    final sort = ref.watch(projectsSortProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteConstants.projectCreate),
        icon: const Icon(Icons.add),
        label: const Text('New Project'),
      ),
      body: projectsAsync.when(
        loading: () => const LoadingView(message: 'Loading projects...'),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.read(projectsListProvider.notifier).refresh(),
        ),
        data: (_) => RefreshIndicator(
          onRefresh: () => ref.read(projectsListProvider.notifier).refresh(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!context.isDesktop)
                        Text(
                          'Projects',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      if (!context.isDesktop)
                        const SizedBox(height: AppSpacing.lg),
                      const ProjectSearchBar(),
                      const SizedBox(height: AppSpacing.md),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            FilterChip(
                              label: Text(filter.status?.label ?? 'Status'),
                              selected: filter.status != null,
                              onSelected: (_) => _pickStatus(context, ref),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            if (filter.hasActiveFilters)
                              TextButton(
                                onPressed: () => ref
                                    .read(projectsFilterProvider.notifier)
                                    .state = ProjectFilter.empty,
                                child: const Text('Clear'),
                              ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: DropdownButton<ProjectSortOption>(
                          value: sort,
                          underline: const SizedBox.shrink(),
                          items: [
                            for (final o in ProjectSortOption.values)
                              DropdownMenuItem(value: o, child: Text(o.label)),
                          ],
                          onChanged: (v) {
                            if (v != null) {
                              ref.read(projectsSortProvider.notifier).state =
                                  v;
                            }
                          },
                        ),
                      ),
                      Text(
                        '${filtered.length} project${filtered.length == 1 ? '' : 's'}',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ],
                  ),
                ),
              ),
              if (filtered.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyStateView(
                    title: 'No projects found',
                    message: 'Create a project to manage clients, budget, and team.',
                    icon: Icons.folder_open_outlined,
                    actionLabel: 'New Project',
                    onAction: () => context.push(RouteConstants.projectCreate),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final project = filtered[i];
                        return ProjectCard(
                          project: project,
                          onTap: () => context.push(
                            RouteConstants.projectDetail
                                .replaceFirst(':id', project.id),
                          ),
                          onEdit: () => context.push(
                            RouteConstants.projectEdit
                                .replaceFirst(':id', project.id),
                          ),
                          onDelete: () =>
                              _confirmDelete(context, ref, project),
                        );
                      },
                      childCount: filtered.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 96)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickStatus(BuildContext context, WidgetRef ref) async {
    final selected = await showModalBottomSheet<ProjectStatus>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final s in ProjectStatus.values)
              ListTile(
                title: Text(s.label),
                onTap: () => Navigator.pop(context, s),
              ),
          ],
        ),
      ),
    );
    if (selected != null) {
      ref.read(projectsFilterProvider.notifier).state =
          ProjectFilter(status: selected);
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Project project,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete project?'),
        content: Text('Delete "${project.name}" and all related data?'),
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
    if (ok == true) {
      await ref.read(projectFormControllerProvider.notifier).delete(project.id);
    }
  }
}
