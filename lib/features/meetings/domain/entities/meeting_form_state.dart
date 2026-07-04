sealed class MeetingFormState {
  const MeetingFormState();
}

final class MeetingFormIdle extends MeetingFormState {
  const MeetingFormIdle();
}

final class MeetingFormLoading extends MeetingFormState {
  const MeetingFormLoading();
}

final class MeetingFormSuccess extends MeetingFormState {
  const MeetingFormSuccess({this.message});
  final String? message;
}

final class MeetingFormError extends MeetingFormState {
  const MeetingFormError(this.message);
  final String message;
}

extension MeetingFormStateX on MeetingFormState {
  bool get isLoading => this is MeetingFormLoading;
}
