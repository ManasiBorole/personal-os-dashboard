import 'package:personal_os_dashboard/features/calendar/domain/entities/calendar_event.dart';
import 'package:personal_os_dashboard/features/calendar/domain/entities/calendar_event_params.dart';

/// Calendar events repository contract.
abstract interface class CalendarRepository {
  Future<List<CalendarEvent>> getEvents({
    required String userId,
    required DateTime rangeStart,
    required DateTime rangeEnd,
  });

  Future<CalendarEvent> getEventById({required String id});

  Future<CalendarEvent> createEvent({
    required String userId,
    required CreateCalendarEventParams params,
  });

  Future<CalendarEvent> updateEvent({
    required String userId,
    required UpdateCalendarEventParams params,
  });

  Future<void> deleteEvent({required String id});
}
