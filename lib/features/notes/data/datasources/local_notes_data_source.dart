import 'package:personal_os_dashboard/features/notes/data/datasources/notes_data_source.dart';
import 'package:personal_os_dashboard/features/notes/data/models/note_model.dart';
import 'package:personal_os_dashboard/features/notes/domain/entities/note.dart';
import 'package:personal_os_dashboard/features/notes/domain/entities/note_params.dart';

final class LocalNotesDataSource implements NotesDataSource {
  final Map<String, NoteModel> _notes = {};

  LocalNotesDataSource() {
    _seed();
  }

  void _seed() {
    const userId = 'local-user';
    final now = DateTime.now();

    final notes = [
      NoteModel(
        id: 'note-local-1',
        userId: userId,
        title: 'Q3 Planning Ideas',
        content:
            'Focus on dashboard polish, mobile responsiveness, and user onboarding flow.',
        type: NoteType.text.name,
        checklist: const [],
        category: NoteCategory.work.name,
        tags: const ['planning', 'roadmap'],
        images: const [],
        documents: const [],
        isPinned: true,
        isArchived: false,
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(hours: 2)),
      ),
      NoteModel(
        id: 'note-local-2',
        userId: userId,
        title: 'Weekly Groceries',
        content: '',
        type: NoteType.checklist.name,
        checklist: const [
          NoteChecklistItem(id: 'c-1', text: 'Milk', isChecked: true),
          NoteChecklistItem(id: 'c-2', text: 'Eggs', isChecked: true),
          NoteChecklistItem(id: 'c-3', text: 'Bread', isChecked: false),
          NoteChecklistItem(id: 'c-4', text: 'Coffee beans', isChecked: false),
        ],
        category: NoteCategory.personal.name,
        tags: const ['shopping'],
        images: const [],
        documents: const [],
        isPinned: false,
        isArchived: false,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(hours: 6)),
      ),
      NoteModel(
        id: 'note-local-3',
        userId: userId,
        title: 'Book recommendations',
        content: 'Atomic Habits, Deep Work, The Pragmatic Programmer',
        type: NoteType.text.name,
        checklist: const [],
        category: NoteCategory.research.name,
        tags: const ['books', 'learning'],
        images: const [],
        documents: const [],
        isPinned: false,
        isArchived: false,
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
      NoteModel(
        id: 'note-local-4',
        userId: userId,
        title: 'Old meeting notes',
        content: 'Archived notes from last quarter sync.',
        type: NoteType.text.name,
        checklist: const [],
        category: NoteCategory.meeting.name,
        tags: const ['archive'],
        images: const [],
        documents: const [],
        isPinned: false,
        isArchived: true,
        createdAt: now.subtract(const Duration(days: 60)),
        updatedAt: now.subtract(const Duration(days: 30)),
      ),
    ];

    for (final note in notes) {
      _notes[note.id] = note;
    }
  }

  @override
  Future<List<NoteModel>> getNotes({required String userId}) async {
    return _notes.values
        .where((n) => n.userId == userId || n.userId == 'local-user')
        .toList()
      ..sort((a, b) {
        if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
        return b.updatedAt.compareTo(a.updatedAt);
      });
  }

  @override
  Future<NoteModel> getNoteById({required String id}) async {
    final note = _notes[id];
    if (note == null) throw StateError('Note not found');
    return note;
  }

  @override
  Future<NoteModel> createNote({
    required String userId,
    required CreateNoteParams params,
  }) async {
    final now = DateTime.now();
    final id = 'note-local-${now.microsecondsSinceEpoch}';
    final note = NoteModel(
      id: id,
      userId: userId,
      title: params.title.trim(),
      content: params.content.trim(),
      type: params.type,
      checklist: params.checklist,
      category: params.category,
      tags: params.tags,
      images: params.images,
      documents: params.documents,
      isPinned: params.isPinned,
      isArchived: false,
      createdAt: now,
      updatedAt: now,
    );
    _notes[id] = note;
    return note;
  }

  @override
  Future<NoteModel> updateNote({
    required String userId,
    required UpdateNoteParams params,
  }) async {
    final existing = await getNoteById(id: params.id);
    final updated = NoteModel(
      id: existing.id,
      userId: userId,
      title: params.title.trim(),
      content: params.content.trim(),
      type: params.type,
      checklist: params.checklist,
      category: params.category,
      tags: params.tags,
      images: params.images,
      documents: params.documents,
      isPinned: params.isPinned,
      isArchived: params.isArchived,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
    );
    _notes[updated.id] = updated;
    return updated;
  }

  @override
  Future<void> deleteNote({required String id}) async {
    _notes.remove(id);
  }

  @override
  Future<NoteModel> togglePin({
    required String id,
    required bool isPinned,
  }) async {
    final existing = await getNoteById(id: id);
    final updated = NoteModel(
      id: existing.id,
      userId: existing.userId,
      title: existing.title,
      content: existing.content,
      type: existing.type,
      checklist: existing.checklist,
      category: existing.category,
      tags: existing.tags,
      images: existing.images,
      documents: existing.documents,
      isPinned: isPinned,
      isArchived: existing.isArchived,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
    );
    _notes[updated.id] = updated;
    return updated;
  }

  @override
  Future<NoteModel> toggleArchive({
    required String id,
    required bool isArchived,
  }) async {
    final existing = await getNoteById(id: id);
    final updated = NoteModel(
      id: existing.id,
      userId: existing.userId,
      title: existing.title,
      content: existing.content,
      type: existing.type,
      checklist: existing.checklist,
      category: existing.category,
      tags: existing.tags,
      images: existing.images,
      documents: existing.documents,
      isPinned: isArchived ? false : existing.isPinned,
      isArchived: isArchived,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
    );
    _notes[updated.id] = updated;
    return updated;
  }
}
