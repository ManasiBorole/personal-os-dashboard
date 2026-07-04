import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:personal_os_dashboard/core/constants/route_constants.dart';
import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/core/utils/extensions/context_extensions.dart';
import 'package:personal_os_dashboard/core/widgets/feedback/empty_state_view.dart';
import 'package:personal_os_dashboard/core/widgets/feedback/error_view.dart';
import 'package:personal_os_dashboard/core/widgets/feedback/loading_view.dart';
import 'package:personal_os_dashboard/features/documents/domain/entities/document.dart';
import 'package:personal_os_dashboard/features/documents/domain/entities/document_params.dart';
import 'package:personal_os_dashboard/features/documents/presentation/providers/documents_provider.dart';
import 'package:personal_os_dashboard/features/documents/presentation/widgets/document_search_bar.dart';
import 'package:personal_os_dashboard/features/documents/presentation/widgets/document_tile.dart';
import 'package:personal_os_dashboard/features/documents/presentation/widgets/document_type_style.dart';

class DocumentsScreen extends ConsumerWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final browserAsync = ref.watch(documentsBrowserProvider);
    final filtered = ref.watch(filteredDocumentsBrowserProvider);
    final filter = ref.watch(documentFilterProvider);
    final breadcrumbs = ref.watch(folderBreadcrumbProvider);
    final isDesktop = context.isDesktop;

    return Scaffold(
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: 'new-folder',
            onPressed: () => _createFolder(context, ref),
            child: const Icon(Icons.create_new_folder_outlined),
          ),
          const SizedBox(height: AppSpacing.sm),
          FloatingActionButton.extended(
            heroTag: 'upload',
            onPressed: () => _uploadDocument(context, ref),
            icon: const Icon(Icons.upload_file),
            label: const Text('Upload'),
          ),
        ],
      ),
      body: browserAsync.when(
        loading: () => const LoadingView(message: 'Loading documents...'),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.read(documentsBrowserProvider.notifier).refresh(),
        ),
        data: (_) => RefreshIndicator(
          onRefresh: () => ref.read(documentsBrowserProvider.notifier).refresh(),
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
                          'Documents',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      if (!isDesktop) const SizedBox(height: AppSpacing.lg),
                      const DocumentSearchBar(),
                      const SizedBox(height: AppSpacing.md),
                      _BreadcrumbBar(breadcrumbs: breadcrumbs),
                      const SizedBox(height: AppSpacing.md),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (final type in DocumentFilterType.values) ...[
                              FilterChip(
                                label: Text(type.label),
                                selected: filter == type,
                                onSelected: (_) {
                                  ref
                                      .read(documentFilterProvider.notifier)
                                      .state = type;
                                },
                              ),
                              const SizedBox(width: AppSpacing.sm),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (filtered.folders.isEmpty && filtered.documents.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyStateView(
                    title: 'No documents here',
                    message: 'Upload files or create a folder to get started.',
                    icon: Icons.folder_open_outlined,
                    actionLabel: 'Upload file',
                    onAction: () => _uploadDocument(context, ref),
                  ),
                )
              else ...[
                if (filtered.folders.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final folder = filtered.folders[index];
                          return FolderTile(
                            folder: folder,
                            onTap: () => ref
                                .read(documentsBrowserProvider.notifier)
                                .navigateToFolder(folder),
                            onDelete: () =>
                                _confirmDeleteFolder(context, ref, folder),
                          );
                        },
                        childCount: filtered.folders.length,
                      ),
                    ),
                  ),
                if (filtered.documents.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.sm,
                      AppSpacing.lg,
                      AppSpacing.xxl,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final document = filtered.documents[index];
                          return DocumentTile(
                            document: document,
                            onTap: () => context.push(
                              RouteConstants.documentPreview
                                  .replaceFirst(':id', document.id),
                            ),
                            onPreview: () => context.push(
                              RouteConstants.documentPreview
                                  .replaceFirst(':id', document.id),
                            ),
                            onDownload: () =>
                                _downloadDocument(context, ref, document),
                            onDelete: () =>
                                _confirmDeleteDocument(context, ref, document),
                          );
                        },
                        childCount: filtered.documents.length,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createFolder(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New folder'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Folder name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty || !context.mounted) return;

    final success = await ref.read(documentFormControllerProvider.notifier).createFolder(
          CreateFolderParams(
            name: name,
            parentId: ref.read(currentFolderIdProvider),
          ),
        );
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Folder created')),
      );
    }
  }

  Future<void> _uploadDocument(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'jpg',
        'jpeg',
        'png',
        'gif',
        'webp',
        'xls',
        'xlsx',
        'doc',
        'docx',
      ],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) return;

    final fileType = DocumentFileType.fromFileName(file.name);
    final displayName = file.name.contains('.')
        ? file.name.substring(0, file.name.lastIndexOf('.'))
        : file.name;

    final success = await ref
        .read(documentFormControllerProvider.notifier)
        .uploadDocument(
          UploadDocumentParams(
            name: displayName,
            folderId: ref.read(currentFolderIdProvider),
            fileName: file.name,
            bytes: bytes,
            mimeType: mimeTypeForExtension(file.extension),
            fileType: fileType.name,
          ),
        );

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${file.name} uploaded')),
      );
    }
  }

  Future<void> _downloadDocument(
    BuildContext context,
    WidgetRef ref,
    ManagedDocument document,
  ) async {
    final bytes = await ref
        .read(documentFormControllerProvider.notifier)
        .downloadDocument(document);
    if (bytes == null || !context.mounted) return;

    final saved = await FilePicker.platform.saveFile(
      fileName: document.fileName,
      bytes: bytes,
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            saved != null
                ? 'Saved ${document.fileName}'
                : 'Downloaded ${document.fileName}',
          ),
        ),
      );
    }
  }

  Future<void> _confirmDeleteFolder(
    BuildContext context,
    WidgetRef ref,
    DocumentFolder folder,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete folder?'),
        content: Text('Delete "${folder.name}" and its contents?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final success = await ref
        .read(documentFormControllerProvider.notifier)
        .deleteFolder(folder.id);
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Folder deleted')),
      );
    }
  }

  Future<void> _confirmDeleteDocument(
    BuildContext context,
    WidgetRef ref,
    ManagedDocument document,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete document?'),
        content: Text('Permanently delete "${document.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final success = await ref
        .read(documentFormControllerProvider.notifier)
        .deleteDocument(document);
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document deleted')),
      );
    }
  }
}

class _BreadcrumbBar extends ConsumerWidget {
  const _BreadcrumbBar({required this.breadcrumbs});

  final List<DocumentFolder> breadcrumbs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.xs,
      children: [
        InkWell(
          onTap: () =>
              ref.read(documentsBrowserProvider.notifier).navigateToBreadcrumb(-1),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.home_outlined, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 4),
              Text(
                'Home',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        for (var i = 0; i < breadcrumbs.length; i++) ...[
          Icon(Icons.chevron_right, size: 18, color: theme.colorScheme.outline),
          InkWell(
            onTap: () => ref
                .read(documentsBrowserProvider.notifier)
                .navigateToBreadcrumb(i),
            child: Text(
              breadcrumbs[i].name,
              style: theme.textTheme.labelLarge?.copyWith(
                color: i == breadcrumbs.length - 1
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.primary,
                fontWeight:
                    i == breadcrumbs.length - 1 ? FontWeight.w600 : null,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
