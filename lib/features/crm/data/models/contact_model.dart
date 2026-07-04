import 'dart:convert';

import 'package:personal_os_dashboard/features/crm/domain/entities/contact.dart';

final class ContactModel {
  const ContactModel({
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
    required this.createdAt,
    required this.updatedAt,
    this.companyName,
    this.birthday,
  });

  final String id;
  final String userId;
  final String? companyId;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? email;
  final String? address;
  final String category;
  final List<String> tags;
  final String? visitingCardPath;
  final String? visitingCardUrl;
  final List<ContactNote> notes;
  final List<ContactFollowUp> followUps;
  final List<ContactMeetingRecord> meetingHistory;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? companyName;
  final DateTime? birthday;

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      companyId: json['company_id']?.toString(),
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      address: json['address']?.toString(),
      category: json['category']?.toString() ?? 'other',
      tags: _parseStringList(json['tags']),
      visitingCardPath: json['visiting_card_path']?.toString(),
      visitingCardUrl: json['visiting_card_url']?.toString(),
      notes: _parseNotes(json['contact_notes']),
      followUps: _parseFollowUps(json['follow_ups']),
      meetingHistory: _parseMeetings(json['meeting_history']),
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updated_at']) ?? DateTime.now(),
      companyName: json['company_name']?.toString(),
      birthday: _parseDate(json['birthday']),
    );
  }

  Map<String, dynamic> toInsertJson(String userId) {
    final now = DateTime.now().toIso8601String();
    return {
      'user_id': userId,
      'company_id': companyId,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'email': email,
      'address': address,
      'category': category,
      'tags': tags,
      'visiting_card_path': visitingCardPath,
      'visiting_card_url': visitingCardUrl,
      'contact_notes': notes.map(noteToJson).toList(),
      'follow_ups': followUps.map(followUpToJson).toList(),
      'meeting_history': meetingHistory.map(meetingToJson).toList(),
      'birthday': birthday?.toIso8601String(),
      'created_at': now,
      'updated_at': now,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'company_id': companyId,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'email': email,
      'address': address,
      'category': category,
      'tags': tags,
      'visiting_card_path': visitingCardPath,
      'visiting_card_url': visitingCardUrl,
      'contact_notes': notes.map(noteToJson).toList(),
      'follow_ups': followUps.map(followUpToJson).toList(),
      'meeting_history': meetingHistory.map(meetingToJson).toList(),
      'birthday': birthday?.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  Contact toEntity() {
    return Contact(
      id: id,
      userId: userId,
      companyId: companyId,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      email: email,
      address: address,
      category: ContactCategory.fromString(category),
      tags: tags,
      visitingCardPath: visitingCardPath,
      visitingCardUrl: visitingCardUrl,
      notes: notes,
      followUps: followUps,
      meetingHistory: meetingHistory,
      companyName: companyName,
      birthday: birthday,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return const [];
    if (value is List) return value.map((e) => e.toString()).toList();
    if (value is String) {
      return (jsonDecode(value) as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [];
    }
    return const [];
  }

  static List<ContactNote> _parseNotes(dynamic value) =>
      _parseList(value, (m) => ContactNote(
            id: m['id']?.toString() ?? '',
            content: m['content']?.toString() ?? '',
            createdAt: _parseDate(m['created_at']) ?? DateTime.now(),
          ));

  static List<ContactFollowUp> _parseFollowUps(dynamic value) =>
      _parseList(value, (m) => ContactFollowUp(
            id: m['id']?.toString() ?? '',
            title: m['title']?.toString() ?? '',
            dueDate: _parseDate(m['due_date']),
            status: FollowUpStatus.fromString(m['status']?.toString()),
            notes: m['notes']?.toString() ?? '',
          ));

  static List<ContactMeetingRecord> _parseMeetings(dynamic value) =>
      _parseList(value, (m) => ContactMeetingRecord(
            id: m['id']?.toString() ?? '',
            meetingId: m['meeting_id']?.toString(),
            title: m['title']?.toString() ?? '',
            meetingDate: _parseDate(m['meeting_date']) ?? DateTime.now(),
            notes: m['notes']?.toString() ?? '',
          ));

  static List<T> _parseList<T>(
    dynamic value,
    T Function(Map<String, dynamic>) map,
  ) {
    if (value == null) return const [];
    List<dynamic> items;
    if (value is String) {
      items = jsonDecode(value) as List<dynamic>? ?? [];
    } else if (value is List) {
      items = value;
    } else {
      return const [];
    }
    return items.map((e) => map(e as Map<String, dynamic>)).toList();
  }

  static Map<String, dynamic> noteToJson(ContactNote note) => {
        'id': note.id,
        'content': note.content,
        'created_at': note.createdAt.toIso8601String(),
      };

  static Map<String, dynamic> followUpToJson(ContactFollowUp f) => {
        'id': f.id,
        'title': f.title,
        'due_date': f.dueDate?.toIso8601String(),
        'status': f.status.name,
        'notes': f.notes,
      };

  static Map<String, dynamic> meetingToJson(ContactMeetingRecord m) => {
        'id': m.id,
        'meeting_id': m.meetingId,
        'title': m.title,
        'meeting_date': m.meetingDate.toIso8601String(),
        'notes': m.notes,
      };

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}

final class CompanyModel {
  const CompanyModel({
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

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      industry: json['industry']?.toString() ?? '',
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      address: json['address']?.toString(),
      website: json['website']?.toString(),
      tags: ContactModel._parseStringList(json['tags']),
      notes: json['notes']?.toString() ?? '',
      createdAt: ContactModel._parseDate(json['created_at']) ?? DateTime.now(),
      updatedAt: ContactModel._parseDate(json['updated_at']) ?? DateTime.now(),
    );
  }

  Company toEntity() => Company(
        id: id,
        userId: userId,
        name: name,
        industry: industry,
        phone: phone,
        email: email,
        address: address,
        website: website,
        tags: tags,
        notes: notes,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
