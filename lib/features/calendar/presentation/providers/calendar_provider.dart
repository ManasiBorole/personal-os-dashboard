import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:personal_os_dashboard/core/di/core_providers.dart';
import 'package:personal_os_dashboard/core/di/service_locator.dart';
import 'package:personal_os_dashboard/core/error/error_handler.dart';
import 'package:personal_os_dashboard/core/utils/date_utils.dart' as app_date;
import 'package:personal_os_dashboard/features/auth/presentation/providers/auth_provider.dart';
import 'package:personal_os_dashboard/features/calendar/domain/entities/calendar_event.dart';
import 'package:personal_os_dashboard/features/calendar/domain/entities/calendar_event_form_state.dart';
import 'package:personal_os_dashboard/features/calendar/domain/entities/calendar_event_params.dart';
import 'package:personal_os_dashboard/features/calendar/domain/usecases/calendar_usecases.dart';
import 'package:personal_os_dashboard/features/dashboard/presentation/providers/dashboard_provider.dart';

final getCalendarEventsUseCaseProvider =
    Provider<GetCalendarEventsUseCase>((ref) {
  return GetCalendarEventsUseCase(ref.watch(calendarRepositoryProvider));
});

final getCalendarEventByIdUseCaseProvider =
    Provider<GetCalendarEventByIdUseCase>((ref) {
  return GetCalendarEventByIdUseCase(ref.watch(calendarRepositoryProvider));
});

final createCalendarEventUseCaseProvider =
    Provider<CreateCalendarEventUseCase>((ref) {
  return CreateCalendarEventUseCase(ref.watch(calendarRepositoryProvider));
});

final updateCalendarEventUseCaseProvider =
    Provider<UpdateCalendarEventUseCase>((ref) {
  return UpdateCalendarEventUseCase(ref.watch(calendarRepositoryProvider));
});

final deleteCalendarEventUseCaseProvider =
    Provider<DeleteCalendarEventUseCase>((ref) {
  return DeleteCalendarEventUseCase(ref.watch(calendarRepositoryProvider));
});

final calendarViewModeProvider = StateProvider<CalendarViewMode>(
  (ref) => CalendarViewMode.month,
);

final calendarFocusedDayProvider = StateProvider<DateTime>(
  (ref) => app_date.DateUtils.startOfDay(DateTime.now()),
);

final calendarFilterProvider = StateProvider<CalendarEventFilter>(
  (ref) => CalendarEventFilter.empty,
);

final calendarEventsProvider =
    AsyncNotifierProvider<CalendarEventsController, List<CalendarEvent>>(
  CalendarEventsController.new,
);

class CalendarEventsController extends AsyncNotifier<List<CalendarEvent>> {
  @override
  Future<List<CalendarEvent>> build() => _loadEvents();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadEvents);
  }

  Future<List<CalendarEvent>> _loadEvents() async {
    final userId = ref.read(currentUserProvider)?.id ?? 'local-user';
    final focusedDay = ref.read(calendarFocusedDayProvider);
    final viewMode = ref.read(calendarViewModeProvider);

    final range = _rangeForView(focusedDay, viewMode);
    final result = await ref.read(getCalendarEventsUseCaseProvider).call(
          (
            userId: userId,
            rangeStart: range.$1,
            rangeEnd: range.$2,
          ),
        );

    return result.when(
      success: (events) => events,
      onFailure: (failure) {
        throw sl<ErrorHandler>().getUserMessage(failure);
      },
    );
  }

  (DateTime, DateTime) _rangeForView(DateTime day, CalendarViewMode mode) {
    return switch (mode) {
      CalendarViewMode.day => (
          app_date.DateUtils.startOfDay(day),
          app_date.DateUtils.endOfDay(day),
        ),
      CalendarViewMode.week => (
          app_date.DateUtils.startOfWeek(day),
          app_date.DateUtils.endOfWeek(day),
        ),
      CalendarViewMode.month => (
          app_date.DateUtils.startOfMonth(day),
          app_date.DateUtils.endOfMonth(day),
        ),
    };
  }

  void goToToday() {
    ref.read(calendarFocusedDayProvider.notifier).state =
        app_date.DateUtils.startOfDay(DateTime.now());
    refresh();
  }

  void goToPrevious() {
    final mode = ref.read(calendarViewModeProvider);
    final current = ref.read(calendarFocusedDayProvider);
    ref.read(calendarFocusedDayProvider.notifier).state = switch (mode) {
      CalendarViewMode.day => current.subtract(const Duration(days: 1)),
      CalendarViewMode.week => current.subtract(const Duration(days: 7)),
      CalendarViewMode.month => DateTime(current.year, current.month - 1, 1),
    };
    refresh();
  }

  void goToNext() {
    final mode = ref.read(calendarViewModeProvider);
    final current = ref.read(calendarFocusedDayProvider);
    ref.read(calendarFocusedDayProvider.notifier).state = switch (mode) {
      CalendarViewMode.day => current.add(const Duration(days: 1)),
      CalendarViewMode.week => current.add(const Duration(days: 7)),
      CalendarViewMode.month => DateTime(current.year, current.month + 1, 1),
    };
    refresh();
  }

  void selectDay(DateTime day) {
    ref.read(calendarFocusedDayProvider.notifier).state =
        app_date.DateUtils.startOfDay(day);
    refresh();
  }
}

