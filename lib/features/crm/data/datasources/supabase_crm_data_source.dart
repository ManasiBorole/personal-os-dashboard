import 'package:personal_os_dashboard/core/constants/api_constants.dart';
import 'package:personal_os_dashboard/core/supabase/datasources/supabase_remote_datasources.dart';
import 'package:personal_os_dashboard/features/crm/data/datasources/crm_data_source.dart';
import 'package:personal_os_dashboard/features/crm/data/models/contact_model.dart';
import 'package:personal_os_dashboard/features/crm/domain/entities/contact_params.dart';

final class SupabaseCrmDataSource implements CrmDataSource {
  SupabaseCrmDataSource(this._database);

  final DatabaseRemoteDataSource _database;

  @override
  Future<List<ContactModel>> getContacts({required String userId}) async {
    final rows = await _database.select(
      table: ApiConstants.contactsTable,
      filters: {'user_id': userId},
      orderBy: 'updated_at',
      ascending: false,
    );
    final companies = await _companyNameMap(userId);
    return rows
        .map((row) => _contactFromRow(row, companies))
        .toList();
  }

  @override
  Future<ContactModel> getContactById({required String id}) async {
    final row = await _database.selectById(
      table: ApiConstants.contactsTable,
      id: id,
    );
    final companies = await _companyNameMap(row['user_id']?.toString() ?? '');
    return _contactFromRow(row, companies);
  }

  @override
  Future<ContactModel> createContact({
    required String userId,
    required CreateContactParams params,
  }) async {
    final row = await _database.insert(
      table: ApiConstants.contactsTable,
      data: {
        'user_id': userId,
        'company_id': params.companyId,
        'first_name': params.firstName.trim(),
        'last_name': params.lastName.trim(),
        'phone': params.phone,
        'email': params.email,
        'address': params.address,
        'category': params.category,
        'tags': params.tags,
        'contact_notes': params.notes.map(ContactModel.noteToJson).toList(),
        'follow_ups': params.followUps.map(ContactModel.followUpToJson).toList(),
        'meeting_history':
            params.meetingHistory.map(ContactModel.meetingToJson).toList(),
        'birthday': params.birthday?.toIso8601String(),
      },
    );
    final companies = await _companyNameMap(userId);
    return _contactFromRow(row, companies);
  }

  @override
  Future<ContactModel> updateContact({
    required String userId,
    required UpdateContactParams params,
  }) async {
    final row = await _database.update(
      table: ApiConstants.contactsTable,
      data: {
        'company_id': params.clearCompanyId ? null : params.companyId,
        'first_name': params.firstName.trim(),
        'last_name': params.lastName.trim(),
        'phone': params.phone,
        'email': params.email,
        'address': params.address,
        'category': params.category,
        'tags': params.tags,
        'contact_notes': params.notes.map(ContactModel.noteToJson).toList(),
        'follow_ups': params.followUps.map(ContactModel.followUpToJson).toList(),
        'meeting_history':
            params.meetingHistory.map(ContactModel.meetingToJson).toList(),
        'birthday': params.clearBirthday
            ? null
            : params.birthday?.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      filters: {'id': params.id, 'user_id': userId},
    );
    final companies = await _companyNameMap(userId);
    return _contactFromRow(row, companies);
  }

  @override
  Future<void> deleteContact({required String id}) async {
    await _database.delete(
      table: ApiConstants.contactsTable,
      filters: {'id': id},
    );
  }

  @override
  Future<ContactModel> updateVisitingCard({
    required String contactId,
    required String? storagePath,
    required String? publicUrl,
  }) async {
    final row = await _database.update(
      table: ApiConstants.contactsTable,
      data: {
        'visiting_card_path': storagePath,
        'visiting_card_url': publicUrl,
        'updated_at': DateTime.now().toIso8601String(),
      },
      filters: {'id': contactId},
    );
    final companies =
        await _companyNameMap(row['user_id']?.toString() ?? '');
    return _contactFromRow(row, companies);
  }

  @override
  Future<List<CompanyModel>> getCompanies({required String userId}) async {
    final rows = await _database.select(
      table: ApiConstants.companiesTable,
      filters: {'user_id': userId},
      orderBy: 'name',
      ascending: true,
    );
    return rows.map(CompanyModel.fromJson).toList();
  }

  @override
  Future<CompanyModel> getCompanyById({required String id}) async {
    final row = await _database.selectById(
      table: ApiConstants.companiesTable,
      id: id,
    );
    return CompanyModel.fromJson(row);
  }

  @override
  Future<CompanyModel> createCompany({
    required String userId,
    required CreateCompanyParams params,
  }) async {
    final row = await _database.insert(
      table: ApiConstants.companiesTable,
      data: {
        'user_id': userId,
        'name': params.name.trim(),
        'industry': params.industry.trim(),
        'phone': params.phone,
        'email': params.email,
        'address': params.address,
        'website': params.website,
        'tags': params.tags,
        'notes': params.notes.trim(),
      },
    );
    return CompanyModel.fromJson(row);
  }

  @override
  Future<CompanyModel> updateCompany({
    required String userId,
    required UpdateCompanyParams params,
  }) async {
    final row = await _database.update(
      table: ApiConstants.companiesTable,
      data: {
        'name': params.name.trim(),
        'industry': params.industry.trim(),
        'phone': params.phone,
        'email': params.email,
        'address': params.address,
        'website': params.website,
        'tags': params.tags,
        'notes': params.notes.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      filters: {'id': params.id, 'user_id': userId},
    );
    return CompanyModel.fromJson(row);
  }

  @override
  Future<void> deleteCompany({required String id}) async {
    await _database.delete(
      table: ApiConstants.companiesTable,
      filters: {'id': id},
    );
  }

  Future<Map<String, String>> _companyNameMap(String userId) async {
    final rows = await _database.select(
      table: ApiConstants.companiesTable,
      columns: 'id, name',
      filters: {'user_id': userId},
    );
    return {
      for (final row in rows)
        row['id']?.toString() ?? '': row['name']?.toString() ?? '',
    };
  }

  ContactModel _contactFromRow(
    Map<String, dynamic> row,
    Map<String, String> companies,
  ) {
    final companyId = row['company_id']?.toString();
    final model = ContactModel.fromJson(row);
    return ContactModel(
      id: model.id,
      userId: model.userId,
      companyId: model.companyId,
      firstName: model.firstName,
      lastName: model.lastName,
      phone: model.phone,
      email: model.email,
      address: model.address,
      category: model.category,
      tags: model.tags,
      visitingCardPath: model.visitingCardPath,
      visitingCardUrl: model.visitingCardUrl,
      notes: model.notes,
      followUps: model.followUps,
      meetingHistory: model.meetingHistory,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      companyName:
          companyId != null ? companies[companyId] : null,
    );
  }
}
