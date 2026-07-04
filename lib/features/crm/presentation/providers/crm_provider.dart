import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:personal_os_dashboard/core/di/core_providers.dart';
import 'package:personal_os_dashboard/core/di/service_locator.dart';
import 'package:personal_os_dashboard/core/error/error_handler.dart';
import 'package:personal_os_dashboard/features/auth/presentation/providers/auth_provider.dart';
import 'package:personal_os_dashboard/features/crm/domain/entities/contact.dart';
import 'package:personal_os_dashboard/features/crm/domain/entities/contact_form_state.dart';
import 'package:personal_os_dashboard/features/crm/domain/entities/contact_params.dart';
import 'package:personal_os_dashboard/features/crm/domain/usecases/crm_usecases.dart';

final getContactsUseCaseProvider = Provider<GetContactsUseCase>((ref) {
  return GetContactsUseCase(ref.watch(crmRepositoryProvider));
});

final getContactByIdUseCaseProvider = Provider<GetContactByIdUseCase>((ref) {
  return GetContactByIdUseCase(ref.watch(crmRepositoryProvider));
});

final createContactUseCaseProvider = Provider<CreateContactUseCase>((ref) {
  return CreateContactUseCase(ref.watch(crmRepositoryProvider));
});

final updateContactUseCaseProvider = Provider<UpdateContactUseCase>((ref) {
  return UpdateContactUseCase(ref.watch(crmRepositoryProvider));
});

final deleteContactUseCaseProvider = Provider<DeleteContactUseCase>((ref) {
  return DeleteContactUseCase(ref.watch(crmRepositoryProvider));
});

final uploadVisitingCardUseCaseProvider =
    Provider<UploadVisitingCardUseCase>((ref) {
  return UploadVisitingCardUseCase(ref.watch(crmRepositoryProvider));
});

final getCompaniesUseCaseProvider = Provider<GetCompaniesUseCase>((ref) {
  return GetCompaniesUseCase(ref.watch(crmRepositoryProvider));
});

final getCompanyByIdUseCaseProvider = Provider<GetCompanyByIdUseCase>((ref) {
  return GetCompanyByIdUseCase(ref.watch(crmRepositoryProvider));
});

final createCompanyUseCaseProvider = Provider<CreateCompanyUseCase>((ref) {
  return CreateCompanyUseCase(ref.watch(crmRepositoryProvider));
});

final updateCompanyUseCaseProvider = Provider<UpdateCompanyUseCase>((ref) {
  return UpdateCompanyUseCase(ref.watch(crmRepositoryProvider));
});

final deleteCompanyUseCaseProvider = Provider<DeleteCompanyUseCase>((ref) {
  return DeleteCompanyUseCase(ref.watch(crmRepositoryProvider));
});

final crmSearchQueryProvider = StateProvider<String>((ref) => '');

final crmListTabProvider =
    StateProvider<CrmListTab>((ref) => CrmListTab.contacts);

final contactFilterProvider =
    StateProvider<ContactFilter>((ref) => ContactFilter.empty);

final contactSortProvider = StateProvider<ContactSortOption>(
  (ref) => ContactSortOption.recentlyUpdated,
);

final contactsListProvider =
    AsyncNotifierProvider<ContactsListController, List<Contact>>(
  ContactsListController.new,
);

class ContactsListController extends AsyncNotifier<List<Contact>> {
  @override
  Future<List<Contact>> build() => _load();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<List<Contact>> _load() async {
    final userId = ref.read(currentUserProvider)?.id ?? 'local-user';
    final result = await ref.read(getContactsUseCaseProvider).call(userId);
    return result.when(
      success: (contacts) => contacts,
      onFailure: (f) => throw sl<ErrorHandler>().getUserMessage(f),
    );
  }
}

final companiesListProvider =
    AsyncNotifierProvider<CompaniesListController, List<Company>>(
  CompaniesListController.new,
);

class CompaniesListController extends AsyncNotifier<List<Company>> {
  @override
  Future<List<Company>> build() => _load();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<List<Company>> _load() async {
    final userId = ref.read(currentUserProvider)?.id ?? 'local-user';
    final result = await ref.read(getCompaniesUseCaseProvider).call(userId);
    return result.when(
      success: (companies) => companies,
      onFailure: (f) => throw sl<ErrorHandler>().getUserMessage(f),
    );
  }
}

