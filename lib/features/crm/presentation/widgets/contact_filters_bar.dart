import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/features/crm/domain/entities/contact.dart';
import 'package:personal_os_dashboard/features/crm/domain/entities/contact_params.dart';
import 'package:personal_os_dashboard/features/crm/presentation/providers/crm_provider.dart';

class ContactFiltersBar extends ConsumerWidget {
  const ContactFiltersBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(contactFilterProvider);
    final sort = ref.watch(contactSortProvider);
    final companies = ref.watch(companiesListProvider).maybeWhen(
          data: (value) => value,
          orElse: () => const <Company>[],
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            DropdownMenu<ContactCategory?>(
              label: const Text('Category'),
              initialSelection: filter.category,
              dropdownMenuEntries: [
                const DropdownMenuEntry(value: null, label: 'All'),
                for (final category in ContactCategory.values)
                  DropdownMenuEntry(
                    value: category,
                    label: category.label,
                  ),
              ],
              onSelected: (value) {
                ref.read(contactFilterProvider.notifier).state =
                    filter.copyWith(
                  category: value,
                  clearCategory: value == null,
                );
              },
            ),
            DropdownMenu<String?>(
              label: const Text('Company'),
              initialSelection: filter.companyId,
              dropdownMenuEntries: [
                const DropdownMenuEntry(value: null, label: 'All'),
                for (final company in companies)
                  DropdownMenuEntry(
                    value: company.id,
                    label: company.name,
                  ),
              ],
              onSelected: (value) {
                ref.read(contactFilterProvider.notifier).state =
                    filter.copyWith(
                  companyId: value,
                  clearCompanyId: value == null,
                );
              },
            ),
            DropdownMenu<ContactSortOption>(
              label: const Text('Sort'),
              initialSelection: sort,
              dropdownMenuEntries: [
                for (final option in ContactSortOption.values)
                  DropdownMenuEntry(
                    value: option,
                    label: option.label,
                  ),
              ],
              onSelected: (value) {
                if (value != null) {
                  ref.read(contactSortProvider.notifier).state = value;
                }
              },
            ),
            if (filter.hasActiveFilters)
              TextButton.icon(
                onPressed: () {
                  ref.read(contactFilterProvider.notifier).state =
                      ContactFilter.empty;
                },
                icon: const Icon(Icons.filter_alt_off),
                label: const Text('Clear filters'),
              ),
          ],
        ),
      ],
    );
  }
}
