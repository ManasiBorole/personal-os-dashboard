import 'package:flutter/material.dart';

import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/core/utils/date_utils.dart' as app_date;
import 'package:personal_os_dashboard/features/calendar/domain/entities/calendar_event.dart';
import 'package:personal_os_dashboard/features/calendar/presentation/widgets/calendar_event_tile.dart';

/// Day view showing events for a single date.
class CalendarDayView extends StatelessWidget {
  const CalendarDayView({
    required this.day,
    required this.events,
    required this.onEventTap,
    super.key,
  });

  final DateTime day;
  final List<CalendarEvent> events;
  final ValueChanged<CalendarEvent> onEventTap;

  @override
  Widget build(BuildContext context) {
    final dayEvents = events.where((e) => e.occursOnDay(day)).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    if (dayEvents.isEmpty) {
      return Center(
        child: Text(
          'No events on ${app_date.DateUtils.formatDisplayDate(day)}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: dayEvents.length,
      itemBuilder: (context, index) {
        final event = dayEvents[index];
        return CalendarEventTile(
          event: event,
          onTap: () => onEventTap(event),
        );
      },
    );
  }
}

/// Week view with seven day columns.
class CalendarWeekView extends StatelessWidget {
  const CalendarWeekView({
    required this.weekStart,
    required this.events,
    required this.selectedDay,
    required this.onDayTap,
    required this.onEventTap,
    super.key,
  });

  final DateTime weekStart;
  final List<CalendarEvent> events;
  final DateTime selectedDay;
  final ValueChanged<DateTime> onDayTap;
  final ValueChanged<CalendarEvent> onEventTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = List.generate(
      7,
      (i) => weekStart.add(Duration(days: i)),
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              for (final day in days)
                Expanded(
                  child: InkWell(
                    onTap: () => onDayTap(day),
                    borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: app_date.DateUtils.isSameDay(day, selectedDay)
                            ? theme.colorScheme.primaryContainer
                            : null,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.borderRadiusMd),
                      ),
                      child: Column(
                        children: [
                          Text(
                            app_date.DateUtils.formatDate(day, pattern: 'E'),
                            style: theme.textTheme.labelSmall,
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            '${day.day}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: app_date.DateUtils.isToday(day)
                                  ? theme.colorScheme.primary
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const Divider(height: AppSpacing.lg),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            children: [
              for (final day in days) ...[
                if (events.any((e) => e.occursOnDay(day))) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Text(
                      app_date.DateUtils.formatDisplayDate(day),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  for (final event in events.where((e) => e.occursOnDay(day)))
                    CalendarEventTile(
                      event: event,
                      onTap: () => onEventTap(event),
                    ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Month grid view with event indicators.
class CalendarMonthView extends StatelessWidget {
  const CalendarMonthView({
    required this.month,
    required this.events,
    required this.selectedDay,
    required this.onDayTap,
    required this.onEventTap,
    super.key,
  });

  final DateTime month;
  final List<CalendarEvent> events;
  final DateTime selectedDay;
  final ValueChanged<DateTime> onDayTap;
  final ValueChanged<CalendarEvent> onEventTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final startWeekday = firstDay.weekday;
    final totalCells = ((startWeekday - 1) + daysInMonth + 6) ~/ 7 * 7;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              for (final label in ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'])
                Expanded(
                  child: Center(
                    child: Text(
                      label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.85,
            ),
            itemCount: totalCells,
            itemBuilder: (context, index) {
              final dayOffset = index - (startWeekday - 1);
              if (dayOffset < 0 || dayOffset >= daysInMonth) {
                return const SizedBox.shrink();
              }

              final day = DateTime(month.year, month.month, dayOffset + 1);
              final dayEvents =
                  events.where((e) => e.occursOnDay(day)).toList();
              final isSelected = app_date.DateUtils.isSameDay(day, selectedDay);
              final isToday = app_date.DateUtils.isToday(day);

              return InkWell(
                onTap: () => onDayTap(day),
                borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.4),
                    borderRadius:
                        BorderRadius.circular(AppSpacing.borderRadiusMd),
                    border: isToday
                        ? Border.all(color: theme.colorScheme.primary)
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '${day.day}',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                          color: isToday ? theme.colorScheme.primary : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Expanded(
                        child: ListView(
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            for (final event in dayEvents.take(3))
                              CalendarEventTile(
                                event: event,
                                compact: true,
                                onTap: () => onEventTap(event),
                              ),
                            if (dayEvents.length > 3)
                              Text(
                                '+${dayEvents.length - 3} more',
                                style: theme.textTheme.labelSmall,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