final filteredContactsProvider = Provider<List<Contact>>((ref) {
  final contacts = ref.watch(contactsListProvider).maybeWhen(
        data: (value) => value,
        orElse: () => const <Contact>[],
      );
  final query = ref.watch(crmSearchQueryProvider).trim().toLowerCase();
  final filter = ref.watch(contactFilterProvider);
  final sort = ref.watch(contactSortProvider);

  var result = contacts.where((contact) {
    final matchesSearch = query.isEmpty ||
        contact.fullName.toLowerCase().contains(query) ||
        contact.email?.toLowerCase().contains(query) == true ||
        contact.phone?.toLowerCase().contains(query) == true ||
        contact.companyName?.toLowerCase().contains(query) == true ||
        contact.tags.any((t) => t.toLowerCase().contains(query));

    final matchesCategory =
        filter.category == null || contact.category == filter.category;
    final matchesCompany =
        filter.companyId == null || contact.companyId == filter.companyId;
    final matchesTag = filter.tag == null ||
        filter.tag!.isEmpty ||
        contact.tags.any((t) => t.toLowerCase() == filter.tag!.toLowerCase());

    return matchesSearch && matchesCategory && matchesCompany && matchesTag;
  }).toList();

  result = List<Contact>.from(result)
    ..sort((a, b) => _compareContacts(a, b, sort));

  return result;
});

final filteredCompaniesProvider = Provider<List<Company>>((ref) {
  final companies = ref.watch(companiesListProvider).maybeWhen(
        data: (value) => value,
        orElse: () => const <Company>[],
      );
  final query = ref.watch(crmSearchQueryProvider).trim().toLowerCase();

  return companies.where((company) {
    if (query.isEmpty) return true;
    return company.name.toLowerCase().contains(query) ||
        company.industry.toLowerCase().contains(query) ||
        company.email?.toLowerCase().contains(query) == true ||
        company.tags.any((t) => t.toLowerCase().contains(query));
  }).toList();
});

int _compareContacts(Contact a, Contact b, ContactSortOption sort) {
  return switch (sort) {
    ContactSortOption.nameAsc =>
      a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()),
    ContactSortOption.recentlyUpdated =>
      b.updatedAt.compareTo(a.updatedAt),
    ContactSortOption.categoryAsc =>
      a.category.label.compareTo(b.category.label),
  };
}

final contactFormControllerProvider =
    NotifierProvider<ContactFormController, ContactFormState>(
  ContactFormController.new,
);

class ContactFormController extends Notifier<ContactFormState> {
  @override
  ContactFormState build() => const ContactFormIdle();

  Future<bool> createContact(CreateContactParams params) async {
    state = const ContactFormLoading();
    final userId = ref.read(currentUserProvider)?.id ?? 'local-user';
    final result = await ref.read(createContactUseCaseProvider).call(
          CreateContactRequest(userId: userId, contact: params),
        );
    return result.when(
      success: (_) {
        state = const ContactFormSuccess(message: 'Contact created.');
        ref.invalidate(contactsListProvider);
        return true;
      },
      onFailure: (f) {
        state = ContactFormError(sl<ErrorHandler>().getUserMessage(f));
        return false;
      },
    );
  }

  Future<bool> updateContact(UpdateContactParams params) async {
    state = const ContactFormLoading();
    final userId = ref.read(currentUserProvider)?.id ?? 'local-user';
    final result = await ref.read(updateContactUseCaseProvider).call(
          UpdateContactRequest(userId: userId, contact: params),
        );
    return result.when(
      success: (_) {
        state = const ContactFormSuccess(message: 'Contact updated.');
        ref.invalidate(contactsListProvider);
        ref.invalidate(contactDetailProvider(params.id));
        return true;
      },
      onFailure: (f) {
        state = ContactFormError(sl<ErrorHandler>().getUserMessage(f));
        return false;
      },
    );
  }

