import 'package:personal_os_dashboard/core/domain/entities/entity.dart';

/// Contact category for CRM segmentation.
enum ContactCategory {
  client('Client'),
  prospect('Prospect'),
  partner('Partner'),
  vendor('Vendor'),
  personal('Personal'),
  other('Other');

  const ContactCategory(this.label);

  final String label;

  static ContactCategory fromString(String? value) {
    return ContactCategory.values.firstWhere(
      (c) => c.name == value?.toLowerCase(),
      orElse: () => ContactCategory.other,
    );
  }
}

/// Follow-up status.
enum FollowUpStatus {
  pending('Pending'),
  completed('Completed'),
  overdue('Overdue');

  const FollowUpStatus(this.label);

  final String label;

  static FollowUpStatus fromString(String? value) {
    return FollowUpStatus.values.firstWhere(
      (s) => s.name == value?.toLowerCase(),
      orElse: () => FollowUpStatus.pending,
    );
  }
}

/// Note attached to a contact.
final class ContactNote extends Entity {
  const ContactNote({
    required this.id,
    required this.content,
    required this.createdAt,
  });

  final String id;
  final String content;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, content, createdAt];
}

/// Follow-up task for a contact.
final class ContactFollowUp extends Entity {
  const ContactFollowUp({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.status,
    required this.notes,
  });

  final String id;
  final String title;
  final DateTime? dueDate;
  final FollowUpStatus status;
  final String notes;

  bool get isOverdue {
    if (dueDate == null || status == FollowUpStatus.completed) return false;
    return dueDate!.isBefore(DateTime.now());
  }

  @override
  List<Object?> get props => [id, title, dueDate, status, notes];
}

/// Meeting record linked to a contact.
final class ContactMeetingRecord extends Entity {
  const ContactMeetingRecord({
    required this.id,
    required this.title,
    required this.meetingDate,
    required this.notes,
    this.meetingId,
  });

  final String id;
  final String? meetingId;
  final String title;
  final DateTime meetingDate;
  final String notes;

  @override
  List<Object?> get props => [id, meetingId, title, meetingDate, notes];
}

/// CRM contact entity.
final class Contact extends Entity {
  const Contact({
    required this.id,
    required this.userId,
    required this.companyId,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.address,
    required this.category,
    required this.tags,
    required this.visitingCardPath,
    required this.visitingCardUrl,
    required this.notes,
    required this.followUps,
    required this.meetingHistory,
    required this.companyName,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String? companyId;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? email;
  final String? address;
  final ContactCategory category;
  final List<String> tags;
  final String? visitingCardPath;
  final String? visitingCardUrl;
  final List<ContactNote> notes;
  final List<ContactFollowUp> followUps;
  final List<ContactMeetingRecord> meetingHistory;
  final String? companyName;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get fullName {
    if (lastName.isEmpty) return firstName;
    return '$firstName $lastName';
  }

  bool get hasVisitingCard =>
      visitingCardPath != null && visitingCardPath!.isNotEmpty;

  Contact copyWith({
    String? id,
    String? userId,
    String? companyId,
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? address,
    ContactCategory? category,
    List<String>? tags,
    String? visitingCardPath,
    String? visitingCardUrl,
    List<ContactNote>? notes,
    List<ContactFollowUp>? followUps,
    List<ContactMeetingRecord>? meetingHistory,
    String? companyName,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearCompanyId = false,
    bool clearVisitingCard = false,
  }) {
    return Contact(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      companyId: clearCompanyId ? null : (companyId ?? this.companyId),
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      visitingCardPath:
          clearVisitingCard ? null : (visitingCardPath ?? this.visitingCardPath),
      visitingCardUrl:
          clearVisitingCard ? null : (visitingCardUrl ?? this.visitingCardUrl),
      notes: notes ?? this.notes,
      followUps: followUps ?? this.followUps,
      meetingHistory: meetingHistory ?? this.meetingHistory,
      companyName: clearCompanyId ? null : (companyName ?? this.companyName),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        companyId,
        firstName,
        lastName,
        phone,
        email,
        address,
        category,
        tags,
        visitingCardPath,
        visitingCardUrl,
        notes,
        followUps,
        meetingHistory,
        companyName,
        createdAt,
        updatedAt,
      ];
}

/// CRM company entity.
final class Company extends Entity {
  const Company({
    required this.id,
    required this.userId,
    required this.name,
    required this.industry,
    required this.phone,
    required this.email,
    required this.address,
    required this.website,
    required this.tags,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String name;
  final String industry;
  final String? phone;
  final String? email;
  final String? address;
  final String? website;
  final List<String> tags;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        industry,
        phone,
        email,
        address,
        website,
        tags,
        notes,
        createdAt,
        updatedAt,
      ];
}