final filteredCalendarEventsProvider = Provider<List<CalendarEvent>>((ref) {
  final events = ref.watch(calendarEventsProvider).maybeWhen(
        data: (value) => value,
        orElse: () => const <CalendarEvent>[],
      );
  final filter = ref.watch(calendarFilterProvider);
  final query = filter.searchQuery?.trim().toLowerCase() ?? '';

  return events.where((event) {
    final matchesType = filter.types == null ||
        filter.types!.isEmpty ||
        filter.types!.contains(event.eventType);
    final matchesSearch = query.isEmpty ||
        event.title.toLowerCase().contains(query) ||
        event.description.toLowerCase().contains(query);
    return matchesType && matchesSearch;
  }).toList();
});

final calendarEventFormControllerProvider =
    NotifierProvider<CalendarEventFormController, CalendarEventFormState>(
  CalendarEventFormController.new,
);

class CalendarEventFormController extends Notifier<CalendarEventFormState> {
  @override
  CalendarEventFormState build() => const CalendarEventFormIdle();

  Future<bool> createEvent(CreateCalendarEventParams params) async {
    state = const CalendarEventFormLoading();

    final userId = ref.read(currentUserProvider)?.id ?? 'local-user';
    final result = await ref.read(createCalendarEventUseCaseProvider).call(
          CreateCalendarEventRequest(userId: userId, event: params),
        );

    return result.when(
      success: (_) {
        state = const CalendarEventFormSuccess(
          message: 'Event created successfully.',
        );
        ref.invalidate(calendarEventsProvider);
        ref.invalidate(dashboardSummaryProvider);
        return true;
      },
      onFailure: (failure) {
        state = CalendarEventFormError(
          sl<ErrorHandler>().getUserMessage(failure),
        );
        return false;
      },
    );
  }

  Future<bool> updateEvent(UpdateCalendarEventParams params) async {
    state = const CalendarEventFormLoading();

    final userId = ref.read(currentUserProvider)?.id ?? 'local-user';
    final result = await ref.read(updateCalendarEventUseCaseProvider).call(
          UpdateCalendarEventRequest(userId: userId, event: params),
        );

    return result.when(
      success: (_) {
        state = const CalendarEventFormSuccess(
          message: 'Event updated successfully.',
        );
        ref.invalidate(calendarEventsProvider);
        ref.invalidate(dashboardSummaryProvider);
        return true;
      },
      onFailure: (failure) {
        state = CalendarEventFormError(
          sl<ErrorHandler>().getUserMessage(failure),
        );
        return false;
      },
    );
  }

  Future<bool> deleteEvent(String id) async {
    state = const CalendarEventFormLoading();

    final result = await ref.read(deleteCalendarEventUseCaseProvider).call(id);

    return result.when(
      success: (_) {
        state = const CalendarEventFormSuccess(message: 'Event deleted.');
        ref.invalidate(calendarEventsProvider);
        ref.invalidate(dashboardSummaryProvider);
        return true;
      },
      onFailure: (failure) {
        state = CalendarEventFormError(
          sl<ErrorHandler>().getUserMessage(failure),
        );
        return false;
      },
    );
  }

  void clearStatus() => state = const CalendarEventFormIdle();
}

final calendarEventDetailProvider =
    FutureProvider.family<CalendarEvent, String>((ref, id) async {
  final result = await ref.read(getCalendarEventByIdUseCaseProvider).call(id);

  return result.when(
    success: (event) => event,
    onFailure: (failure) {
      throw sl<ErrorHandler>().getUserMessage(failure);
    },
  );
});
