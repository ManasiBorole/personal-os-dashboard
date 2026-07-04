import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:personal_os_dashboard/core/constants/app_constants.dart';
import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/core/utils/date_utils.dart' as app_date;
import 'package:personal_os_dashboard/core/utils/extensions/context_extensions.dart';
import 'package:personal_os_dashboard/core/utils/validators.dart';
import 'package:personal_os_dashboard/core/widgets/buttons/app_button.dart';
import 'package:personal_os_dashboard/core/widgets/feedback/error_view.dart';
import 'package:personal_os_dashboard/core/widgets/feedback/loading_view.dart';
import 'package:personal_os_dashboard/core/widgets/inputs/app_text_field.dart';
import 'package:personal_os_dashboard/features/calendar/domain/entities/calendar_event.dart';
import 'package:personal_os_dashboard/features/calendar/domain/entities/calendar_event_form_state.dart';
import 'package:personal_os_dashboard/features/calendar/domain/entities/calendar_event_params.dart';
import 'package:personal_os_dashboard/features/calendar/presentation/providers/calendar_provider.dart';

/// Create or edit calendar event form.
class CalendarEventFormScreen extends ConsumerStatefulWidget {
  const CalendarEventFormScreen({
    super.key,
    this.eventId,
    this.initialDay,
  });

  final String? eventId;
  final DateTime? initialDay;

  bool get isEditing => eventId != null;

  @override
  ConsumerState<CalendarEventFormScreen> createState() =>
      _CalendarEventFormScreenState();
}

