import 'package:personal_os_dashboard/core/domain/usecases/usecase.dart';
import 'package:personal_os_dashboard/core/error/exception_mapper.dart';
import 'package:personal_os_dashboard/core/error/result.dart';
import 'package:personal_os_dashboard/features/calendar/domain/entities/calendar_event.dart';
import 'package:personal_os_dashboard/features/calendar/domain/entities/calendar_event_params.dart';
import 'package:personal_os_dashboard/features/calendar/domain/repositories/calendar_repository.dart';

typedef GetCalendarEventsParams = ({
  String userId,
  DateTime rangeStart,
  DateTime rangeEnd,
});

final class GetCalendarEventsUseCase
    implements AsyncUseCase<List<CalendarEvent>, GetCalendarEventsParams> {
  const GetCalendarEventsUseCase(this._repository);
  final CalendarRepository _repository;

  @override
  Future<Result<List<CalendarEvent>>> call(GetCalendarEventsParams params) async {
    try {
      return Result.success(
        await _repository.getEvents(
          userId: params.userId,
          rangeStart: params.rangeStart,
          rangeEnd: params.rangeEnd,
        ),
      );
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}

final class GetCalendarEventByIdUseCase
    implements AsyncUseCase<CalendarEvent, String> {
  const GetCalendarEventByIdUseCase(this._repository);
  final CalendarRepository _repository;

  @override
  Future<Result<CalendarEvent>> call(String id) async {
    try {
      return Result.success(await _repository.getEventById(id: id));
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}

final class CreateCalendarEventUseCase
    implements AsyncUseCase<CalendarEvent, CreateCalendarEventRequest> {
  const CreateCalendarEventUseCase(this._repository);
  final CalendarRepository _repository;

  @override
  Future<Result<CalendarEvent>> call(CreateCalendarEventRequest params) async {
    try {
      return Result.success(
        await _repository.createEvent(
          userId: params.userId,
          params: params.event,
        ),
      );
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}

final class UpdateCalendarEventUseCase
    implements AsyncUseCase<CalendarEvent, UpdateCalendarEventRequest> {
  const UpdateCalendarEventUseCase(this._repository);
  final CalendarRepository _repository;

  @override
  Future<Result<CalendarEvent>> call(UpdateCalendarEventRequest params) async {
    try {
      return Result.success(
        await _repository.updateEvent(
          userId: params.userId,
          params: params.event,
        ),
      );
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}

final class DeleteCalendarEventUseCase implements AsyncUseCase<void, String> {
  const DeleteCalendarEventUseCase(this._repository);
  final CalendarRepository _repository;

  @override
  Future<Result<void>> call(String id) async {
    try {
      await _repository.deleteEvent(id: id);
      return const Result.success(null);
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}

final class CreateCalendarEventRequest {
  const CreateCalendarEventRequest({required this.userId, required this.event});
  final String userId;
  final CreateCalendarEventParams event;
}

final class UpdateCalendarEventRequest {
  const UpdateCalendarEventRequest({required this.userId, required this.event});
  final String userId;
  final UpdateCalendarEventParams event;
}
