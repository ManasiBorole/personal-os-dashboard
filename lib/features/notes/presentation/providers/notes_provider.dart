import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:personal_os_dashboard/core/di/core_providers.dart';
import 'package:personal_os_dashboard/core/di/service_locator.dart';
import 'package:personal_os_dashboard/core/error/error_handler.dart';
import 'package:personal_os_dashboard/features/auth/presentation/providers/auth_provider.dart';
import 'package:personal_os_dashboard/features/notes/domain/entities/note.dart';
import 'package:personal_os_dashboard/features/notes/domain/entities/note_form_state.dart';
import 'package:personal_os_dashboard/features/notes/domain/entities/note_params.dart';
import 'package:personal_os_dashboard/features/notes/domain/usecases/note_usecases.dart';

final getNotesUseCaseProvider = Provider<GetNotesUseCase>((ref) {
  return GetNotesUseCase(ref.watch(notesRepositoryProvider));
});

final getNoteByIdUseCaseProvider = Provider<GetNoteByIdUseCase>((ref) {
  return GetNoteByIdUseCase(ref.watch(notesRepositoryProvider));
});

final createNoteUseCaseProvider = Provider<CreateNoteUseCase>((ref) {
  return CreateNoteUseCase(ref.watch(notesRepositoryProvider));
});

final updateNoteUseCaseProvider = Provider<UpdateNoteUseCase>((ref) {
  return UpdateNoteUseCase(ref.watch(notesRepositoryProvider));
});

final deleteNoteUseCaseProvider = Provider<DeleteNoteUseCase>((ref) {
  return DeleteNoteUseCase(ref.watch(notesRepositoryProvider));
});

final toggleNotePinUseCaseProvider = Provider<ToggleNotePinUseCase>((ref) {
  return ToggleNotePinUseCase(ref.watch(notesRepositoryProvider));
});

final toggleNoteArchiveUseCaseProvider =
    Provider<ToggleNoteArchiveUseCase>((ref) {
  return ToggleNoteArchiveUseCase(ref.watch(notesRepositoryProvider));
});

final uploadNoteAttachmentUseCaseProvider =
    Provider<UploadNoteAttachmentUseCase>((ref) {
  return UploadNoteAttachmentUseCase(ref.watch(notesRepositoryProvider));
});

final notesSearchQueryProvider = StateProvider<String>((ref) => '');

final notesListTabProvider =
    StateProvider<NotesListTab>((ref) => NotesListTab.active);

final noteFilterProvider =
    StateProvider<NoteFilter>((ref) => NoteFilter.empty);

final notesListProvider =
    AsyncNotifierProvider<NotesListController, List<Note>>(
  NotesListController.new,
);

class NotesListController extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() => _load();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<List<Note>> _load() async {
    final userId = ref.read(currentUserProvider)?.id ?? 'local-user';
    final result = await ref.read(getNotesUseCaseProvider).call(userId);
    return result.when(
      success: (notes) => notes,
      onFailure: (f) => throw sl<ErrorHandler>().getUserMessage(f),
    );
  }
}

final filteredNotesProvider = Provider<List<Note>>((ref) {
  final notes = ref.watch(notesListProvider).maybeWhen(
        data: (value) => value,
        orElse: () => const <Note>[],
      );
  final query = ref.watch(notesSearchQueryProvider).trim().toLowerCase();
  final filter = ref.watch(noteFilterProvider);
  final tab = ref.watch(notesListTabProvider);

  var result = notes.where((note) {
    final matchesTab = tab == NotesListTab.archived
        ? note.isArchived
        : !note.isArchived;

    final matchesSearch = query.isEmpty ||
        note.title.toLowerCase().contains(query) ||
        note.content.toLowerCase().contains(query) ||
        note.tags.any((t) => t.toLowerCase().contains(query)) ||
        note.checklist.any((c) => c.text.toLowerCase().contains(query));

    final matchesCategory =
        filter.category == null || note.category == filter.category;

    return matchesTab && matchesSearch && matchesCategory;
  }).toList();

  result = List<Note>.from(result)
    ..sort((a, b) {
      if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });

  return result;
});

final pinnedNotesProvider = Provider<List<Note>>((ref) {
  final tab = ref.watch(notesListTabProvider);
  if (tab == NotesListTab.archived) return const [];
  return ref
      .watch(filteredNotesProvider)
      .where((note) => note.isPinned)
      .toList();
});

