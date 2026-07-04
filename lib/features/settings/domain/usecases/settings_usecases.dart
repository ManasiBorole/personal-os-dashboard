import 'package:personal_os_dashboard/core/domain/usecases/usecase.dart';
import 'package:personal_os_dashboard/core/error/exception_mapper.dart';
import 'package:personal_os_dashboard/core/error/result.dart';
import 'package:personal_os_dashboard/features/settings/domain/entities/settings_entities.dart';
import 'package:personal_os_dashboard/features/settings/domain/entities/settings_params.dart';
import 'package:personal_os_dashboard/features/settings/domain/repositories/settings_repository.dart';

typedef UpdateUserProfileRequest = ({
  String userId,
  String email,
  UpdateUserProfileParams params,
});

final class GetUserProfileUseCase
    implements AsyncUseCase<UserProfile, ({String userId, String? email})> {
  const GetUserProfileUseCase(this._repository);
  final SettingsRepository _repository;

  @override
  Future<Result<UserProfile>> call(({String userId, String? email}) params) async {
    try {
      return Result.success(
        await _repository.getUserProfile(
          userId: params.userId,
          email: params.email,
        ),
      );
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}

final class UpdateUserProfileUseCase
    implements AsyncUseCase<UserProfile, UpdateUserProfileRequest> {
  const UpdateUserProfileUseCase(this._repository);
  final SettingsRepository _repository;

  @override
  Future<Result<UserProfile>> call(UpdateUserProfileRequest params) async {
    try {
      return Result.success(
        await _repository.updateUserProfile(
          userId: params.userId,
          email: params.email,
          params: params.params,
        ),
      );
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}

final class GetAppPreferencesUseCase
    implements AsyncUseCase<AppPreferences, NoParams> {
  const GetAppPreferencesUseCase(this._repository);
  final SettingsRepository _repository;

  @override
  Future<Result<AppPreferences>> call(NoParams params) async {
    try {
      return Result.success(await _repository.getPreferences());
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}

final class UpdateAppPreferencesUseCase
    implements AsyncUseCase<AppPreferences, AppPreferences> {
  const UpdateAppPreferencesUseCase(this._repository);
  final SettingsRepository _repository;

  @override
  Future<Result<AppPreferences>> call(AppPreferences preferences) async {
    try {
      return Result.success(await _repository.updatePreferences(preferences));
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}

final class CreateBackupUseCase implements AsyncUseCase<BackupSummary, String> {
  const CreateBackupUseCase(this._repository);
  final SettingsRepository _repository;

  @override
  Future<Result<BackupSummary>> call(String userId) async {
    try {
      return Result.success(await _repository.createBackup(userId: userId));
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}
