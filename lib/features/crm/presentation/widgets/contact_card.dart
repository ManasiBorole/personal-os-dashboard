import 'package:flutter/material.dart';

import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/features/crm/domain/entities/contact.dart';

class ContactCard extends StatelessWidget {
  const ContactCard({
    required this.contact,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final Contact contact;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLg),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.6)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    child: Text(
                      contact.firstName.isNotEmpty
                          ? contact.firstName[0].toUpperCase()
                          : '?',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contact.fullName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (contact.companyName != null)
                          Text(
                            contact.companyName!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onEdit();
                        case 'delete':
                          onDelete();
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              if (contact.email != null)
                Row(
                  children: [
                    const Icon(Icons.email_outlined, size: 16),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(child: Text(contact.email!)),
                  ],
                ),
              if (contact.phone != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    const Icon(Icons.phone_outlined, size: 16),
                    const SizedBox(width: AppSpacing.xs),
                    Text(contact.phone!),
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  Chip(
                    label: Text(contact.category.label),
                    visualDensity: VisualDensity.compact,
                  ),
                  if (contact.hasVisitingCard)
                    const Chip(
                      avatar: Icon(Icons.badge_outlined, size: 16),
                      label: Text('Card'),
                      visualDensity: VisualDensity.compact,
                    ),
                  if (contact.followUps.any((f) => f.isOverdue))
                    Chip(
                      label: const Text('Overdue follow-up'),
                      backgroundColor:
                          theme.colorScheme.errorContainer.withValues(alpha: 0.5),
                      visualDensity: VisualDensity.compact,
                    ),
                  ...contact.tags.take(3).map(
                        (tag) => Chip(
                          label: Text(tag),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
