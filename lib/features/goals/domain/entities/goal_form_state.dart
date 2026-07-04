/// UI state for goal form submissions.
sealed class GoalFormState {
  const GoalFormState();
}

final class GoalFormIdle extends GoalFormState {
  const GoalFormIdle();
}

final class GoalFormLoading extends GoalFormState {
  const GoalFormLoading();
}

final class GoalFormSuccess extends GoalFormState {
  const GoalFormSuccess({this.message});

  final String? message;
}

final class GoalFormError extends GoalFormState {
  const GoalFormError(this.message);

  final String message;
}

extension GoalFormStateX on GoalFormState {
  bool get isLoading => this is GoalFormLoading;

  bool get isSuccess => this is GoalFormSuccess;

  bool get isError => this is GoalFormError;
}
