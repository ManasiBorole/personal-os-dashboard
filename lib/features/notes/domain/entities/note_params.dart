import 'package:personal_os_dashboard/features/notes/domain/entities/note.dart';

/// Parameters for creating a note.
final class CreateNoteParams {
  const CreateNoteParams({
    required this.title,
    required this.content,
    required this.type,
    required this.checklist,
    required this.category,
    required this.tags,
    required this.images,
    required this.documents,
    this.isPinned = false,
  });

  final String title;
  final String content;
  final String type;
  final List<NoteChecklistItem> checklist;
  final String category;
  final List<String> tags;
  final List<NoteAttachment> images;
  final List<NoteAttachment> documents;
  final bool isPinned;
}

/// Parameters for updating a note.
final class UpdateNoteParams {
  const UpdateNoteParams({
    required this.id,
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
  });

  final String id;
  final String title;
  final String content;
  final String type;
  final List<NoteChecklistItem> checklist;
  final String category;
  final List<String> tags;
  final List<NoteAttachment> images;
  final List<NoteAttachment> documents;
  final bool isPinned;
  final bool isArchived;
}

enum NotesListTab {
  active('Active'),
  archived('Archived');

  const NotesListTab(this.label);

  final String label;
}

final class NoteFilter {
  const NoteFilter({
    this.category,
    this.tag,
  });

  final NoteCategory? category;
  final String? tag;

  static const NoteFilter empty = NoteFilter();

  NoteFilter copyWith({
    NoteCategory? category,
    String? tag,
    bool clearCategory = false,
    bool clearTag = false,
  }) {
    return NoteFilter(
      category: clearCategory ? null : (category ?? this.category),
      tag: clearTag ? null : (tag ?? this.tag),
    );
  }

  bool get hasActiveFilters =>
      category != null || (tag != null && tag!.isNotEmpty);
}
