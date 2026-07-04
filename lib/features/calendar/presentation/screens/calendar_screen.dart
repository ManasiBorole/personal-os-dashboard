import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:personal_os_dashboard/core/constants/route_constants.dart';
import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/core/utils/date_utils.dart' as app_date;
import 'package:personal_os_dashboard/core/utils/extensions/context_extensions.dart';
import 'package:personal_os_dashboard/core/widgets/feedback/empty_state_view.dart';
import 'package:personal_os_dashboard/core/widgets/feedback/error_view.dart';
import 'package:personal_os_dashboard/core/widgets/feedback/loading_view.dart';
import 'package:personal_os_dashboard/features/calendar/domain/entities/calendar_event.dart';
import 'package:personal_os_dashboard/features/calendar/domain/entities/calendar_event_params.dart';
import 'package:personal_os_dashboard/features/calendar/presentation/providers/calendar_provider.dart';
import 'package:personal_os_dashboard/features/calendar/presentation/widgets/calendar_event_type_chip.dart';
import 'package:personal_os_dashboard/features/calendar/presentation/widgets/calendar_views.dart';

/// Main calendar screen with day, week, and month views.
class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(calendarEventsProvider);
    final filteredEvents = ref.watch(filteredCalendarEventsProvider);
    final viewMode = ref.watch(calendarViewModeProvider);
    final focusedDay = ref.watch(calendarFocusedDayProvider);
    final isDesktop = context.isDesktop;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(
          '${RouteConstants.calendarCreate}?day=${focusedDay.toIso8601String()}',
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Event'),
      ),
      body: eventsAsync.when(
        loading: () => const LoadingView(message: 'Loading calendar...'),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.read(calendarEventsProvider.notifier).refresh(),
        ),
        data: (_) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
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
                      'Calendar',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  if (!isDesktop) const SizedBox(height: AppSpacing.md),
                  _CalendarHeader(
                    focusedDay: focusedDay,
                    viewMode: viewMode,
                    onPrevious: () =>
                        ref.read(calendarEventsProvider.notifier).goToPrevious(),
                    onNext: () =>
                        ref.read(calendarEventsProvider.notifier).goToNext(),
                    onToday: () =>
                        ref.read(calendarEventsProvider.notifier).goToToday(),
                    onViewModeChanged: (mode) {
                      ref.read(calendarViewModeProvider.notifier).state = mode;
                      ref.read(calendarEventsProvider.notifier).refresh();
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _CalendarTypeFilters(),
                ],
              ),
            ),
            Expanded(
              child: filteredEvents.isEmpty
                  ? EmptyStateView(
                      title: 'No events',
                      message: 'Create an event or adjust your filters.',
                      icon: Icons.event_outlined,
                      actionLabel: 'Add Event',
                      onAction: () => context.push(RouteConstants.calendarCreate),
                    )
                  : switch (viewMode) {
                      CalendarViewMode.day => CalendarDayView(
                          day: focusedDay,
                          events: filteredEvents,
                          onEventTap: (event) =>
                              _showEventDetail(context, ref, event),
                        ),
                      CalendarViewMode.week => CalendarWeekView(
                          weekStart: app_date.DateUtils.startOfWeek(focusedDay),
                          events: filteredEvents,
                          selectedDay: focusedDay,
                          onDayTap: (day) {
                            ref
                                .read(calendarEventsProvider.notifier)
                                .selectDay(day);
                          },
                          onEventTap: (event) =>
                              _showEventDetail(context, ref, event),
                        ),
                      CalendarViewMode.month => CalendarMonthView(
                          month: focusedDay,
                          events: filteredEvents,
                          selectedDay: focusedDay,
                          onDayTap: (day) {
                            ref
                                .read(calendarEventsProvider.notifier)
                                .selectDay(day);
                            ref.read(calendarViewModeProvider.notifier).state =
                                CalendarViewMode.day;
                            ref.read(calendarEventsProvider.notifier).refresh();
                          },
                          onEventTap: (event) =>
                              _showEventDetail(context, ref, event),
                        ),
                    },
            ),
          ],
        ),
      ),
    );
  }

  void _showEventDetail(
    BuildContext context,
    WidgetRef ref,
    CalendarEvent event,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _EventDetailSheet(
        event: event,
        onEdit: event.isReadOnly
            ? null
            : () {
                Navigator.of(context).pop();
                context.push(
                  RouteConstants.calendarEdit.replaceFirst(':id', event.id),
                );
              },
        onDelete: event.isReadOnly
            ? null
            : () async {
                Navigator.of(context).pop();
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete event?'),
                    content: Text('Delete "${event.title}"?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await ref
                      .read(calendarEventFormControllerProvider.notifier)
                      .deleteEvent(event.id);
                }
              },
      ),
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({
    required this.focusedDay,
    required this.viewMode,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
    required this.onViewModeChanged,
  });

  final DateTime focusedDay;
  final CalendarViewMode viewMode;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;
  final ValueChanged<CalendarViewMode> onViewModeChanged;

  String get _title => switch (viewMode) {
        CalendarViewMode.day =>
          app_date.DateUtils.formatDisplayDate(focusedDay),
        CalendarViewMode.week =>
          'Week of ${app_date.DateUtils.formatDisplayDate(app_date.DateUtils.startOfWeek(focusedDay))}',
        CalendarViewMode.month =>
          app_date.DateUtils.formatDate(focusedDay, pattern: 'MMMM yyyy'),
      };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(onPressed: onPrevious, icon: const Icon(Icons.chevron_left)),
            Expanded(
              child: Text(
                _title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            IconButton(onPressed: onNext, icon: const Icon(Icons.chevron_right)),
            TextButton(onPressed: onToday, child: const Text('Today')),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        SegmentedButton<CalendarViewMode>(
          segments: [
            for (final mode in CalendarViewMode.values)
              ButtonSegment(value: mode, label: Text(mode.label)),
          ],
          selected: {viewMode},
          onSelectionChanged: (selection) =>
              onViewModeChanged(selection.first),
        ),
      ],
    );
  }
}

