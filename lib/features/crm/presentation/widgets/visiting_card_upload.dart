import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/core/widgets/buttons/app_button.dart';
import 'package:personal_os_dashboard/features/crm/domain/entities/contact.dart';
import 'package:personal_os_dashboard/features/crm/presentation/providers/crm_provider.dart';

class VisitingCardUpload extends ConsumerStatefulWidget {
  const VisitingCardUpload({
    required this.contact,
    super.key,
  });

  final Contact contact;

  @override
  ConsumerState<VisitingCardUpload> createState() => _VisitingCardUploadState();
}

class _VisitingCardUploadState extends ConsumerState<VisitingCardUpload> {
  bool _uploading = false;

  Future<void> _pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) return;

    setState(() => _uploading = true);
    final success = await ref
        .read(contactFormControllerProvider.notifier)
        .uploadVisitingCard(
          contactId: widget.contact.id,
          bytes: bytes,
          fileName: file.name,
          contentType: _mimeType(file.extension),
        );
    if (mounted) {
      setState(() => _uploading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Visiting card uploaded')),
        );
      }
    }
  }

  String? _mimeType(String? extension) {
    return switch (extension?.toLowerCase()) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'webp' => 'image/webp',
      'gif' => 'image/gif',
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final contact = widget.contact;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLg),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.6)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.badge_outlined),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Visiting Card',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (contact.hasVisitingCard && contact.visitingCardUrl != null)
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(AppSpacing.borderRadiusMd),
                child: contact.visitingCardUrl!.startsWith('http')
                    ? Image.network(
                        contact.visitingCardUrl!,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(theme),
                      )
                    : _placeholder(theme),
              )
            else
              _placeholder(theme),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: contact.hasVisitingCard ? 'Replace card' : 'Upload card',
              icon: Icons.upload_file,
              isLoading: _uploading,
              onPressed: _uploading ? null : _pickAndUpload,
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(ThemeData theme) {
    return Container(
      height: 120,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.contact_page_outlined,
            size: 40,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'No visiting card uploaded',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