final unpinnedNotesProvider = Provider<List<Note>>((ref) {
  final filtered = ref.watch(filteredNotesProvider);
  final tab = ref.watch(notesListTabProvider);
  if (tab == NotesListTab.archived) return filtered;
  return filtered.where((note) => !note.isPinned).toList();
});

final noteFormControllerProvider =
    NotifierProvider<NoteFormController, NoteFormState>(
  NoteFormController.new,
);

class NoteFormController extends Notifier<NoteFormState> {
  @override
  NoteFormState build() => const NoteFormIdle();

  Future<bool> createNote(CreateNoteParams params) async {
    state = const NoteFormLoading();
    final userId = ref.read(currentUserProvider)?.id ?? 'local-user';
    final result = await ref.read(createNoteUseCaseProvider).call(
          CreateNoteRequest(userId: userId, note: params),
        );
    return result.when(
      success: (_) {
        state = const NoteFormSuccess(message: 'Note created.');
        ref.invalidate(notesListProvider);
        return true;
      },
      onFailure: (f) {
        state = NoteFormError(sl<ErrorHandler>().getUserMessage(f));
        return false;
      },
    );
  }

  Future<bool> updateNote(UpdateNoteParams params) async {
    state = const NoteFormLoading();
    final userId = ref.read(currentUserProvider)?.id ?? 'local-user';
    final result = await ref.read(updateNoteUseCaseProvider).call(
          UpdateNoteRequest(userId: userId, note: params),
        );
    return result.when(
      success: (_) {
        state = const NoteFormSuccess(message: 'Note updated.');
        ref.invalidate(notesListProvider);
        ref.invalidate(noteDetailProvider(params.id));
        return true;
      },
      onFailure: (f) {
        state = NoteFormError(sl<ErrorHandler>().getUserMessage(f));
        return false;
      },
    );
  }

  Future<bool> deleteNote(String id) async {
    state = const NoteFormLoading();
    final result = await ref.read(deleteNoteUseCaseProvider).call(id);
    return result.when(
      success: (_) {
        state = const NoteFormSuccess(message: 'Note deleted.');
        ref.invalidate(notesListProvider);
        return true;
      },
      onFailure: (f) {
        state = NoteFormError(sl<ErrorHandler>().getUserMessage(f));
        return false;
      },
    );
  }

  Future<bool> togglePin(String id, bool isPinned) async {
    final result = await ref.read(toggleNotePinUseCaseProvider).call(
          ToggleNotePinRequest(id: id, isPinned: isPinned),
        );
    return result.when(
      success: (_) {
        ref.invalidate(notesListProvider);
        ref.invalidate(noteDetailProvider(id));
        return true;
      },
      onFailure: (f) {
        state = NoteFormError(sl<ErrorHandler>().getUserMessage(f));
        return false;
      },
    );
  }

  Future<bool> toggleArchive(String id, bool isArchived) async {
    final result = await ref.read(toggleNoteArchiveUseCaseProvider).call(
          ToggleNoteArchiveRequest(id: id, isArchived: isArchived),
        );
    return result.when(
      success: (_) {
        ref.invalidate(notesListProvider);
        ref.invalidate(noteDetailProvider(id));
        return true;
      },
      onFailure: (f) {
        state = NoteFormError(sl<ErrorHandler>().getUserMessage(f));
        return false;
      },
    );
  }

  Future<NoteAttachment?> uploadAttachment({
    required String noteId,
    required List<int> bytes,
    required String fileName,
    required bool isImage,
    String? contentType,
  }) async {
    final userId = ref.read(currentUserProvider)?.id ?? 'local-user';
    final result = await ref.read(uploadNoteAttachmentUseCaseProvider).call((
      userId: userId,
      noteId: noteId,
      bytes: bytes is Uint8List ? bytes : Uint8List.fromList(bytes),
      fileName: fileName,
      isImage: isImage,
      contentType: contentType,
    ));
    return result.when(
      success: (attachment) => attachment,
      onFailure: (f) {
        state = NoteFormError(sl<ErrorHandler>().getUserMessage(f));
        return null;
      },
    );
  }

  void clearStatus() => state = const NoteFormIdle();
}

final noteDetailProvider = FutureProvider.family<Note, String>((ref, id) async {
  final result = await ref.read(getNoteByIdUseCaseProvider).call(id);
  return result.when(
    success: (note) => note,
    onFailure: (f) => throw sl<ErrorHandler>().getUserMessage(f),
  );
});
