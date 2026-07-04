import 'package:personal_os_dashboard/features/calendar/data/models/calendar_event_model.dart';
import 'package:personal_os_dashboard/features/calendar/domain/entities/calendar_event_params.dart';

/// Data source contract for calendar events.
abstract interface class CalendarDataSource {
  Future<List<CalendarEventModel>> getEvents({
    required String userId,
    required DateTime rangeStart,
    required DateTime rangeEnd,
  });

  Future<CalendarEventModel> getEventById({required String id});

  Future<CalendarEventModel> createEvent({
    required String userId,
    required CreateCalendarEventParams params,
  });

  Future<CalendarEventModel> updateEvent({
    required String userId,
    required UpdateCalendarEventParams params,
  });

  Future<void> deleteEvent({required String id});
}
