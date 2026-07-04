import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/features/goals/domain/entities/goal.dart';
import 'package:personal_os_dashboard/features/goals/domain/entities/goal_params.dart';
import 'package:personal_os_dashboard/features/goals/domain/entities/goal_sort_option.dart';
import 'package:personal_os_dashboard/features/goals/presentation/providers/goals_provider.dart';

/// Filter and sort controls for the goals list.
class GoalFiltersBar extends ConsumerWidget {
  const GoalFiltersBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(goalsFilterProvider);
    final sort = ref.watch(goalsSortProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FilterChip(
                label: 'Status',
                value: filter.status?.label,
                onTap: () => _pickStatus(context, ref, filter.status),
                onClear: filter.status != null
                    ? () => ref.read(goalsFilterProvider.notifier).state =
                        filter.copyWith(clearStatus: true)
                    : null,
              ),
              const SizedBox(width: AppSpacing.sm),
              _FilterChip(
                label: 'Category',
                value: filter.category?.label,
                onTap: () => _pickCategory(context, ref, filter.category),
                onClear: filter.category != null
                    ? () => ref.read(goalsFilterProvider.notifier).state =
                        filter.copyWith(clearCategory: true)
                    : null,
              ),
              const SizedBox(width: AppSpacing.sm),
              _FilterChip(
                label: 'Priority',
                value: filter.priority?.label,
                onTap: () => _pickPriority(context, ref, filter.priority),
                onClear: filter.priority != null
                    ? () => ref.read(goalsFilterProvider.notifier).state =
                        filter.copyWith(clearPriority: true)
                    : null,
              ),
              if (filter.hasActiveFilters) ...[
                const SizedBox(width: AppSpacing.sm),
                TextButton(
                  onPressed: () => ref.read(goalsFilterProvider.notifier).state =
                      GoalFilter.empty,
                  child: const Text('Clear all'),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Align(
          alignment: Alignment.centerRight,
          child: DropdownButton<GoalSortOption>(
            value: sort,
            underline: const SizedBox.shrink(),
            items: [
              for (final option in GoalSortOption.values)
                DropdownMenuItem(
                  value: option,
                  child: Text(option.label),
                ),
            ],
            onChanged: (value) {
              if (value != null) {
                ref.read(goalsSortProvider.notifier).state = value;
              }
            },
          ),
        ),
      ],
    );
  }

  Future<void> _pickStatus(
    BuildContext context,
    WidgetRef ref,
    GoalStatus? current,
  ) async {
    final selected = await showModalBottomSheet<GoalStatus>(
      context: context,
      builder: (context) => _PickerSheet<GoalStatus>(
        title: 'Filter by status',
        options: GoalStatus.values,
        labelBuilder: (value) => value.label,
        selected: current,
      ),
    );

    if (selected != null) {
      ref.read(goalsFilterProvider.notifier).state =
          ref.read(goalsFilterProvider).copyWith(status: selected);
    }
  }

  Future<void> _pickCategory(
    BuildContext context,
    WidgetRef ref,
    GoalCategory? current,
  ) async {
    final selected = await showModalBottomSheet<GoalCategory>(
      context: context,
      builder: (context) => _PickerSheet<GoalCategory>(
        title: 'Filter by category',
        options: GoalCategory.values,
        labelBuilder: (value) => value.label,
        selected: current,
      ),
    );

    if (selected != null) {
      ref.read(goalsFilterProvider.notifier).state =
          ref.read(goalsFilterProvider).copyWith(category: selected);
    }
  }

  Future<void> _pickPriority(
    BuildContext context,
    WidgetRef ref,
    GoalPriority? current,
  ) async {
    final selected = await showModalBottomSheet<GoalPriority>(
      context: context,
      builder: (context) => _PickerSheet<GoalPriority>(
        title: 'Filter by priority',
        options: GoalPriority.values,
        labelBuilder: (value) => value.label,
        selected: current,
      ),
    );

    if (selected != null) {
      ref.read(goalsFilterProvider.notifier).state =
          ref.read(goalsFilterProvider).copyWith(priority: selected);
    }
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.onTap,
    this.value,
    this.onClear,
  });

  final String label;
  final String? value;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final isActive = value != null;

    return FilterChip(
      label: Text(value ?? label),
      selected: isActive,
      onSelected: (_) => onTap(),
      deleteIcon: onClear != null ? const Icon(Icons.close, size: 16) : null,
      onDeleted: onClear,
    );
  }
}

class _PickerSheet<T> extends StatelessWidget {
  const _PickerSheet({
    required this.title,
    required this.options,
    required this.labelBuilder,
    this.selected,
  });

  final String title;
  final List<T> options;
  final String Function(T value) labelBuilder;
  final T? selected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          for (final option in options)
            ListTile(
              title: Text(labelBuilder(option)),
              trailing: option == selected ? const Icon(Icons.check) : null,
              onTap: () => Navigator.of(context).pop(option),
            ),
        ],
      ),
    );
  }
}
