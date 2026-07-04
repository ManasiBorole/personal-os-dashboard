import 'package:personal_os_dashboard/features/meetings/data/datasources/local_meetings_data_source.dart';
import 'package:personal_os_dashboard/features/meetings/data/datasources/meetings_data_source.dart';
import 'package:personal_os_dashboard/features/meetings/domain/entities/meeting.dart';
import 'package:personal_os_dashboard/features/meetings/domain/entities/meeting_params.dart';
import 'package:personal_os_dashboard/features/meetings/domain/repositories/meetings_repository.dart';

final class MeetingsRepositoryImpl implements MeetingsRepository {
  MeetingsRepositoryImpl(this._dataSource);

  final MeetingsDataSource _dataSource;

  @override
  Future<List<Meeting>> getMeetings({required String userId}) async {
    final models = await _dataSource.getMeetings(userId: userId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Meeting> getMeetingById({required String id}) async {
    final model = await _dataSource.getMeetingById(id: id);
    return model.toEntity();
  }

  @override
  Future<Meeting> createMeeting({
    required String userId,
    required CreateMeetingParams params,
  }) async {
    final model = await _dataSource.createMeeting(
      userId: userId,
      params: params,
    );
    return model.toEntity();
  }

  @override
  Future<Meeting> updateMeeting({
    required String userId,
    required UpdateMeetingParams params,
  }) async {
    final model = await _dataSource.updateMeeting(
      userId: userId,
      params: params,
    );
    return model.toEntity();
  }

  @override
  Future<void> deleteMeeting({required String id}) async {
    await _dataSource.deleteMeeting(id: id);
  }
}

final class UnconfiguredMeetingsRepository implements MeetingsRepository {
  UnconfiguredMeetingsRepository()
      : _delegate = MeetingsRepositoryImpl(LocalMeetingsDataSource());

  final MeetingsRepositoryImpl _delegate;

  @override
  Future<List<Meeting>> getMeetings({required String userId}) =>
      _delegate.getMeetings(userId: userId);

  @override
  Future<Meeting> getMeetingById({required String id}) =>
      _delegate.getMeetingById(id: id);

  @override
  Future<Meeting> createMeeting({
    required String userId,
    required CreateMeetingParams params,
  }) =>
      _delegate.createMeeting(userId: userId, params: params);

  @override
  Future<Meeting> updateMeeting({
    required String userId,
    required UpdateMeetingParams params,
  }) =>
      _delegate.updateMeeting(userId: userId, params: params);

  @override
  Future<void> deleteMeeting({required String id}) =>
      _delegate.deleteMeeting(id: id);
}

MeetingsRepository createMeetingsRepository({
  required bool isSupabaseReady,
  required MeetingsDataSource remoteDataSource,
}) {
  if (isSupabaseReady) {
    return MeetingsRepositoryImpl(remoteDataSource);
  }
  return UnconfiguredMeetingsRepository();
}
