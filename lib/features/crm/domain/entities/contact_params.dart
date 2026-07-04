import 'package:personal_os_dashboard/features/crm/domain/entities/contact.dart';

/// Parameters for creating a contact.
final class CreateContactParams {
  const CreateContactParams({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.address,
    required this.category,
    required this.tags,
    required this.companyId,
    required this.notes,
    required this.followUps,
    required this.meetingHistory,
  });

  final String firstName;
  final String lastName;
  final String? phone;
  final String? email;
  final String? address;
  final String category;
  final List<String> tags;
  final String? companyId;
  final List<ContactNote> notes;
  final List<ContactFollowUp> followUps;
  final List<ContactMeetingRecord> meetingHistory;
}

/// Parameters for updating a contact.
final class UpdateContactParams {
  const UpdateContactParams({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.address,
    required this.category,
    required this.tags,
    required this.companyId,
    required this.notes,
    required this.followUps,
    required this.meetingHistory,
    this.clearCompanyId = false,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? email;
  final String? address;
  final String category;
  final List<String> tags;
  final String? companyId;
  final List<ContactNote> notes;
  final List<ContactFollowUp> followUps;
  final List<ContactMeetingRecord> meetingHistory;
  final bool clearCompanyId;
}

/// Parameters for creating a company.
final class CreateCompanyParams {
  const CreateCompanyParams({
    required this.name,
    required this.industry,
    required this.phone,
    required this.email,
    required this.address,
    required this.website,
    required this.tags,
    required this.notes,
  });

  final String name;
  final String industry;
  final String? phone;
  final String? email;
  final String? address;
  final String? website;
  final List<String> tags;
  final String notes;
}

/// Parameters for updating a company.
final class UpdateCompanyParams {
  const UpdateCompanyParams({
    required this.id,
    required this.name,
    required this.industry,
    required this.phone,
    required this.email,
    required this.address,
    required this.website,
    required this.tags,
    required this.notes,
  });

  final String id;
  final String name;
  final String industry;
  final String? phone;
  final String? email;
  final String? address;
  final String? website;
  final List<String> tags;
  final String notes;
}

enum CrmListTab {
  contacts('Contacts'),
  companies('Companies');

  const CrmListTab(this.label);

  final String label;
}

final class ContactFilter {
  const ContactFilter({
    this.category,
    this.companyId,
    this.tag,
  });

  final ContactCategory? category;
  final String? companyId;
  final String? tag;

  static const ContactFilter empty = ContactFilter();

  ContactFilter copyWith({
    ContactCategory? category,
    String? companyId,
    String? tag,
    bool clearCategory = false,
    bool clearCompanyId = false,
    bool clearTag = false,
  }) {
    return ContactFilter(
      category: clearCategory ? null : (category ?? this.category),
      companyId: clearCompanyId ? null : (companyId ?? this.companyId),
      tag: clearTag ? null : (tag ?? this.tag),
    );
  }

  bool get hasActiveFilters =>
      category != null || companyId != null || (tag != null && tag!.isNotEmpty);
}

enum ContactSortOption {
  nameAsc('Name (A–Z)'),
  recentlyUpdated('Recently updated'),
  categoryAsc('Category');

  const ContactSortOption(this.label);

  final String label;
}
