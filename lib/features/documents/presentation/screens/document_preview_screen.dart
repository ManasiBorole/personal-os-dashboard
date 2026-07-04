import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/core/widgets/feedback/error_view.dart';
import 'package:personal_os_dashboard/core/widgets/feedback/loading_view.dart';
import 'package:personal_os_dashboard/features/documents/domain/entities/document.dart';
import 'package:personal_os_dashboard/features/documents/presentation/providers/documents_provider.dart';
import 'package:personal_os_dashboard/features/documents/presentation/widgets/document_type_style.dart';

class DocumentPreviewScreen extends ConsumerWidget {
  const DocumentPreviewScreen({required this.documentId, super.key});

  final String documentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentAsync = ref.watch(documentDetailProvider(documentId));
    final bytesAsync = ref.watch(documentPreviewBytesProvider(documentId));

    return documentAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Preview')),
        body: const LoadingView(message: 'Loading document...'),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Preview')),
        body: ErrorView(message: e.toString()),
      ),
      data: (document) => bytesAsync.when(
        loading: () => Scaffold(
          appBar: AppBar(title: Text(document.name)),
          body: const LoadingView(message: 'Loading preview...'),
        ),
        error: (e, _) => Scaffold(
          appBar: AppBar(title: Text(document.name)),
          body: ErrorView(message: e.toString()),
        ),
        data: (bytes) => _PreviewBody(document: document, bytes: bytes),
      ),
    );
  }
}

class _PreviewBody extends ConsumerWidget {
  const _PreviewBody({required this.document, required this.bytes});

  final ManagedDocument document;
  final List<int> bytes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final color = DocumentTypeStyle.color(document.fileType);
    final icon = DocumentTypeStyle.icon(document.fileType);

    return Scaffold(
      appBar: AppBar(
        title: Text(document.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            tooltip: 'Download',
            onPressed: () => _download(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
            onPressed: () => _delete(context, ref),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(AppSpacing.borderRadiusMd),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        document.fileName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${document.fileType.label} · ${document.sizeLabel}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(child: _buildPreview(context)),
        ],
      ),
    );
  }

  Widget _buildPreview(BuildContext context) {
    if (document.canPreviewImage && bytes.isNotEmpty) {
      return InteractiveViewer(
        child: Center(
          child: Image.memory(
            bytes is Uint8List ? bytes as Uint8List : Uint8List.fromList(bytes),
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => _fallbackPreview(context),
          ),
        ),
      );
    }

    if (document.canPreviewExcel && bytes.isNotEmpty) {
      return _ExcelPreview(bytes: bytes);
    }

    return _fallbackPreview(context);
  }

  Widget _fallbackPreview(BuildContext context) {
    final theme = Theme.of(context);
    final color = DocumentTypeStyle.color(document.fileType);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              DocumentTypeStyle.icon(document.fileType),
              size: 72,
              color: color.withValues(alpha: 0.6),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              document.fileType == DocumentFileType.pdf
                  ? 'PDF preview'
                  : document.fileType == DocumentFileType.word
                      ? 'Word document'
                      : 'File preview',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              document.fileType == DocumentFileType.pdf ||
                      document.fileType == DocumentFileType.word
                  ? 'Download the file to open it in your preferred app.'
                  : 'Preview is not available for this file type.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _download(BuildContext context, WidgetRef ref) async {
    final saved = await FilePicker.platform.saveFile(
      fileName: document.fileName,
      bytes: bytes is Uint8List ? bytes as Uint8List : Uint8List.fromList(bytes),
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            saved != null ? 'Saved ${document.fileName}' : 'Download ready',
          ),
        ),
      );
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
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
      Navigator.pop(context);
    }
  }
}

class _ExcelPreview extends StatelessWidget {
  const _ExcelPreview({required this.bytes});

  final List<int> bytes;

  @override
  Widget build(BuildContext context) {
    try {
      final excel = Excel.decodeBytes(
        bytes is Uint8List ? bytes as Uint8List : Uint8List.fromList(bytes),
      );
      final sheetName = excel.tables.keys.firstOrNull;
      if (sheetName == null) {
        return const Center(child: Text('Empty spreadsheet'));
      }
      final sheet = excel.tables[sheetName]!;
      final rows = sheet.rows.take(20).toList();

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            headingRowHeight: 36,
            dataRowMinHeight: 32,
            dataRowMaxHeight: 48,
            columns: List.generate(
              rows.isEmpty ? 1 : rows.first.length.clamp(1, 8),
              (i) => DataColumn(label: Text('Col ${i + 1}')),
            ),
            rows: rows.map((row) {
              return DataRow(
                cells: row.take(8).map((cell) {
                  return DataCell(
                    Text(
                      cell?.value?.toString() ?? '',
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
              );
            }).toList(),
          ),
        ),
      );
    } on Object {
      return const Center(child: Text('Unable to parse Excel file'));
    }
  }
}
