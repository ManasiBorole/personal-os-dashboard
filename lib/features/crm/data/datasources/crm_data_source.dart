import 'package:personal_os_dashboard/features/crm/data/models/contact_model.dart';
import 'package:personal_os_dashboard/features/crm/domain/entities/contact_params.dart';

/// Data source contract for CRM contacts and companies.
abstract interface class CrmDataSource {
  Future<List<ContactModel>> getContacts({required String userId});

  Future<ContactModel> getContactById({required String id});

  Future<ContactModel> createContact({
    required String userId,
    required CreateContactParams params,
  });

  Future<ContactModel> updateContact({
    required String userId,
    required UpdateContactParams params,
  });

  Future<void> deleteContact({required String id});

  Future<ContactModel> updateVisitingCard({
    required String contactId,
    required String? storagePath,
    required String? publicUrl,
  });

  Future<List<CompanyModel>> getCompanies({required String userId});

  Future<CompanyModel> getCompanyById({required String id});

  Future<CompanyModel> createCompany({
    required String userId,
    required CreateCompanyParams params,
  });

  Future<CompanyModel> updateCompany({
    required String userId,
    required UpdateCompanyParams params,
  });

  Future<void> deleteCompany({required String id});
}
