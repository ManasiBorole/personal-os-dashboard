sealed class NoteFormState {
  const NoteFormState();
}

final class NoteFormIdle extends NoteFormState {
  const NoteFormIdle();
}

final class NoteFormLoading extends NoteFormState {
  const NoteFormLoading();
}

final class NoteFormSuccess extends NoteFormState {
  const NoteFormSuccess({this.message});
  final String? message;
}

final class NoteFormError extends NoteFormState {
  const NoteFormError(this.message);
  final String message;
}

extension NoteFormStateX on NoteFormState {
  bool get isLoading => this is NoteFormLoading;
}
