import 'package:personal_os_dashboard/core/domain/usecases/usecase.dart';
import 'package:personal_os_dashboard/core/error/exception_mapper.dart';
import 'package:personal_os_dashboard/core/error/result.dart';
import 'package:personal_os_dashboard/features/tasks/domain/entities/task.dart';
import 'package:personal_os_dashboard/features/tasks/domain/entities/task_params.dart';
import 'package:personal_os_dashboard/features/tasks/domain/repositories/tasks_repository.dart';

typedef GetTasksParams = ({String userId, String? projectId});

final class GetTasksUseCase implements AsyncUseCase<List<Task>, GetTasksParams> {
  const GetTasksUseCase(this._repository);
  final TasksRepository _repository;

  @override
  Future<Result<List<Task>>> call(GetTasksParams params) async {
    try {
      return Result.success(
        await _repository.getTasks(
          userId: params.userId,
          projectId: params.projectId,
        ),
      );
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}

final class GetTaskByIdUseCase implements AsyncUseCase<Task, String> {
  const GetTaskByIdUseCase(this._repository);
  final TasksRepository _repository;

  @override
  Future<Result<Task>> call(String id) async {
    try {
      return Result.success(await _repository.getTaskById(id: id));
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}

final class CreateTaskUseCase
    implements AsyncUseCase<Task, CreateTaskRequest> {
  const CreateTaskUseCase(this._repository);
  final TasksRepository _repository;

  @override
  Future<Result<Task>> call(CreateTaskRequest params) async {
    try {
      return Result.success(
        await _repository.createTask(
          userId: params.userId,
          params: params.task,
        ),
      );
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}

final class UpdateTaskUseCase
    implements AsyncUseCase<Task, UpdateTaskRequest> {
  const UpdateTaskUseCase(this._repository);
  final TasksRepository _repository;

  @override
  Future<Result<Task>> call(UpdateTaskRequest params) async {
    try {
      return Result.success(
        await _repository.updateTask(
          userId: params.userId,
          params: params.task,
        ),
      );
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}

final class CompleteTaskUseCase implements AsyncUseCase<Task, String> {
  const CompleteTaskUseCase(this._repository);
  final TasksRepository _repository;

  @override
  Future<Result<Task>> call(String id) async {
    try {
      return Result.success(await _repository.completeTask(id: id));
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}

final class DeleteTaskUseCase implements AsyncUseCase<void, String> {
  const DeleteTaskUseCase(this._repository);
  final TasksRepository _repository;

  @override
  Future<Result<void>> call(String id) async {
    try {
      await _repository.deleteTask(id: id);
      return const Result.success(null);
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}

final class CreateTaskRequest {
  const CreateTaskRequest({required this.userId, required this.task});
  final String userId;
  final CreateTaskParams task;
}

final class UpdateTaskRequest {
  const UpdateTaskRequest({required this.userId, required this.task});
  final String userId;
  final UpdateTaskParams task;
}