class _CalendarTypeFilters extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(calendarFilterProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final type in CalendarEventType.values)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: FilterChip(
                label: Text(type.label),
                selected: filter.types?.contains(type) ?? false,
                onSelected: (selected) {
                  final current = filter.types ?? <CalendarEventType>{};
                  final updated = Set<CalendarEventType>.from(current);
                  if (selected) {
                    updated.add(type);
                  } else {
                    updated.remove(type);
                  }
                  ref.read(calendarFilterProvider.notifier).state =
                      filter.copyWith(
                    types: updated.isEmpty ? null : updated,
                    clearTypes: updated.isEmpty,
                  );
                },
              ),
            ),
          if (filter.hasActiveFilters)
            TextButton(
              onPressed: () => ref.read(calendarFilterProvider.notifier).state =
                  CalendarEventFilter.empty,
              child: const Text('Clear'),
            ),
        ],
      ),
    );
  }
}

class _EventDetailSheet extends StatelessWidget {
  const _EventDetailSheet({
    required this.event,
    this.onEdit,
    this.onDelete,
  });

  final CalendarEvent event;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xl + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            event.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (event.description.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              event.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          CalendarEventTypeChip(eventType: event.eventType),
          const SizedBox(height: AppSpacing.md),
          Text(
            event.isAllDay
                ? 'All day · ${app_date.DateUtils.formatDisplayDate(event.startTime)}'
                : '${app_date.DateUtils.formatDisplayDateTime(event.startTime)} – ${app_date.DateUtils.formatTime(event.endTime)}',
          ),
          if (event.location != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(Icons.place_outlined, size: 18),
                const SizedBox(width: AppSpacing.sm),
                Text(event.location!),
              ],
            ),
          ],
          if (event.reminderAt != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(Icons.notifications_outlined, size: 18),
                const SizedBox(width: AppSpacing.sm),
                Text(app_date.DateUtils.formatDisplayDateTime(event.reminderAt!)),
              ],
            ),
          ],
          if (event.isReadOnly) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              'Synced from tasks module',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (onEdit != null || onDelete != null) ...[
            const SizedBox(height: AppSpacing.lg),
            if (onEdit != null)
              FilledButton(onPressed: onEdit, child: const Text('Edit Event')),
            if (onDelete != null) ...[
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton(onPressed: onDelete, child: const Text('Delete')),
            ],
          ],
        ],
      ),
    );
  }
}