  Future<bool> deleteContact(String id) async {
    state = const ContactFormLoading();
    final result = await ref.read(deleteContactUseCaseProvider).call(id);
    return result.when(
      success: (_) {
        state = const ContactFormSuccess(message: 'Contact deleted.');
        ref.invalidate(contactsListProvider);
        return true;
      },
      onFailure: (f) {
        state = ContactFormError(sl<ErrorHandler>().getUserMessage(f));
        return false;
      },
    );
  }

  Future<bool> uploadVisitingCard({
    required String contactId,
    required List<int> bytes,
    required String fileName,
    String? contentType,
  }) async {
    state = const ContactFormLoading();
    final userId = ref.read(currentUserProvider)?.id ?? 'local-user';
    final result = await ref.read(uploadVisitingCardUseCaseProvider).call((
      userId: userId,
      contactId: contactId,
      bytes: bytes is Uint8List ? bytes : Uint8List.fromList(bytes),
      fileName: fileName,
      contentType: contentType,
    ));
    return result.when(
      success: (_) {
        state = const ContactFormSuccess(message: 'Visiting card uploaded.');
        ref.invalidate(contactsListProvider);
        ref.invalidate(contactDetailProvider(contactId));
        return true;
      },
      onFailure: (f) {
        state = ContactFormError(sl<ErrorHandler>().getUserMessage(f));
        return false;
      },
    );
  }

  void clearStatus() => state = const ContactFormIdle();
}

final companyFormControllerProvider =
    NotifierProvider<CompanyFormController, CompanyFormState>(
  CompanyFormController.new,
);

class CompanyFormController extends Notifier<CompanyFormState> {
  @override
  CompanyFormState build() => const CompanyFormIdle();

  Future<bool> createCompany(CreateCompanyParams params) async {
    state = const CompanyFormLoading();
    final userId = ref.read(currentUserProvider)?.id ?? 'local-user';
    final result = await ref.read(createCompanyUseCaseProvider).call(
          CreateCompanyRequest(userId: userId, company: params),
        );
    return result.when(
      success: (_) {
        state = const CompanyFormSuccess(message: 'Company created.');
        ref.invalidate(companiesListProvider);
        ref.invalidate(contactsListProvider);
        return true;
      },
      onFailure: (f) {
        state = CompanyFormError(sl<ErrorHandler>().getUserMessage(f));
        return false;
      },
    );
  }

  Future<bool> updateCompany(UpdateCompanyParams params) async {
    state = const CompanyFormLoading();
    final userId = ref.read(currentUserProvider)?.id ?? 'local-user';
    final result = await ref.read(updateCompanyUseCaseProvider).call(
          UpdateCompanyRequest(userId: userId, company: params),
        );
    return result.when(
      success: (_) {
        state = const CompanyFormSuccess(message: 'Company updated.');
        ref.invalidate(companiesListProvider);
        ref.invalidate(contactsListProvider);
        return true;
      },
      onFailure: (f) {
        state = CompanyFormError(sl<ErrorHandler>().getUserMessage(f));
        return false;
      },
    );
  }

  Future<bool> deleteCompany(String id) async {
    state = const CompanyFormLoading();
    final result = await ref.read(deleteCompanyUseCaseProvider).call(id);
    return result.when(
      success: (_) {
        state = const CompanyFormSuccess(message: 'Company deleted.');
        ref.invalidate(companiesListProvider);
        ref.invalidate(contactsListProvider);
        return true;
      },
      onFailure: (f) {
        state = CompanyFormError(sl<ErrorHandler>().getUserMessage(f));
        return false;
      },
    );
  }

  void clearStatus() => state = const CompanyFormIdle();
}

final contactDetailProvider =
    FutureProvider.family<Contact, String>((ref, id) async {
  final result = await ref.read(getContactByIdUseCaseProvider).call(id);
  return result.when(
    success: (contact) => contact,
    onFailure: (f) => throw sl<ErrorHandler>().getUserMessage(f),
  );
});

final companyDetailProvider =
    FutureProvider.family<Company, String>((ref, id) async {
  final result = await ref.read(getCompanyByIdUseCaseProvider).call(id);
  return result.when(
    success: (company) => company,
    onFailure: (f) => throw sl<ErrorHandler>().getUserMessage(f),
  );
});
