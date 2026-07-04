sealed class TaskFormState {
  const TaskFormState();
}

final class TaskFormIdle extends TaskFormState {
  const TaskFormIdle();
}

final class TaskFormLoading extends TaskFormState {
  const TaskFormLoading();
}

final class TaskFormSuccess extends TaskFormState {
  const TaskFormSuccess({this.message});
  final String? message;
}

final class TaskFormError extends TaskFormState {
  const TaskFormError(this.message);
  final String message;
}

extension TaskFormStateX on TaskFormState {
  bool get isLoading => this is TaskFormLoading;
}
