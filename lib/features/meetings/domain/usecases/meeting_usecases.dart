import 'dart:typed_data';

import 'package:personal_os_dashboard/core/domain/usecases/usecase.dart';
import 'package:personal_os_dashboard/core/error/exception_mapper.dart';
import 'package:personal_os_dashboard/core/error/result.dart';
import 'package:personal_os_dashboard/features/meetings/data/services/meeting_pdf_exporter.dart';
import 'package:personal_os_dashboard/features/meetings/domain/entities/meeting.dart';
import 'package:personal_os_dashboard/features/meetings/domain/entities/meeting_params.dart';
import 'package:personal_os_dashboard/features/meetings/domain/repositories/meetings_repository.dart';

final class GetMeetingsUseCase implements AsyncUseCase<List<Meeting>, String> {
  const GetMeetingsUseCase(this._repository);
  final MeetingsRepository _repository;

  @override
  Future<Result<List<Meeting>>> call(String userId) async {
    try {
      return Result.success(await _repository.getMeetings(userId: userId));
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}

final class GetMeetingByIdUseCase implements AsyncUseCase<Meeting, String> {
  const GetMeetingByIdUseCase(this._repository);
  final MeetingsRepository _repository;

  @override
  Future<Result<Meeting>> call(String id) async {
    try {
      return Result.success(await _repository.getMeetingById(id: id));
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}

final class CreateMeetingUseCase
    implements AsyncUseCase<Meeting, CreateMeetingRequest> {
  const CreateMeetingUseCase(this._repository);
  final MeetingsRepository _repository;

  @override
  Future<Result<Meeting>> call(CreateMeetingRequest params) async {
    try {
      return Result.success(
        await _repository.createMeeting(
          userId: params.userId,
          params: params.meeting,
        ),
      );
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}

final class UpdateMeetingUseCase
    implements AsyncUseCase<Meeting, UpdateMeetingRequest> {
  const UpdateMeetingUseCase(this._repository);
  final MeetingsRepository _repository;

  @override
  Future<Result<Meeting>> call(UpdateMeetingRequest params) async {
    try {
      return Result.success(
        await _repository.updateMeeting(
          userId: params.userId,
          params: params.meeting,
        ),
      );
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}

final class DeleteMeetingUseCase implements AsyncUseCase<void, String> {
  const DeleteMeetingUseCase(this._repository);
  final MeetingsRepository _repository;

  @override
  Future<Result<void>> call(String id) async {
    try {
      await _repository.deleteMeeting(id: id);
      return const Result.success(null);
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}

final class ExportMeetingPdfUseCase implements AsyncUseCase<Uint8List, Meeting> {
  const ExportMeetingPdfUseCase(this._exporter);
  final MeetingPdfExporter _exporter;

  @override
  Future<Result<Uint8List>> call(Meeting meeting) async {
    try {
      return Result.success(await _exporter.export(meeting));
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}

final class CreateMeetingRequest {
  const CreateMeetingRequest({required this.userId, required this.meeting});
  final String userId;
  final CreateMeetingParams meeting;
}

final class UpdateMeetingRequest {
  const UpdateMeetingRequest({required this.userId, required this.meeting});
  final String userId;
  final UpdateMeetingParams meeting;
}