class _CalendarEventFormScreenState
    extends ConsumerState<CalendarEventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _attendeeController = TextEditingController();

  CalendarEventType _eventType = CalendarEventType.meeting;
  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now().add(const Duration(hours: 1));
  DateTime? _reminderAt;
  bool _isAllDay = false;
  bool _initialized = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _attendeeController.dispose();
    super.dispose();
  }

  void _populate(CalendarEvent event) {
    _titleController.text = event.title;
    _descriptionController.text = event.description;
    _locationController.text = event.location ?? '';
    _attendeeController.text =
        event.attendeeCount > 0 ? '${event.attendeeCount}' : '';
    _eventType = event.eventType;
    _startTime = event.startTime;
    _endTime = event.endTime;
    _reminderAt = event.reminderAt;
    _isAllDay = event.isAllDay;
    _initialized = true;
  }

  Future<void> _pickStart() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDate: _startTime,
    );
    if (date == null || !mounted) return;

    if (_isAllDay) {
      setState(() {
        _startTime = DateTime(date.year, date.month, date.day);
        _endTime = DateTime(date.year, date.month, date.day, 23, 59);
      });
      return;
    }

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startTime),
    );
    if (time != null) {
      setState(() {
        _startTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        if (!_endTime.isAfter(_startTime)) {
          _endTime = _startTime.add(const Duration(hours: 1));
        }
      });
    }
  }

  Future<void> _pickEnd() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDate: _endTime,
    );
    if (date == null || !mounted || _isAllDay) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_endTime),
    );
    if (time != null) {
      setState(() {
        _endTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  Future<void> _pickReminder() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
      initialDate: _reminderAt ?? _startTime,
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_reminderAt ?? now),
    );
    if (time != null) {
      setState(() {
        _reminderAt = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  Future<void> _submit() async {
    context.hideKeyboard();
    ref.read(calendarEventFormControllerProvider.notifier).clearStatus();

    if (!_formKey.currentState!.validate()) return;

    final attendeeCount = int.tryParse(_attendeeController.text.trim()) ?? 0;
    final controller = ref.read(calendarEventFormControllerProvider.notifier);

    final success = widget.isEditing
        ? await controller.updateEvent(
            UpdateCalendarEventParams(
              id: widget.eventId!,
              title: _titleController.text,
              description: _descriptionController.text,
              eventType: _eventType.storageValue,
              startTime: _startTime,
              endTime: _endTime,
              isAllDay: _isAllDay,
              location: _locationController.text.trim().isEmpty
                  ? null
                  : _locationController.text.trim(),
              reminderAt: _reminderAt,
              attendeeCount: attendeeCount,
              linkedTaskId: null,
              clearLocation: _locationController.text.trim().isEmpty,
              clearReminder: _reminderAt == null,
            ),
          )
        : await controller.createEvent(
            CreateCalendarEventParams(
              title: _titleController.text,
              description: _descriptionController.text,
              eventType: _eventType.storageValue,
              startTime: _startTime,
              endTime: _endTime,
              isAllDay: _isAllDay,
              location: _locationController.text.trim().isEmpty
                  ? null
                  : _locationController.text.trim(),
              reminderAt: _reminderAt,
              attendeeCount: attendeeCount,
              linkedTaskId: null,
            ),
          );

    if (success && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized && widget.initialDay != null) {
      final day = widget.initialDay!;
      _startTime = DateTime(day.year, day.month, day.day, 9);
      _endTime = DateTime(day.year, day.month, day.day, 10);
      _initialized = true;
    }

    if (widget.isEditing) {
      final eventAsync = ref.watch(calendarEventDetailProvider(widget.eventId!));
      return eventAsync.when(
        loading: () => Scaffold(
          appBar: AppBar(title: const Text('Edit Event')),
          body: const LoadingView(message: 'Loading event...'),
        ),
        error: (error, _) => Scaffold(
          appBar: AppBar(title: const Text('Edit Event')),
          body: ErrorView(message: error.toString()),
        ),
        data: (event) {
          if (event.isReadOnly) {
            return Scaffold(
              appBar: AppBar(title: const Text('Edit Event')),
              body: const ErrorView(
                message: 'This event is synced from a task and cannot be edited here.',
              ),
            );
          }
          if (!_initialized || _titleController.text.isEmpty) {
            _populate(event);
          }
          return _buildScaffold(context);
        },
      );
    }

    return _buildScaffold(context);
  }

  Widget _buildScaffold(BuildContext context) {
    final formState = ref.watch(calendarEventFormControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Event' : 'Add Event'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (formState is CalendarEventFormError)
                    _MessageBanner(
                      message: formState.message,
                      isError: true,
                    ),
                  if (formState is CalendarEventFormSuccess)
                    _MessageBanner(
                      message: formState.message ?? 'Saved',
                      isError: false,
                    ),
                  AppTextField(
                    controller: _titleController,
                    label: 'Title',
                    hint: 'Event title',
                    enabled: !formState.isLoading,
                    validator: (value) => Validators.combine([
                      (v) => Validators.required(v, fieldName: 'Title'),
                      (v) => Validators.maxLength(
                            v,
                            AppConstants.maxTitleLength,
                            fieldName: 'Title',
                          ),
                    ])(value),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    controller: _descriptionController,
                    label: 'Description',
                    hint: 'Optional details',
                    enabled: !formState.isLoading,
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  DropdownButtonFormField<CalendarEventType>(
                    initialValue: _eventType,
                    decoration: const InputDecoration(labelText: 'Event type'),
                    items: [
                      for (final type in CalendarEventType.values)
                        DropdownMenuItem(
                          value: type,
                          child: Text(type.label),
                        ),
                    ],
                    onChanged: formState.isLoading
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() => _eventType = value);
                            }
                          },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('All day'),
                    value: _isAllDay,
                    onChanged: formState.isLoading
                        ? null
                        : (value) => setState(() => _isAllDay = value),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Start'),
                    subtitle: Text(
                      _isAllDay
                          ? app_date.DateUtils.formatDisplayDate(_startTime)
                          : app_date.DateUtils.formatDisplayDateTime(_startTime),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.calendar_today_outlined),
                      onPressed: formState.isLoading ? null : _pickStart,
                    ),
                  ),
                  if (!_isAllDay)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('End'),
                      subtitle: Text(
                        app_date.DateUtils.formatDisplayDateTime(_endTime),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.schedule_outlined),
                        onPressed: formState.isLoading ? null : _pickEnd,
                      ),
                    ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Reminder'),
                    subtitle: Text(
                      _reminderAt != null
                          ? app_date.DateUtils.formatDisplayDateTime(_reminderAt!)
                          : 'No reminder',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_reminderAt != null)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: formState.isLoading
                                ? null
                                : () => setState(() => _reminderAt = null),
                          ),
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          onPressed:
                              formState.isLoading ? null : _pickReminder,
                        ),
                      ],
                    ),
                  ),
                  if (_eventType == CalendarEventType.meeting) ...[
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _locationController,
                      label: 'Location',
                      hint: 'Zoom, office, etc.',
                      enabled: !formState.isLoading,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      controller: _attendeeController,
                      label: 'Attendees',
                      hint: 'Number of attendees',
                      enabled: !formState.isLoading,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    label: widget.isEditing ? 'Save Changes' : 'Create Event',
                    isLoading: formState.isLoading,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageBanner extends StatelessWidget {
  const _MessageBanner({
    required this.message,
    required this.isError,
  });

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isError
            ? Theme.of(context).colorScheme.errorContainer
            : Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
      ),
      child: Text(message),
    );
  }
}
