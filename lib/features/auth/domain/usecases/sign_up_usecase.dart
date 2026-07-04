import 'package:personal_os_dashboard/core/domain/usecases/usecase.dart';
import 'package:personal_os_dashboard/core/error/exception_mapper.dart';
import 'package:personal_os_dashboard/core/error/result.dart';
import 'package:personal_os_dashboard/features/auth/domain/entities/auth_credentials.dart';
import 'package:personal_os_dashboard/features/auth/domain/repositories/auth_repository.dart';

/// Registers a new user account.
final class SignUpUseCase implements AsyncUseCase<void, AuthCredentials> {
  const SignUpUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<void>> call(AuthCredentials params) async {
    try {
      await _repository.signUp(
        email: params.email,
        password: params.password,
      );
      return const Result.success(null);
    } on Object catch (error) {
      return Result.failure(ExceptionMapper.mapException(error));
    }
  }
}
