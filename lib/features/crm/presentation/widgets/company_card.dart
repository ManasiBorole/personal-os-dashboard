import 'package:flutter/material.dart';

import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/features/crm/domain/entities/contact.dart';

class CompanyCard extends StatelessWidget {
  const CompanyCard({
    required this.company,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final Company company;
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
                  Expanded(
                    child: Text(
                      company.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
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
              if (company.industry.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  company.industry,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (company.email != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const Icon(Icons.email_outlined, size: 16),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(child: Text(company.email!)),
                  ],
                ),
              ],
              if (company.phone != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    const Icon(Icons.phone_outlined, size: 16),
                    const SizedBox(width: AppSpacing.xs),
                    Text(company.phone!),
                  ],
                ),
              ],
              if (company.tags.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  children: company.tags
                      .take(4)
                      .map(
                        (tag) => Chip(
                          label: Text(tag),
                          visualDensity: VisualDensity.compact,
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
