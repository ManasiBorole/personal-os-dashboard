import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/features/crm/domain/entities/contact_params.dart';
import 'package:personal_os_dashboard/features/crm/presentation/providers/crm_provider.dart';

class ContactSearchBar extends ConsumerWidget {
  const ContactSearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(crmSearchQueryProvider);
    final tab = ref.watch(crmListTabProvider);

    return TextField(
      decoration: InputDecoration(
        hintText: tab == CrmListTab.contacts
            ? 'Search contacts...'
            : 'Search companies...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: query.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () =>
                    ref.read(crmSearchQueryProvider.notifier).state = '',
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
        ),
        isDense: true,
      ),
      onChanged: (value) =>
          ref.read(crmSearchQueryProvider.notifier).state = value,
    );
  }
}
