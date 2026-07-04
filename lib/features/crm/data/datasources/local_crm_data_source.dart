import 'package:personal_os_dashboard/features/crm/data/datasources/crm_data_source.dart';
import 'package:personal_os_dashboard/features/crm/data/models/contact_model.dart';
import 'package:personal_os_dashboard/features/crm/domain/entities/contact.dart';
import 'package:personal_os_dashboard/features/crm/domain/entities/contact_params.dart';

final class LocalCrmDataSource implements CrmDataSource {
  final Map<String, ContactModel> _contacts = {};
  final Map<String, CompanyModel> _companies = {};

  LocalCrmDataSource() {
    _seed();
  }

  void _seed() {
    const userId = 'local-user';
    final now = DateTime.now();

    final companies = [
      CompanyModel(
        id: 'company-local-1',
        userId: userId,
        name: 'Acme Corp',
        industry: 'Technology',
        phone: '+1 555-0100',
        email: 'hello@acme.example',
        address: '123 Innovation Way, San Francisco, CA',
        website: 'https://acme.example',
        tags: const ['enterprise', 'saas'],
        notes: 'Key strategic partner for Q3.',
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      CompanyModel(
        id: 'company-local-2',
        userId: userId,
        name: 'Bright Ideas Studio',
        industry: 'Design',
        phone: '+1 555-0200',
        email: 'contact@brightideas.example',
        address: '45 Creative Lane, Austin, TX',
        website: 'https://brightideas.example',
        tags: const ['design', 'freelance'],
        notes: 'Collaborated on dashboard UI.',
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
    ];

    for (final company in companies) {
      _companies[company.id] = company;
    }

    final contacts = [
      ContactModel(
        id: 'contact-local-1',
        userId: userId,
        companyId: 'company-local-1',
        firstName: 'Sarah',
        lastName: 'Johnson',
        phone: '+1 555-1001',
        email: 'sarah.j@acme.example',
        address: '123 Innovation Way, San Francisco, CA',
        category: ContactCategory.client.name,
        tags: const ['decision-maker', 'vip'],
        visitingCardPath: null,
        visitingCardUrl: null,
        notes: [
          ContactNote(
            id: 'note-1',
            content: 'Met at SaaS conference. Interested in enterprise plan.',
            createdAt: now.subtract(const Duration(days: 10)),
          ),
        ],
        followUps: [
          ContactFollowUp(
            id: 'fu-1',
            title: 'Send proposal',
            dueDate: now.add(const Duration(days: 3)),
            status: FollowUpStatus.pending,
            notes: 'Include pricing tiers.',
          ),
        ],
        meetingHistory: [
          ContactMeetingRecord(
            id: 'mh-1',
            title: 'Discovery call',
            meetingDate: now.subtract(const Duration(days: 14)),
            notes: 'Discussed integration requirements.',
          ),
        ],
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(days: 1)),
        companyName: 'Acme Corp',
      ),
      ContactModel(
        id: 'contact-local-2',
        userId: userId,
        companyId: 'company-local-2',
        firstName: 'Marcus',
        lastName: 'Lee',
        phone: '+1 555-1002',
        email: 'marcus@brightideas.example',
        address: '45 Creative Lane, Austin, TX',
        category: ContactCategory.partner.name,
        tags: const ['design'],
        visitingCardPath: null,
        visitingCardUrl: null,
        notes: const [],
        followUps: const [],
        meetingHistory: const [],
        createdAt: now.subtract(const Duration(days: 8)),
        updatedAt: now.subtract(const Duration(days: 3)),
        companyName: 'Bright Ideas Studio',
      ),
      ContactModel(
        id: 'contact-local-3',
        userId: userId,
        companyId: null,
        firstName: 'Elena',
        lastName: 'Vasquez',
        phone: '+1 555-1003',
        email: 'elena.v@gmail.com',
        address: null,
        category: ContactCategory.personal.name,
        tags: const ['networking'],
        visitingCardPath: null,
        visitingCardUrl: null,
        notes: const [],
        followUps: [
          ContactFollowUp(
            id: 'fu-2',
            title: 'Coffee catch-up',
            dueDate: now.subtract(const Duration(days: 2)),
            status: FollowUpStatus.pending,
            notes: '',
          ),
        ],
        meetingHistory: const [],
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(hours: 12)),
        companyName: null,
        birthday: DateTime(now.year - 28, now.month, now.day),
      ),
    ];

    for (final contact in contacts) {
      _contacts[contact.id] = contact;
    }
  }

  String? _companyName(String? companyId) =>
      companyId == null ? null : _companies[companyId]?.name;

  ContactModel _withCompanyName(ContactModel contact) {
    return ContactModel(
      id: contact.id,
      userId: contact.userId,
      companyId: contact.companyId,
      firstName: contact.firstName,
      lastName: contact.lastName,
      phone: contact.phone,
      email: contact.email,
      address: contact.address,
      category: contact.category,
      tags: contact.tags,
      visitingCardPath: contact.visitingCardPath,
      visitingCardUrl: contact.visitingCardUrl,
      notes: contact.notes,
      followUps: contact.followUps,
      meetingHistory: contact.meetingHistory,
      createdAt: contact.createdAt,
      updatedAt: contact.updatedAt,
      companyName: _companyName(contact.companyId),
      birthday: contact.birthday,
    );
  }

