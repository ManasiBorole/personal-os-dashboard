import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/features/documents/presentation/providers/documents_provider.dart';

class DocumentSearchBar extends ConsumerWidget {
  const DocumentSearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(documentsSearchQueryProvider);

    return TextField(
      decoration: InputDecoration(
        hintText: 'Search documents and folders...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: query.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () =>
                    ref.read(documentsSearchQueryProvider.notifier).state = '',
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        isDense: true,
      ),
      onChanged: (value) =>
          ref.read(documentsSearchQueryProvider.notifier).state = value,
    );
  }
}
