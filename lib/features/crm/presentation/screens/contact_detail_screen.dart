import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:personal_os_dashboard/core/constants/route_constants.dart';
import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/core/utils/date_utils.dart' as app_date;
import 'package:personal_os_dashboard/core/widgets/feedback/error_view.dart';
import 'package:personal_os_dashboard/core/widgets/feedback/loading_view.dart';
import 'package:personal_os_dashboard/features/crm/domain/entities/contact.dart';
import 'package:personal_os_dashboard/features/crm/presentation/providers/crm_provider.dart';
import 'package:personal_os_dashboard/features/crm/presentation/widgets/visiting_card_upload.dart';

class ContactDetailScreen extends ConsumerWidget {
  const ContactDetailScreen({required this.contactId, super.key});

  final String contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactAsync = ref.watch(contactDetailProvider(contactId));

    return contactAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Contact')),
        body: const LoadingView(message: 'Loading contact...'),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Contact')),
        body: ErrorView(message: e.toString()),
      ),
      data: (contact) => _ContactDetailBody(contact: contact),
    );
  }
}

class _ContactDetailBody extends ConsumerWidget {
  const _ContactDetailBody({required this.contact});

  final Contact contact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(contact.fullName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push(
              RouteConstants.contactEdit.replaceFirst(':id', contact.id),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  child: Text(
                    contact.firstName.isNotEmpty
                        ? contact.firstName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.fullName,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      if (contact.companyName != null)
                        Text(
                          contact.companyName!,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                      Chip(label: Text(contact.category.label)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            if (contact.email != null)
              _section(context, 'Email', contact.email!, Icons.email_outlined),
            if (contact.phone != null)
              _section(context, 'Phone', contact.phone!, Icons.phone_outlined),
            if (contact.address != null)
              _section(
                context,
                'Address',
                contact.address!,
                Icons.location_on_outlined,
              ),
            if (contact.tags.isNotEmpty)
              _section(
                context,
                'Tags',
                contact.tags.join(', '),
                Icons.label_outline,
              ),
            const SizedBox(height: AppSpacing.md),
            VisitingCardUpload(contact: contact),
            const SizedBox(height: AppSpacing.lg),
            _section(
              context,
              'Notes (${contact.notes.length})',
              contact.notes.isEmpty
                  ? 'No notes yet'
                  : contact.notes
                      .map(
                        (n) =>
                            '• ${n.content}\n  ${app_date.DateUtils.formatDisplayDateTime(n.createdAt)}',
                      )
                      .join('\n\n'),
              Icons.sticky_note_2_outlined,
            ),
            _section(
              context,
              'Follow-ups (${contact.followUps.length})',
              contact.followUps.isEmpty
                  ? 'No follow-ups scheduled'
                  : contact.followUps
                      .map((f) {
                        final due = f.dueDate != null
                            ? app_date.DateUtils.formatDisplayDate(f.dueDate!)
                            : 'No due date';
                        return '• ${f.title} [$due · ${f.status.label}]'
                            '${f.notes.isNotEmpty ? '\n  ${f.notes}' : ''}';
                      })
                      .join('\n\n'),
              Icons.task_alt_outlined,
            ),
            _section(
              context,
              'Meeting history (${contact.meetingHistory.length})',
              contact.meetingHistory.isEmpty
                  ? 'No meetings recorded'
                  : contact.meetingHistory
                      .map(
                        (m) =>
                            '• ${m.title} — ${app_date.DateUtils.formatDisplayDate(m.meetingDate)}'
                            '${m.notes.isNotEmpty ? '\n  ${m.notes}' : ''}',
                      )
                      .join('\n\n'),
              Icons.history,
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(
    BuildContext context,
    String title,
    String content,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20),
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
          Text(content),
        ],
      ),
    );
  }
}
