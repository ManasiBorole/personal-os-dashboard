import 'package:flutter/material.dart';

import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/features/tasks/domain/entities/task.dart';

/// Editable checklist for task forms.
class TaskChecklistWidget extends StatefulWidget {
  const TaskChecklistWidget({
    required this.items,
    required this.onChanged,
    this.readOnly = false,
    super.key,
  });

  final List<ChecklistItem> items;
  final ValueChanged<List<ChecklistItem>> onChanged;
  final bool readOnly;

  @override
  State<TaskChecklistWidget> createState() => _TaskChecklistWidgetState();
}

class _TaskChecklistWidgetState extends State<TaskChecklistWidget> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addItem() {
    final title = _controller.text.trim();
    if (title.isEmpty) return;

    final id = 'cl-${DateTime.now().microsecondsSinceEpoch}';
    widget.onChanged([
      ...widget.items,
      ChecklistItem(id: id, title: title, isCompleted: false),
    ]);
    _controller.clear();
  }

  void _removeItem(String id) {
    widget.onChanged(widget.items.where((item) => item.id != id).toList());
  }

  void _toggleItem(String id) {
    widget.onChanged(
      widget.items
          .map(
            (item) => item.id == id
                ? item.copyWith(isCompleted: !item.isCompleted)
                : item,
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Checklist', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        for (final item in widget.items)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Checkbox(
              value: item.isCompleted,
              onChanged: widget.readOnly
                  ? null
                  : (_) => _toggleItem(item.id),
            ),
            title: Text(
              item.title,
              style: item.isCompleted
                  ? const TextStyle(decoration: TextDecoration.lineThrough)
                  : null,
            ),
            trailing: widget.readOnly
                ? null
                : IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => _removeItem(item.id),
                  ),
          ),
        if (!widget.readOnly)
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Add checklist item',
                    isDense: true,
                  ),
                  onSubmitted: (_) => _addItem(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _addItem,
              ),
            ],
          ),
      ],
    );
  }
}

/// Read-only subtask list for task detail views.
class TaskSubtasksList extends StatelessWidget {
  const TaskSubtasksList({
    required this.subtasks,
    super.key,
  });

  final List<Task> subtasks;

  @override
  Widget build(BuildContext context) {
    if (subtasks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Subtasks', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        for (final subtask in subtasks)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              subtask.isCompleted
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              size: 20,
              color: subtask.isCompleted
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            title: Text(
              subtask.title,
              style: subtask.isCompleted
                  ? const TextStyle(decoration: TextDecoration.lineThrough)
                  : null,
            ),
          ),
      ],
    );
  }
}
