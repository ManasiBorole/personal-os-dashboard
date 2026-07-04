import 'package:flutter/material.dart';
import 'package:personal_os_dashboard/features/documents/domain/entities/document.dart';

/// File type icons and colors for document cards.
abstract final class DocumentTypeStyle {
  static IconData icon(DocumentFileType type) {
    return switch (type) {
      DocumentFileType.pdf => Icons.picture_as_pdf,
      DocumentFileType.image => Icons.image_outlined,
      DocumentFileType.excel => Icons.table_chart_outlined,
      DocumentFileType.word => Icons.description_outlined,
      DocumentFileType.other => Icons.insert_drive_file_outlined,
    };
  }

  static Color color(DocumentFileType type) {
    return switch (type) {
      DocumentFileType.pdf => const Color(0xFFE53935),
      DocumentFileType.image => const Color(0xFF43A047),
      DocumentFileType.excel => const Color(0xFF2E7D32),
      DocumentFileType.word => const Color(0xFF1E88E5),
      DocumentFileType.other => const Color(0xFF757575),
    };
  }
}

String mimeTypeForExtension(String? extension) {
  return switch (extension?.toLowerCase()) {
    'pdf' => 'application/pdf',
    'jpg' || 'jpeg' => 'image/jpeg',
    'png' => 'image/png',
    'gif' => 'image/gif',
    'webp' => 'image/webp',
    'xls' => 'application/vnd.ms-excel',
    'xlsx' =>
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'doc' => 'application/msword',
    'docx' =>
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'txt' => 'text/plain',
    _ => 'application/octet-stream',
  };
}
