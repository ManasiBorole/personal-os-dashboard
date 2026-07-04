import 'dart:typed_data';

import 'package:personal_os_dashboard/features/crm/domain/entities/contact.dart';
import 'package:personal_os_dashboard/features/crm/domain/entities/contact_params.dart';

/// CRM repository contract.
abstract interface class CrmRepository {
  Future<List<Contact>> getContacts({required String userId});

  Future<Contact> getContactById({required String id});

  Future<Contact> createContact({
    required String userId,
    required CreateContactParams params,
  });

  Future<Contact> updateContact({
    required String userId,
    required UpdateContactParams params,
  });

  Future<void> deleteContact({required String id});

  Future<Contact> updateVisitingCard({
    required String contactId,
    required String? storagePath,
    required String? publicUrl,
  });

  Future<List<Company>> getCompanies({required String userId});

  Future<Company> getCompanyById({required String id});

  Future<Company> createCompany({
    required String userId,
    required CreateCompanyParams params,
  });

  Future<Company> updateCompany({
    required String userId,
    required UpdateCompanyParams params,
  });

  Future<void> deleteCompany({required String id});

  Future<({String path, String url})> uploadVisitingCard({
    required String userId,
    required String contactId,
    required Uint8List bytes,
    required String fileName,
    String? contentType,
  });
}
