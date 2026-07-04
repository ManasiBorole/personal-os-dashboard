import 'package:personal_os_dashboard/core/domain/entities/entity.dart';

/// Note content type.
enum NoteType {
  text('Text'),
  checklist('Checklist');

  const NoteType(this.label);

  final String label;

  static NoteType fromString(String? value) {
    return NoteType.values.firstWhere(
      (t) => t.name == value?.toLowerCase(),
      orElse: () => NoteType.text,
    );
  }
}

/// Note category for organization.
enum NoteCategory {
  personal('Personal'),
  work('Work'),
  ideas('Ideas'),
  meeting('Meeting'),
  research('Research'),
  other('Other');

  const NoteCategory(this.label);

  final String label;

  static NoteCategory fromString(String? value) {
    return NoteCategory.values.firstWhere(
      (c) => c.name == value?.toLowerCase(),
      orElse: () => NoteCategory.other,
    );
  }
}

/// Checklist item within a note.
final class NoteChecklistItem extends Entity {
  const NoteChecklistItem({
    required this.id,
    required this.text,
    required this.isChecked,
  });

  final String id;
  final String text;
  final bool isChecked;

  NoteChecklistItem copyWith({
    String? id,
    String? text,
    bool? isChecked,
  }) {
    return NoteChecklistItem(
      id: id ?? this.id,
      text: text ?? this.text,
      isChecked: isChecked ?? this.isChecked,
    );
  }

  @override
  List<Object?> get props => [id, text, isChecked];
}

/// Image or document attachment on a note.
final class NoteAttachment extends Entity {
  const NoteAttachment({
    required this.id,
    required this.name,
    required this.storagePath,
    required this.publicUrl,
    required this.mimeType,
    required this.isImage,
  });

  final String id;
  final String name;
  final String storagePath;
  final String publicUrl;
  final String mimeType;
  final bool isImage;

  @override
  List<Object?> get props => [id, name, storagePath, publicUrl, mimeType, isImage];
}

/// User note entity.
final class Note extends Entity {
  const Note({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.type,
    required this.checklist,
    required this.category,
    required this.tags,
    required this.images,
    required this.documents,
    required this.isPinned,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String title;
  final String content;
  final NoteType type;
  final List<NoteChecklistItem> checklist;
  final NoteCategory category;
  final List<String> tags;
  final List<NoteAttachment> images;
  final List<NoteAttachment> documents;
  final bool isPinned;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  int get checklistCompleted =>
      checklist.where((item) => item.isChecked).length;

  bool get hasAttachments => images.isNotEmpty || documents.isNotEmpty;

  String get preview {
    if (type == NoteType.checklist) {
      if (checklist.isEmpty) return 'Empty checklist';
      return '$checklistCompleted/${checklist.length} completed';
    }
    final trimmed = content.trim();
    if (trimmed.isEmpty) return 'No content';
    return trimmed.length > 120 ? '${trimmed.substring(0, 120)}…' : trimmed;
  }

  Note copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    NoteType? type,
    List<NoteChecklistItem>? checklist,
    NoteCategory? category,
    List<String>? tags,
    List<NoteAttachment>? images,
    List<NoteAttachment>? documents,
    bool? isPinned,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      checklist: checklist ?? this.checklist,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      images: images ?? this.images,
      documents: documents ?? this.documents,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        content,
        type,
        checklist,
        category,
        tags,
        images,
        documents,
        isPinned,
        isArchived,
        createdAt,
        updatedAt,
      ];
}
