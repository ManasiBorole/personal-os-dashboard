import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/features/meetings/presentation/providers/meetings_provider.dart';

class MeetingSearchBar extends ConsumerWidget {
  const MeetingSearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(meetingsSearchQueryProvider);

    return TextField(
      decoration: InputDecoration(
        hintText: 'Search meetings...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: query.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () =>
                    ref.read(meetingsSearchQueryProvider.notifier).state = '',
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
        ),
        isDense: true,
      ),
      onChanged: (value) =>
          ref.read(meetingsSearchQueryProvider.notifier).state = value,
    );
  }
}
