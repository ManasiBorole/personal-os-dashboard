/// UI state for project form submissions.
sealed class ProjectFormState {
  const ProjectFormState();
}

final class ProjectFormIdle extends ProjectFormState {
  const ProjectFormIdle();
}

final class ProjectFormLoading extends ProjectFormState {
  const ProjectFormLoading();
}

final class ProjectFormSuccess extends ProjectFormState {
  const ProjectFormSuccess({this.message});

  final String? message;
}

final class ProjectFormError extends ProjectFormState {
  const ProjectFormError(this.message);

  final String message;
}

extension ProjectFormStateX on ProjectFormState {
  bool get isLoading => this is ProjectFormLoading;
}
