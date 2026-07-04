import 'dart:convert';

import 'package:personal_os_dashboard/features/meetings/domain/entities/meeting.dart';

final class MeetingModel {
  const MeetingModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.agenda,
    required this.participants,
    required this.startTime,
    required this.durationMinutes,
    required this.location,
    required this.notes,
    required this.followUp,
    required this.attachments,
    required this.reminderAt,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String title;
  final String agenda;
  final List<MeetingParticipant> participants;
  final DateTime startTime;
  final int durationMinutes;
  final String? location;
  final String notes;
  final String followUp;
  final List<MeetingAttachment> attachments;
  final DateTime? reminderAt;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    return MeetingModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      agenda: json['agenda']?.toString() ?? '',
      participants: _parseParticipants(json['participants']),
      startTime: _parseDate(json['start_time']) ?? DateTime.now(),
      durationMinutes: json['duration_minutes'] as int? ??
          json['attendee_count'] as int? ??
          30,
      location: json['location']?.toString(),
      notes: json['notes']?.toString() ?? '',
      followUp: json['follow_up']?.toString() ?? '',
      attachments: _parseAttachments(json['attachments']),
      reminderAt: _parseDate(json['reminder_at']),
      status: json['status']?.toString() ?? 'scheduled',
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updated_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toInsertJson(String userId) {
    final now = DateTime.now().toIso8601String();
    return {
      'user_id': userId,
      'title': title,
      'agenda': agenda,
      'participants': participants.map(MeetingModel.participantToJson).toList(),
      'start_time': startTime.toIso8601String(),
      'duration_minutes': durationMinutes,
      'location': location,
      'attendee_count': participants.length,
      'notes': notes,
      'follow_up': followUp,
      'attachments': attachments.map(MeetingModel.attachmentToJson).toList(),
      'reminder_at': reminderAt?.toIso8601String(),
      'status': status,
      'created_at': now,
      'updated_at': now,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'title': title,
      'agenda': agenda,
      'participants': participants.map(MeetingModel.participantToJson).toList(),
      'start_time': startTime.toIso8601String(),
      'duration_minutes': durationMinutes,
      'location': location,
      'attendee_count': participants.length,
      'notes': notes,
      'follow_up': followUp,
      'attachments': attachments.map(MeetingModel.attachmentToJson).toList(),
      'reminder_at': reminderAt?.toIso8601String(),
      'status': status,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  Meeting toEntity() {
    return Meeting(
      id: id,
      userId: userId,
      title: title,
      agenda: agenda,
      participants: participants,
      startTime: startTime,
      durationMinutes: durationMinutes,
      location: location,
      notes: notes,
      followUp: followUp,
      attachments: attachments,
      reminderAt: reminderAt,
      status: MeetingStatus.fromString(status),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static List<MeetingParticipant> _parseParticipants(dynamic value) {
    if (value == null) return const [];
    List<dynamic> items;
    if (value is String) {
      items = jsonDecode(value) as List<dynamic>? ?? [];
    } else if (value is List) {
      items = value;
    } else {
      return const [];
    }
    return items.map((item) {
      final map = item as Map<String, dynamic>;
      return MeetingParticipant(
        id: map['id']?.toString() ?? '',
        name: map['name']?.toString() ?? '',
        email: map['email']?.toString() ?? '',
        role: map['role']?.toString() ?? 'Attendee',
      );
    }).toList();
  }

  static List<MeetingAttachment> _parseAttachments(dynamic value) {
    if (value == null) return const [];
    List<dynamic> items;
    if (value is String) {
      items = jsonDecode(value) as List<dynamic>? ?? [];
    } else if (value is List) {
      items = value;
    } else {
      return const [];
    }
    return items.map((item) {
      final map = item as Map<String, dynamic>;
      return MeetingAttachment(
        id: map['id']?.toString() ?? '',
        name: map['name']?.toString() ?? '',
        storagePath: map['storage_path']?.toString() ?? '',
        mimeType: map['mime_type']?.toString() ?? 'application/octet-stream',
      );
    }).toList();
  }

  static Map<String, dynamic> participantToJson(MeetingParticipant p) {
    return {
      'id': p.id,
      'name': p.name,
      'email': p.email,
      'role': p.role,
    };
  }

  static Map<String, dynamic> attachmentToJson(MeetingAttachment a) {
    return {
      'id': a.id,
      'name': a.name,
      'storage_path': a.storagePath,
      'mime_type': a.mimeType,
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
