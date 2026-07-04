import 'package:flutter/material.dart';

/// Maps icon name strings from domain entities to [IconData].
IconData dashboardIconForName(String name) {
  return switch (name) {
    'add_task' => Icons.add_task_rounded,
    'note_add' => Icons.note_add_outlined,
    'event' => Icons.event_outlined,
    'flag' => Icons.flag_outlined,
    'groups' => Icons.groups_outlined,
    'analytics' => Icons.analytics_outlined,
    'task_alt' => Icons.task_alt_outlined,
    'timer' => Icons.timer_outlined,
    'trending_up' => Icons.trending_up_rounded,
    'trending_down' => Icons.trending_down_rounded,
    'trending_flat' => Icons.trending_flat_rounded,
    _ => Icons.circle_outlined,
  };
}
