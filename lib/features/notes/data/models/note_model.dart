import 'dart:convert';

import 'package:personal_os_dashboard/features/notes/domain/entities/note.dart';

final class NoteModel {
  const NoteModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.type,
    required this.checklist,
    required this.category,
    required this.tags,
    required this.images,
    required this.documents,
    required this.isPinned,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String title;
  final String content;
  final String type;
  final List<NoteChecklistItem> checklist;
  final String category;
  final List<String> tags;
  final List<NoteAttachment> images;
  final List<NoteAttachment> documents;
  final bool isPinned;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      type: json['note_type']?.toString() ?? 'text',
      checklist: _parseChecklist(json['checklist']),
      category: json['category']?.toString() ?? 'other',
      tags: _parseStringList(json['tags']),
      images: _parseAttachments(json['images'], isImage: true),
      documents: _parseAttachments(json['documents'], isImage: false),
      isPinned: json['is_pinned'] == true,
      isArchived: json['is_archived'] == true,
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updated_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toInsertJson(String userId) {
    final now = DateTime.now().toIso8601String();
    return {
      'user_id': userId,
      'title': title,
      'content': content,
      'note_type': type,
      'checklist': checklist.map(checklistToJson).toList(),
      'category': category,
      'tags': tags,
      'images': images.map(attachmentToJson).toList(),
      'documents': documents.map(attachmentToJson).toList(),
      'is_pinned': isPinned,
      'is_archived': isArchived,
      'created_at': now,
      'updated_at': now,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'title': title,
      'content': content,
      'note_type': type,
      'checklist': checklist.map(checklistToJson).toList(),
      'category': category,
      'tags': tags,
      'images': images.map(attachmentToJson).toList(),
      'documents': documents.map(attachmentToJson).toList(),
      'is_pinned': isPinned,
      'is_archived': isArchived,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  Note toEntity() => Note(
        id: id,
        userId: userId,
        title: title,
        content: content,
        type: NoteType.fromString(type),
        checklist: checklist,
        category: NoteCategory.fromString(category),
        tags: tags,
        images: images,
        documents: documents,
        isPinned: isPinned,
        isArchived: isArchived,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

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

  static List<NoteChecklistItem> _parseChecklist(dynamic value) {
    if (value == null) return const [];
    List<dynamic> items;
    if (value is String) {
      items = jsonDecode(value) as List<dynamic>? ?? [];
    } else if (value is List) {
      items = value;
    } else {
      return const [];
    }
    return items
        .map(
          (e) => NoteChecklistItem(
            id: (e as Map)['id']?.toString() ?? '',
            text: e['text']?.toString() ?? '',
            isChecked: e['is_checked'] == true || e['isChecked'] == true,
          ),
        )
        .toList();
  }

  static List<NoteAttachment> _parseAttachments(
    dynamic value, {
    required bool isImage,
  }) {
    if (value == null) return const [];
    List<dynamic> items;
    if (value is String) {
      items = jsonDecode(value) as List<dynamic>? ?? [];
    } else if (value is List) {
      items = value;
    } else {
      return const [];
    }
    return items
        .map(
          (e) => NoteAttachment(
            id: (e as Map)['id']?.toString() ?? '',
            name: e['name']?.toString() ?? '',
            storagePath: e['storage_path']?.toString() ?? '',
            publicUrl: e['public_url']?.toString() ?? '',
            mimeType: e['mime_type']?.toString() ?? '',
            isImage: isImage,
          ),
        )
        .toList();
  }

  static Map<String, dynamic> checklistToJson(NoteChecklistItem item) => {
        'id': item.id,
        'text': item.text,
        'is_checked': item.isChecked,
      };

  static Map<String, dynamic> attachmentToJson(NoteAttachment attachment) => {
        'id': attachment.id,
        'name': attachment.name,
        'storage_path': attachment.storagePath,
        'public_url': attachment.publicUrl,
        'mime_type': attachment.mimeType,
      };

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
