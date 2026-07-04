import 'dart:typed_data';

import 'package:personal_os_dashboard/features/crm/data/datasources/crm_data_source.dart';
import 'package:personal_os_dashboard/features/crm/data/datasources/local_crm_data_source.dart';
import 'package:personal_os_dashboard/features/crm/data/services/visiting_card_storage.dart';
import 'package:personal_os_dashboard/features/crm/domain/entities/contact.dart';
import 'package:personal_os_dashboard/features/crm/domain/entities/contact_params.dart';
import 'package:personal_os_dashboard/features/crm/domain/repositories/crm_repository.dart';

final class CrmRepositoryImpl implements CrmRepository {
  CrmRepositoryImpl(
    this._dataSource, {
    VisitingCardStorage? visitingCardStorage,
  }) : _visitingCardStorage = visitingCardStorage;

  final CrmDataSource _dataSource;
  final VisitingCardStorage? _visitingCardStorage;

  @override
  Future<List<Contact>> getContacts({required String userId}) async {
    final models = await _dataSource.getContacts(userId: userId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Contact> getContactById({required String id}) async {
    final model = await _dataSource.getContactById(id: id);
    return model.toEntity();
  }

  @override
  Future<Contact> createContact({
    required String userId,
    required CreateContactParams params,
  }) async {
    final model = await _dataSource.createContact(
      userId: userId,
      params: params,
    );
    return model.toEntity();
  }

  @override
  Future<Contact> updateContact({
    required String userId,
    required UpdateContactParams params,
  }) async {
    final model = await _dataSource.updateContact(
      userId: userId,
      params: params,
    );
    return model.toEntity();
  }

  @override
  Future<void> deleteContact({required String id}) async {
    await _dataSource.deleteContact(id: id);
  }

  @override
  Future<Contact> updateVisitingCard({
    required String contactId,
    required String? storagePath,
    required String? publicUrl,
  }) async {
    final model = await _dataSource.updateVisitingCard(
      contactId: contactId,
      storagePath: storagePath,
      publicUrl: publicUrl,
    );
    return model.toEntity();
  }

  @override
  Future<List<Company>> getCompanies({required String userId}) async {
    final models = await _dataSource.getCompanies(userId: userId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Company> getCompanyById({required String id}) async {
    final model = await _dataSource.getCompanyById(id: id);
    return model.toEntity();
  }

  @override
  Future<Company> createCompany({
    required String userId,
    required CreateCompanyParams params,
  }) async {
    final model = await _dataSource.createCompany(
      userId: userId,
      params: params,
    );
    return model.toEntity();
  }

  @override
  Future<Company> updateCompany({
    required String userId,
    required UpdateCompanyParams params,
  }) async {
    final model = await _dataSource.updateCompany(
      userId: userId,
      params: params,
    );
    return model.toEntity();
  }

  @override
  Future<void> deleteCompany({required String id}) async {
    await _dataSource.deleteCompany(id: id);
  }

  @override
  Future<({String path, String url})> uploadVisitingCard({
    required String userId,
    required String contactId,
    required Uint8List bytes,
    required String fileName,
    String? contentType,
  }) async {
    final storage = _visitingCardStorage;
    if (storage != null) {
      return storage.upload(
        userId: userId,
        contactId: contactId,
        bytes: bytes,
        fileName: fileName,
        contentType: contentType,
      );
    }
    final path = '$userId/$contactId/$fileName';
    return (path: path, url: 'local://$path');
  }
}

final class UnconfiguredCrmRepository implements CrmRepository {
  UnconfiguredCrmRepository()
      : _delegate = CrmRepositoryImpl(LocalCrmDataSource());

  final CrmRepositoryImpl _delegate;

  @override
  Future<List<Contact>> getContacts({required String userId}) =>
      _delegate.getContacts(userId: userId);

  @override
  Future<Contact> getContactById({required String id}) =>
      _delegate.getContactById(id: id);

  @override
  Future<Contact> createContact({
    required String userId,
    required CreateContactParams params,
  }) =>
      _delegate.createContact(userId: userId, params: params);

  @override
  Future<Contact> updateContact({
    required String userId,
    required UpdateContactParams params,
  }) =>
      _delegate.updateContact(userId: userId, params: params);

  @override
  Future<void> deleteContact({required String id}) =>
      _delegate.deleteContact(id: id);

  @override
  Future<Contact> updateVisitingCard({
    required String contactId,
    required String? storagePath,
    required String? publicUrl,
  }) =>
      _delegate.updateVisitingCard(
        contactId: contactId,
        storagePath: storagePath,
        publicUrl: publicUrl,
      );

  @override
  Future<List<Company>> getCompanies({required String userId}) =>
      _delegate.getCompanies(userId: userId);

  @override
  Future<Company> getCompanyById({required String id}) =>
      _delegate.getCompanyById(id: id);

  @override
  Future<Company> createCompany({
    required String userId,
    required CreateCompanyParams params,
  }) =>
      _delegate.createCompany(userId: userId, params: params);

  @override
  Future<Company> updateCompany({
    required String userId,
    required UpdateCompanyParams params,
  }) =>
      _delegate.updateCompany(userId: userId, params: params);

  @override
  Future<void> deleteCompany({required String id}) =>
      _delegate.deleteCompany(id: id);

  @override
  Future<({String path, String url})> uploadVisitingCard({
    required String userId,
    required String contactId,
    required Uint8List bytes,
    required String fileName,
    String? contentType,
  }) =>
      _delegate.uploadVisitingCard(
        userId: userId,
        contactId: contactId,
        bytes: bytes,
        fileName: fileName,
        contentType: contentType,
      );
}

CrmRepository createCrmRepository({
  required bool isSupabaseReady,
  required CrmDataSource remoteDataSource,
  VisitingCardStorage? visitingCardStorage,
}) {
  if (isSupabaseReady) {
    return CrmRepositoryImpl(
      remoteDataSource,
      visitingCardStorage: visitingCardStorage,
    );
  }
  return UnconfiguredCrmRepository();
}
