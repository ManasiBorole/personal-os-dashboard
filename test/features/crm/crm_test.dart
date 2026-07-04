import 'package:flutter_test/flutter_test.dart';

import 'package:personal_os_dashboard/features/crm/data/datasources/local_crm_data_source.dart';
import 'package:personal_os_dashboard/features/crm/data/repositories/crm_repository_impl.dart';
import 'package:personal_os_dashboard/features/crm/domain/entities/contact.dart';
import 'package:personal_os_dashboard/features/crm/domain/entities/contact_params.dart';
import 'package:personal_os_dashboard/features/crm/domain/usecases/crm_usecases.dart';

void main() {
  late CrmRepositoryImpl repository;

  setUp(() {
    repository = CrmRepositoryImpl(LocalCrmDataSource());
  });

  group('CRM use cases', () {
    test('loads seeded contacts for local user', () async {
      final result = await GetContactsUseCase(repository).call('local-user');

      expect(result.isSuccess, isTrue);
      result.when(
        success: (contacts) => expect(contacts.length, greaterThanOrEqualTo(3)),
        onFailure: (_) => fail('Expected success'),
      );
    });

    test('loads seeded companies for local user', () async {
      final result = await GetCompaniesUseCase(repository).call('local-user');

      expect(result.isSuccess, isTrue);
      result.when(
        success: (companies) =>
            expect(companies.length, greaterThanOrEqualTo(2)),
        onFailure: (_) => fail('Expected success'),
      );
    });

    test('creates, updates, and deletes a contact', () async {
      const userId = 'test-user';

      final createResult = await CreateContactUseCase(repository).call(
        CreateContactRequest(
          userId: userId,
          contact: CreateContactParams(
            firstName: 'Test',
            lastName: 'User',
            phone: '+1 555-9999',
            email: 'test@example.com',
            address: '123 Test St',
            category: ContactCategory.prospect.name,
            tags: const ['test'],
            companyId: null,
            notes: const [],
            followUps: const [],
            meetingHistory: const [],
          ),
        ),
      );

      late String contactId;
      createResult.when(
        success: (contact) {
          contactId = contact.id;
          expect(contact.fullName, 'Test User');
          expect(contact.category, ContactCategory.prospect);
        },
        onFailure: (_) => fail('Create failed'),
      );

      final updateResult = await UpdateContactUseCase(repository).call(
        UpdateContactRequest(
          userId: userId,
          contact: UpdateContactParams(
            id: contactId,
            firstName: 'Updated',
            lastName: 'Contact',
            phone: '+1 555-8888',
            email: 'updated@example.com',
            address: null,
            category: ContactCategory.client.name,
            tags: const ['updated'],
            companyId: null,
            notes: [
              ContactNote(
                id: 'note-test',
                content: 'Test note',
                createdAt: DateTime.now(),
              ),
            ],
            followUps: const [],
            meetingHistory: const [],
            clearCompanyId: true,
          ),
        ),
      );

      updateResult.when(
        success: (contact) {
          expect(contact.firstName, 'Updated');
          expect(contact.notes.length, 1);
        },
        onFailure: (_) => fail('Update failed'),
      );

      final deleteResult =
          await DeleteContactUseCase(repository).call(contactId);
      expect(deleteResult.isSuccess, isTrue);
    });

    test('creates and deletes a company', () async {
      const userId = 'test-user';

      final createResult = await CreateCompanyUseCase(repository).call(
        CreateCompanyRequest(
          userId: userId,
          company: const CreateCompanyParams(
            name: 'Test Co',
            industry: 'Testing',
            phone: '+1 555-0000',
            email: 'co@test.com',
            address: '456 Co Ave',
            website: 'https://test.co',
            tags: ['qa'],
            notes: 'Test company',
          ),
        ),
      );

      late String companyId;
      createResult.when(
        success: (company) {
          companyId = company.id;
          expect(company.name, 'Test Co');
        },
        onFailure: (_) => fail('Create failed'),
      );

      final deleteResult =
          await DeleteCompanyUseCase(repository).call(companyId);
      expect(deleteResult.isSuccess, isTrue);
    });
  });
}
