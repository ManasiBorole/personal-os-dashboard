import 'package:flutter/material.dart';
import 'package:personal_os_dashboard/features/notes/domain/entities/note.dart';

/// Category accent colors for note cards.
abstract final class NoteCategoryColors {
  static Color color(NoteCategory category) {
    return switch (category) {
      NoteCategory.personal => const Color(0xFF7C4DFF),
      NoteCategory.work => const Color(0xFF2196F3),
      NoteCategory.ideas => const Color(0xFFFF9800),
      NoteCategory.meeting => const Color(0xFF009688),
      NoteCategory.research => const Color(0xFF4CAF50),
      NoteCategory.other => const Color(0xFF9E9E9E),
    };
  }
}
