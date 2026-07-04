sealed class CalendarEventFormState {
  const CalendarEventFormState();
}

final class CalendarEventFormIdle extends CalendarEventFormState {
  const CalendarEventFormIdle();
}

final class CalendarEventFormLoading extends CalendarEventFormState {
  const CalendarEventFormLoading();
}

final class CalendarEventFormSuccess extends CalendarEventFormState {
  const CalendarEventFormSuccess({this.message});
  final String? message;
}

final class CalendarEventFormError extends CalendarEventFormState {
  const CalendarEventFormError(this.message);
  final String message;
}

extension CalendarEventFormStateX on CalendarEventFormState {
  bool get isLoading => this is CalendarEventFormLoading;
}
