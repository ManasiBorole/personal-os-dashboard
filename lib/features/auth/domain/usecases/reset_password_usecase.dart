import 'package:personal_os_dashboard/core/domain/usecases/usecase.dart';
import 'package:personal_os_dashboard/core/error/exception_mapper.dart';
import 'package:personal_os_dashboard/core/error/result.dart';
import 'package:personal_os_dashboard/features/auth/domain/entities/auth_credentials.dart';
import 'package:personal_os_dashboard/features/auth/domain/repositories/auth_repository.dart';

/// Sends a password reset email to the user.
final class ResetPasswordUseCase
    implements AsyncUseCase<void, ResetPasswordParams> {
  const ResetPasswordUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<void>> call(ResetPasswordParams params) async {
    try {
      await _repository.resetPassword(email: params.email);
      return const Result.success(null);
    } on Object catch (error) {
      return Result.failure(ExceptionMapper.mapException(error));
    }
  }
}
