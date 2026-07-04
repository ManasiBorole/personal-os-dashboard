sealed class DocumentFormState {
  const DocumentFormState();
}

final class DocumentFormIdle extends DocumentFormState {
  const DocumentFormIdle();
}

final class DocumentFormLoading extends DocumentFormState {
  const DocumentFormLoading();
}

final class DocumentFormSuccess extends DocumentFormState {
  const DocumentFormSuccess({this.message});
  final String? message;
}

final class DocumentFormError extends DocumentFormState {
  const DocumentFormError(this.message);
  final String message;
}

extension DocumentFormStateX on DocumentFormState {
  bool get isLoading => this is DocumentFormLoading;
}
