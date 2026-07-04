import 'dart:typed_data';

import 'package:personal_os_dashboard/core/domain/usecases/usecase.dart';
import 'package:personal_os_dashboard/core/error/exception_mapper.dart';
import 'package:personal_os_dashboard/core/error/result.dart';
import 'package:personal_os_dashboard/features/crm/domain/entities/contact.dart';
import 'package:personal_os_dashboard/features/crm/domain/entities/contact_params.dart';
import 'package:personal_os_dashboard/features/crm/domain/repositories/crm_repository.dart';

typedef UploadVisitingCardParams = ({
  String userId,
  String contactId,
  Uint8List bytes,
  String fileName,
  String? contentType,
});

final class GetContactsUseCase implements AsyncUseCase<List<Contact>, String> {
  const GetContactsUseCase(this._repository);
  final CrmRepository _repository;

  @override
  Future<Result<List<Contact>>> call(String userId) async {
    try {
      return Result.success(await _repository.getContacts(userId: userId));
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}

final class GetContactByIdUseCase implements AsyncUseCase<Contact, String> {
  const GetContactByIdUseCase(this._repository);
  final CrmRepository _repository;

  @override
  Future<Result<Contact>> call(String id) async {
    try {
      return Result.success(await _repository.getContactById(id: id));
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}

final class CreateContactUseCase
    implements AsyncUseCase<Contact, CreateContactRequest> {
  const CreateContactUseCase(this._repository);
  final CrmRepository _repository;

  @override
  Future<Result<Contact>> call(CreateContactRequest params) async {
    try {
      return Result.success(
        await _repository.createContact(
          userId: params.userId,
          params: params.contact,
        ),
      );
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}

final class UpdateContactUseCase
    implements AsyncUseCase<Contact, UpdateContactRequest> {
  const UpdateContactUseCase(this._repository);
  final CrmRepository _repository;

  @override
  Future<Result<Contact>> call(UpdateContactRequest params) async {
    try {
      return Result.success(
        await _repository.updateContact(
          userId: params.userId,
          params: params.contact,
        ),
      );
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}

final class DeleteContactUseCase implements AsyncUseCase<void, String> {
  const DeleteContactUseCase(this._repository);
  final CrmRepository _repository;

  @override
  Future<Result<void>> call(String id) async {
    try {
      await _repository.deleteContact(id: id);
      return const Result.success(null);
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}

final class UploadVisitingCardUseCase
    implements AsyncUseCase<Contact, UploadVisitingCardParams> {
  const UploadVisitingCardUseCase(this._repository);
  final CrmRepository _repository;

  @override
  Future<Result<Contact>> call(UploadVisitingCardParams params) async {
    try {
      final uploaded = await _repository.uploadVisitingCard(
        userId: params.userId,
        contactId: params.contactId,
        bytes: params.bytes,
        fileName: params.fileName,
        contentType: params.contentType,
      );
      return Result.success(
        await _repository.updateVisitingCard(
          contactId: params.contactId,
          storagePath: uploaded.path,
          publicUrl: uploaded.url,
        ),
      );
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}

final class GetCompaniesUseCase implements AsyncUseCase<List<Company>, String> {
  const GetCompaniesUseCase(this._repository);
  final CrmRepository _repository;

  @override
  Future<Result<List<Company>>> call(String userId) async {
    try {
      return Result.success(await _repository.getCompanies(userId: userId));
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}

final class GetCompanyByIdUseCase implements AsyncUseCase<Company, String> {
  const GetCompanyByIdUseCase(this._repository);
  final CrmRepository _repository;

  @override
  Future<Result<Company>> call(String id) async {
    try {
      return Result.success(await _repository.getCompanyById(id: id));
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}

final class CreateCompanyUseCase
    implements AsyncUseCase<Company, CreateCompanyRequest> {
  const CreateCompanyUseCase(this._repository);
  final CrmRepository _repository;

  @override
  Future<Result<Company>> call(CreateCompanyRequest params) async {
    try {
      return Result.success(
        await _repository.createCompany(
          userId: params.userId,
          params: params.company,
        ),
      );
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}

final class UpdateCompanyUseCase
    implements AsyncUseCase<Company, UpdateCompanyRequest> {
  const UpdateCompanyUseCase(this._repository);
  final CrmRepository _repository;

  @override
  Future<Result<Company>> call(UpdateCompanyRequest params) async {
    try {
      return Result.success(
        await _repository.updateCompany(
          userId: params.userId,
          params: params.company,
        ),
      );
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}

final class DeleteCompanyUseCase implements AsyncUseCase<void, String> {
  const DeleteCompanyUseCase(this._repository);
  final CrmRepository _repository;

  @override
  Future<Result<void>> call(String id) async {
    try {
      await _repository.deleteCompany(id: id);
      return const Result.success(null);
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}

final class CreateContactRequest {
  const CreateContactRequest({required this.userId, required this.contact});
  final String userId;
  final CreateContactParams contact;
}

final class UpdateContactRequest {
  const UpdateContactRequest({required this.userId, required this.contact});
  final String userId;
  final UpdateContactParams contact;
}

final class CreateCompanyRequest {
  const CreateCompanyRequest({required this.userId, required this.company});
  final String userId;
  final CreateCompanyParams company;
}

final class UpdateCompanyRequest {
  const UpdateCompanyRequest({required this.userId, required this.company});
  final String userId;
  final UpdateCompanyParams company;
}
