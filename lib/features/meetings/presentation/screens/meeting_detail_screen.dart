import 'dart:io';

import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:personal_os_dashboard/core/constants/route_constants.dart';
import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/core/utils/date_utils.dart' as app_date;
import 'package:personal_os_dashboard/core/widgets/feedback/error_view.dart';
import 'package:personal_os_dashboard/core/widgets/feedback/loading_view.dart';
import 'package:personal_os_dashboard/features/meetings/domain/entities/meeting.dart';
import 'package:personal_os_dashboard/features/meetings/presentation/providers/meetings_provider.dart';
import 'package:personal_os_dashboard/features/meetings/presentation/widgets/meeting_status_chip.dart';

class MeetingDetailScreen extends ConsumerWidget {
  const MeetingDetailScreen({required this.meetingId, super.key});

  final String meetingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meetingAsync = ref.watch(meetingDetailProvider(meetingId));

    return meetingAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Meeting')),
        body: const LoadingView(message: 'Loading meeting...'),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Meeting')),
        body: ErrorView(message: e.toString()),
      ),
      data: (meeting) => _MeetingDetailBody(meeting: meeting),
    );
  }
}

class _MeetingDetailBody extends ConsumerWidget {
  const _MeetingDetailBody({required this.meeting});

  final Meeting meeting;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(meeting.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Export PDF',
            onPressed: () => _exportPdf(context, ref, meeting),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push(
              RouteConstants.meetingEdit.replaceFirst(':id', meeting.id),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MeetingStatusChip(status: meeting.status),
            const SizedBox(height: AppSpacing.lg),
            _section(
              context,
              'Schedule',
              '${app_date.DateUtils.formatDisplayDateTime(meeting.startTime)}\n'
              '${meeting.durationMinutes} minutes',
              icon: Icons.schedule,
            ),
            if (meeting.location != null)
              _section(
                context,
                'Location',
                meeting.location!,
                icon: Icons.place_outlined,
              ),
            if (meeting.reminderAt != null)
              _section(
                context,
                'Reminder',
                app_date.DateUtils.formatDisplayDateTime(meeting.reminderAt!),
                icon: Icons.notifications_outlined,
              ),
            _section(context, 'Agenda', meeting.agenda, icon: Icons.list_alt),
            _section(
              context,
              'Participants (${meeting.participants.length})',
              meeting.participants.isEmpty
                  ? 'No participants'
                  : meeting.participants
                      .map((p) => '• ${p.name} (${p.role})')
                      .join('\n'),
              icon: Icons.people_outline,
            ),
            _section(context, 'Notes', meeting.notes, icon: Icons.notes),
            _section(
              context,
              'Follow Up',
              meeting.followUp,
              icon: Icons.follow_the_signs_outlined,
            ),
            if (meeting.attachments.isNotEmpty)
              _section(
                context,
                'Attachments',
                meeting.attachments.map((a) => '• ${a.name}').join('\n'),
                icon: Icons.attach_file,
              ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: () => context.push(
                RouteConstants.meetingEdit.replaceFirst(':id', meeting.id),
              ),
              child: const Text('Edit Meeting'),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton(
              onPressed: () => _confirmDelete(context, ref),
              child: const Text('Delete Meeting'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(
    BuildContext context,
    String title,
    String body, {
    required IconData icon,
  }) {
    if (body.trim().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            body.isEmpty ? '—' : body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportPdf(
    BuildContext context,
    WidgetRef ref,
    Meeting meeting,
  ) async {
    final result =
        await ref.read(exportMeetingPdfUseCaseProvider).call(meeting);

    await result.when(
      success: (bytes) async {
        final fileName =
            'meeting-${meeting.id}-${DateTime.now().millisecondsSinceEpoch}.pdf';
        final file = File('${Directory.systemTemp.path}/$fileName');
        await file.writeAsBytes(bytes);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('PDF saved to ${file.path}')),
          );
        }
      },
      onFailure: (f) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Export failed: ${f.message}')),
          );
        }
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
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
      final success = await ref
          .read(meetingFormControllerProvider.notifier)
          .deleteMeeting(meeting.id);
      if (success && context.mounted) {
        context.pop();
      }
    }
  }
}