  @override
  Future<List<ContactModel>> getContacts({required String userId}) async {
    return _contacts.values
        .where((c) => c.userId == userId || c.userId == 'local-user')
        .map(_withCompanyName)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  @override
  Future<ContactModel> getContactById({required String id}) async {
    final contact = _contacts[id];
    if (contact == null) throw StateError('Contact not found');
    return _withCompanyName(contact);
  }

  @override
  Future<ContactModel> createContact({
    required String userId,
    required CreateContactParams params,
  }) async {
    final now = DateTime.now();
    final id = 'contact-local-${now.microsecondsSinceEpoch}';
    final contact = ContactModel(
      id: id,
      userId: userId,
      companyId: params.companyId,
      firstName: params.firstName.trim(),
      lastName: params.lastName.trim(),
      phone: params.phone,
      email: params.email,
      address: params.address,
      category: params.category,
      tags: params.tags,
      visitingCardPath: null,
      visitingCardUrl: null,
      notes: params.notes,
      followUps: params.followUps,
      meetingHistory: params.meetingHistory,
      birthday: params.birthday,
      createdAt: now,
      updatedAt: now,
    );
    _contacts[id] = contact;
    return _withCompanyName(contact);
  }

  @override
  Future<ContactModel> updateContact({
    required String userId,
    required UpdateContactParams params,
  }) async {
    final existing = await getContactById(id: params.id);
    final updated = ContactModel(
      id: existing.id,
      userId: userId,
      companyId: params.clearCompanyId ? null : params.companyId,
      firstName: params.firstName.trim(),
      lastName: params.lastName.trim(),
      phone: params.phone,
      email: params.email,
      address: params.address,
      category: params.category,
      tags: params.tags,
      visitingCardPath: existing.visitingCardPath,
      visitingCardUrl: existing.visitingCardUrl,
      notes: params.notes,
      followUps: params.followUps,
      meetingHistory: params.meetingHistory,
      birthday: params.clearBirthday ? null : (params.birthday ?? existing.birthday),
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
    );
    _contacts[updated.id] = updated;
    return _withCompanyName(updated);
  }

  @override
  Future<void> deleteContact({required String id}) async {
    _contacts.remove(id);
  }

  @override
  Future<ContactModel> updateVisitingCard({
    required String contactId,
    required String? storagePath,
    required String? publicUrl,
  }) async {
    final existing = await getContactById(id: contactId);
    final updated = ContactModel(
      id: existing.id,
      userId: existing.userId,
      companyId: existing.companyId,
      firstName: existing.firstName,
      lastName: existing.lastName,
      phone: existing.phone,
      email: existing.email,
      address: existing.address,
      category: existing.category,
      tags: existing.tags,
      visitingCardPath: storagePath,
      visitingCardUrl: publicUrl,
      notes: existing.notes,
      followUps: existing.followUps,
      meetingHistory: existing.meetingHistory,
      birthday: existing.birthday,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
    );
    _contacts[updated.id] = updated;
    return _withCompanyName(updated);
  }

  @override
  Future<List<CompanyModel>> getCompanies({required String userId}) async {
    return _companies.values
        .where((c) => c.userId == userId || c.userId == 'local-user')
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  @override
  Future<CompanyModel> getCompanyById({required String id}) async {
    final company = _companies[id];
    if (company == null) throw StateError('Company not found');
    return company;
  }

  @override
  Future<CompanyModel> createCompany({
    required String userId,
    required CreateCompanyParams params,
  }) async {
    final now = DateTime.now();
    final id = 'company-local-${now.microsecondsSinceEpoch}';
    final company = CompanyModel(
      id: id,
      userId: userId,
      name: params.name.trim(),
      industry: params.industry.trim(),
      phone: params.phone,
      email: params.email,
      address: params.address,
      website: params.website,
      tags: params.tags,
      notes: params.notes.trim(),
      createdAt: now,
      updatedAt: now,
    );
    _companies[id] = company;
    return company;
  }

  @override
  Future<CompanyModel> updateCompany({
    required String userId,
    required UpdateCompanyParams params,
  }) async {
    final existing = await getCompanyById(id: params.id);
    final updated = CompanyModel(
      id: existing.id,
      userId: userId,
      name: params.name.trim(),
      industry: params.industry.trim(),
      phone: params.phone,
      email: params.email,
      address: params.address,
      website: params.website,
      tags: params.tags,
      notes: params.notes.trim(),
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
    );
    _companies[updated.id] = updated;
    return updated;
  }

  @override
  Future<void> deleteCompany({required String id}) async {
    _companies.remove(id);
    for (final entry in _contacts.entries) {
      if (entry.value.companyId == id) {
        _contacts[entry.key] = ContactModel(
          id: entry.value.id,
          userId: entry.value.userId,
          companyId: null,
          firstName: entry.value.firstName,
          lastName: entry.value.lastName,
          phone: entry.value.phone,
          email: entry.value.email,
          address: entry.value.address,
          category: entry.value.category,
          tags: entry.value.tags,
          visitingCardPath: entry.value.visitingCardPath,
          visitingCardUrl: entry.value.visitingCardUrl,
          notes: entry.value.notes,
          followUps: entry.value.followUps,
          meetingHistory: entry.value.meetingHistory,
          createdAt: entry.value.createdAt,
          updatedAt: DateTime.now(),
        );
      }
    }
  }
}
