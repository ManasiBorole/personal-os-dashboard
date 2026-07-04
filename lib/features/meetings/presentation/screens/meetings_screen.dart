import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:personal_os_dashboard/core/constants/route_constants.dart';
import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/core/utils/extensions/context_extensions.dart';
import 'package:personal_os_dashboard/core/widgets/feedback/empty_state_view.dart';
import 'package:personal_os_dashboard/core/widgets/feedback/error_view.dart';
import 'package:personal_os_dashboard/core/widgets/feedback/loading_view.dart';
import 'package:personal_os_dashboard/features/meetings/domain/entities/meeting.dart';
import 'package:personal_os_dashboard/features/meetings/domain/entities/meeting_params.dart';
import 'package:personal_os_dashboard/features/meetings/presentation/providers/meetings_provider.dart';
import 'package:personal_os_dashboard/features/meetings/presentation/widgets/meeting_card.dart';
import 'package:personal_os_dashboard/features/meetings/presentation/widgets/meeting_search_bar.dart';

class MeetingsScreen extends ConsumerWidget {
  const MeetingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meetingsAsync = ref.watch(meetingsListProvider);
    final filtered = ref.watch(filteredMeetingsProvider);
    final filter = ref.watch(meetingsFilterProvider);
    final isDesktop = context.isDesktop;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteConstants.meetingCreate),
        icon: const Icon(Icons.add),
        label: const Text('Schedule Meeting'),
      ),
      body: meetingsAsync.when(
        loading: () => const LoadingView(message: 'Loading meetings...'),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.read(meetingsListProvider.notifier).refresh(),
        ),
        data: (_) => RefreshIndicator(
          onRefresh: () => ref.read(meetingsListProvider.notifier).refresh(),
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
                          'Meetings',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      if (!isDesktop) const SizedBox(height: AppSpacing.lg),
                      const MeetingSearchBar(),
                      const SizedBox(height: AppSpacing.md),
                      SegmentedButton<MeetingListTab>(
                        segments: [
                          for (final tab in MeetingListTab.values)
                            ButtonSegment(
                              value: tab,
                              label: Text(tab.label),
                            ),
                        ],
                        selected: {filter.tab},
                        onSelectionChanged: (selection) {
                          ref.read(meetingsFilterProvider.notifier).state =
                              filter.copyWith(tab: selection.first);
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '${filtered.length} meeting${filtered.length == 1 ? '' : 's'}',
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
              if (filtered.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyStateView(
                    title: filter.tab == MeetingListTab.upcoming
                        ? 'No upcoming meetings'
                        : 'No meeting history',
                    message: filter.tab == MeetingListTab.upcoming
                        ? 'Schedule your next meeting to get started.'
                        : 'Completed and past meetings will appear here.',
                    icon: Icons.groups_outlined,
                    actionLabel: 'Schedule Meeting',
                    onAction: () => context.push(RouteConstants.meetingCreate),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final meeting = filtered[index];
                        return MeetingCard(
                          meeting: meeting,
                          onTap: () => context.push(
                            RouteConstants.meetingDetail
                                .replaceFirst(':id', meeting.id),
                          ),
                          onEdit: () => context.push(
                            RouteConstants.meetingEdit
                                .replaceFirst(':id', meeting.id),
                          ),
                          onDelete: () =>
                              _confirmDelete(context, ref, meeting),
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

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Meeting meeting,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete meeting?'),
        content: Text('Delete "${meeting.title}"?'),
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
          .read(meetingFormControllerProvider.notifier)
          .deleteMeeting(meeting.id);
    }
  }
}
