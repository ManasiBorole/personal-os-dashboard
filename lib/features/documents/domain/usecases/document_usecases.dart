import 'dart:typed_data';

import 'package:personal_os_dashboard/core/domain/usecases/usecase.dart';
import 'package:personal_os_dashboard/core/error/exception_mapper.dart';
import 'package:personal_os_dashboard/core/error/result.dart';
import 'package:personal_os_dashboard/features/documents/domain/entities/document.dart';
import 'package:personal_os_dashboard/features/documents/domain/entities/document_params.dart';
import 'package:personal_os_dashboard/features/documents/domain/repositories/documents_repository.dart';

final class GetFoldersUseCase
    implements AsyncUseCase<List<DocumentFolder>, GetFoldersRequest> {
  const GetFoldersUseCase(this._repository);
  final DocumentsRepository _repository;

  @override
  Future<Result<List<DocumentFolder>>> call(GetFoldersRequest params) async {
    try {
      return Result.success(
        await _repository.getFolders(
          userId: params.userId,
          parentId: params.parentId,
        ),
      );
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}

final class CreateFolderUseCase
    implements AsyncUseCase<DocumentFolder, CreateFolderRequest> {
  const CreateFolderUseCase(this._repository);
  final DocumentsRepository _repository;

  @override
  Future<Result<DocumentFolder>> call(CreateFolderRequest params) async {
    try {
      return Result.success(
        await _repository.createFolder(
          userId: params.userId,
          params: params.folder,
        ),
      );
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}

final class DeleteFolderUseCase implements AsyncUseCase<void, String> {
  const DeleteFolderUseCase(this._repository);
  final DocumentsRepository _repository;

  @override
  Future<Result<void>> call(String id) async {
    try {
      await _repository.deleteFolder(id: id);
      return const Result.success(null);
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}

final class GetDocumentsUseCase
    implements AsyncUseCase<List<ManagedDocument>, GetDocumentsRequest> {
  const GetDocumentsUseCase(this._repository);
  final DocumentsRepository _repository;

  @override
  Future<Result<List<ManagedDocument>>> call(GetDocumentsRequest params) async {
    try {
      return Result.success(
        await _repository.getDocuments(
          userId: params.userId,
          folderId: params.folderId,
        ),
      );
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}

final class GetDocumentByIdUseCase
    implements AsyncUseCase<ManagedDocument, String> {
  const GetDocumentByIdUseCase(this._repository);
  final DocumentsRepository _repository;

  @override
  Future<Result<ManagedDocument>> call(String id) async {
    try {
      return Result.success(await _repository.getDocumentById(id: id));
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}

final class UploadDocumentUseCase
    implements AsyncUseCase<ManagedDocument, UploadDocumentRequest> {
  const UploadDocumentUseCase(this._repository);
  final DocumentsRepository _repository;

  @override
  Future<Result<ManagedDocument>> call(UploadDocumentRequest params) async {
    try {
      return Result.success(
        await _repository.uploadDocument(
          userId: params.userId,
          params: params.document,
        ),
      );
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}

final class DownloadDocumentUseCase
    implements AsyncUseCase<Uint8List, ManagedDocument> {
  const DownloadDocumentUseCase(this._repository);
  final DocumentsRepository _repository;

  @override
  Future<Result<Uint8List>> call(ManagedDocument document) async {
    try {
      return Result.success(
        await _repository.downloadDocument(document: document),
      );
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}

final class DeleteDocumentUseCase
    implements AsyncUseCase<void, ManagedDocument> {
  const DeleteDocumentUseCase(this._repository);
  final DocumentsRepository _repository;

  @override
  Future<Result<void>> call(ManagedDocument document) async {
    try {
      await _repository.deleteDocument(document: document);
      return const Result.success(null);
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}

final class GetFoldersRequest {
  const GetFoldersRequest({required this.userId, this.parentId});
  final String userId;
  final String? parentId;
}

final class CreateFolderRequest {
  const CreateFolderRequest({required this.userId, required this.folder});
  final String userId;
  final CreateFolderParams folder;
}

final class GetDocumentsRequest {
  const GetDocumentsRequest({required this.userId, this.folderId});
  final String userId;
  final String? folderId;
}

final class UploadDocumentRequest {
  const UploadDocumentRequest({required this.userId, required this.document});
  final String userId;
  final UploadDocumentParams document;
}
