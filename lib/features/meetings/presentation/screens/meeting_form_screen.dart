import 'package:file_picker/file_picker.dart';
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
import 'package:personal_os_dashboard/features/meetings/domain/entities/meeting.dart';
import 'package:personal_os_dashboard/features/meetings/domain/entities/meeting_form_state.dart';
import 'package:personal_os_dashboard/features/meetings/domain/entities/meeting_params.dart';
import 'package:personal_os_dashboard/features/meetings/presentation/providers/meetings_provider.dart';

class MeetingFormScreen extends ConsumerStatefulWidget {
  const MeetingFormScreen({super.key, this.meetingId});

  final String? meetingId;

  bool get isEditing => meetingId != null;

  @override
  ConsumerState<MeetingFormScreen> createState() => _MeetingFormScreenState();
}

class _MeetingFormScreenState extends ConsumerState<MeetingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _agendaController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  final _followUpController = TextEditingController();
  final _durationController = TextEditingController(text: '30');
  final _participantNameController = TextEditingController();
  final _participantEmailController = TextEditingController();
  final _participantRoleController = TextEditingController(text: 'Attendee');

  DateTime _startTime = DateTime.now().add(const Duration(hours: 1));
  DateTime? _reminderAt;
  MeetingStatus _status = MeetingStatus.scheduled;
  List<MeetingParticipant> _participants = [];
  List<MeetingAttachment> _attachments = [];
  bool _initialized = false;

  @override
  void dispose() {
    _titleController.dispose();
    _agendaController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    _followUpController.dispose();
    _durationController.dispose();
    _participantNameController.dispose();
    _participantEmailController.dispose();
    _participantRoleController.dispose();
    super.dispose();
  }

  void _populate(Meeting meeting) {
    _titleController.text = meeting.title;
    _agendaController.text = meeting.agenda;
    _locationController.text = meeting.location ?? '';
    _notesController.text = meeting.notes;
    _followUpController.text = meeting.followUp;
    _durationController.text = '${meeting.durationMinutes}';
    _startTime = meeting.startTime;
    _reminderAt = meeting.reminderAt;
    _status = meeting.status;
    _participants = List<MeetingParticipant>.from(meeting.participants);
    _attachments = List<MeetingAttachment>.from(meeting.attachments);
    _initialized = true;
  }

  Future<void> _pickStartTime() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDate: _startTime,
    );
    if (date == null || !mounted) return;

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
      });
    }
  }

  Future<void> _pickReminder() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
      initialDate: _reminderAt ?? _startTime,
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_reminderAt ?? _startTime),
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

  void _addParticipant() {
    final name = _participantNameController.text.trim();
    if (name.isEmpty) return;
    setState(() {
      _participants = [
        ..._participants,
        MeetingParticipant(
          id: 'p-${DateTime.now().microsecondsSinceEpoch}',
          name: name,
          email: _participantEmailController.text.trim(),
          role: _participantRoleController.text.trim().isEmpty
              ? 'Attendee'
              : _participantRoleController.text.trim(),
        ),
      ];
      _participantNameController.clear();
      _participantEmailController.clear();
      _participantRoleController.text = 'Attendee';
    });
  }

  void _removeParticipant(String id) {
    setState(() {
      _participants = _participants.where((p) => p.id != id).toList();
    });
  }

  Future<void> _addAttachment() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    setState(() {
      _attachments = [
        ..._attachments,
        MeetingAttachment(
          id: 'att-${DateTime.now().microsecondsSinceEpoch}',
          name: file.name,
          storagePath: file.path ?? 'local://${file.name}',
          mimeType: file.extension != null
              ? 'application/${file.extension}'
              : 'application/octet-stream',
        ),
      ];
    });
  }

  void _removeAttachment(String id) {
    setState(() {
      _attachments = _attachments.where((a) => a.id != id).toList();
    });
  }

  Future<void> _submit() async {
    context.hideKeyboard();
    ref.read(meetingFormControllerProvider.notifier).clearStatus();
    if (!_formKey.currentState!.validate()) return;

    final duration = int.tryParse(_durationController.text.trim()) ?? 30;
    final controller = ref.read(meetingFormControllerProvider.notifier);

    final success = widget.isEditing
        ? await controller.updateMeeting(
            UpdateMeetingParams(
              id: widget.meetingId!,
              title: _titleController.text,
              agenda: _agendaController.text,
              participants: _participants,
              startTime: _startTime,
              durationMinutes: duration,
              location: _locationController.text.trim().isEmpty
                  ? null
                  : _locationController.text.trim(),
              notes: _notesController.text,
              followUp: _followUpController.text,
              attachments: _attachments,
              reminderAt: _reminderAt,
              status: _status.name,
              clearLocation: _locationController.text.trim().isEmpty,
              clearReminder: _reminderAt == null,
            ),
          )
        : await controller.createMeeting(
            CreateMeetingParams(
              title: _titleController.text,
              agenda: _agendaController.text,
              participants: _participants,
              startTime: _startTime,
              durationMinutes: duration,
              location: _locationController.text.trim().isEmpty
                  ? null
                  : _locationController.text.trim(),
              notes: _notesController.text,
              followUp: _followUpController.text,
              attachments: _attachments,
              reminderAt: _reminderAt,
              status: _status.name,
            ),
          );

    if (success && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEditing) {
      final meetingAsync = ref.watch(meetingDetailProvider(widget.meetingId!));
      return meetingAsync.when(
        loading: () => Scaffold(
          appBar: AppBar(title: const Text('Edit Meeting')),
          body: const LoadingView(message: 'Loading meeting...'),
        ),
        error: (e, _) => Scaffold(
          appBar: AppBar(title: const Text('Edit Meeting')),
          body: ErrorView(message: e.toString()),
        ),
        data: (meeting) {
          if (!_initialized || _titleController.text.isEmpty) {
            _populate(meeting);
          }
          return _buildScaffold(context);
        },
      );
    }
    return _buildScaffold(context);
  }

  Widget _buildScaffold(BuildContext context) {
    final formState = ref.watch(meetingFormControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Meeting' : 'Schedule Meeting'),
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
                  if (formState is MeetingFormError)
                    _banner(formState.message, isError: true),
                  if (formState is MeetingFormSuccess)
                    _banner(formState.message ?? 'Saved', isError: false),
                  AppTextField(
                    controller: _titleController,
                    label: 'Title',
                    hint: 'Meeting title',
                    enabled: !formState.isLoading,
                    validator: (v) => Validators.required(v, fieldName: 'Title'),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    controller: _agendaController,
                    label: 'Agenda',
                    hint: 'Meeting agenda and topics',
                    enabled: !formState.isLoading,
                    maxLines: 4,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Date & Time'),
                    subtitle: Text(
                      app_date.DateUtils.formatDisplayDateTime(_startTime),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.calendar_today_outlined),
                      onPressed: formState.isLoading ? null : _pickStartTime,
                    ),
                  ),
                  AppTextField(
                    controller: _durationController,
                    label: 'Duration (minutes)',
                    keyboardType: TextInputType.number,
                    enabled: !formState.isLoading,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    controller: _locationController,
                    label: 'Location',
                    hint: 'Zoom, office, etc.',
                    enabled: !formState.isLoading,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  DropdownButtonFormField<MeetingStatus>(
                    initialValue: _status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: [
                      for (final s in MeetingStatus.values)
                        DropdownMenuItem(value: s, child: Text(s.label)),
                    ],
                    onChanged: formState.isLoading
                        ? null
                        : (v) {
                            if (v != null) setState(() => _status = v);
                          },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Reminder'),
                    subtitle: Text(
                      _reminderAt != null
                          ? app_date.DateUtils.formatDisplayDateTime(
                              _reminderAt!,
                            )
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
                  const SizedBox(height: AppSpacing.lg),
                  Text('Participants', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: AppSpacing.sm),
                  for (final p in _participants)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(p.name),
                      subtitle: Text('${p.role}${p.email.isNotEmpty ? ' · ${p.email}' : ''}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: formState.isLoading
                            ? null
                            : () => _removeParticipant(p.id),
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _participantNameController,
                          decoration: const InputDecoration(
                            hintText: 'Name',
                            isDense: true,
                          ),
                          enabled: !formState.isLoading,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: TextField(
                          controller: _participantRoleController,
                          decoration: const InputDecoration(
                            hintText: 'Role',
                            isDense: true,
                          ),
                          enabled: !formState.isLoading,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.person_add_outlined),
                        onPressed: formState.isLoading ? null : _addParticipant,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    controller: _notesController,
                    label: 'Notes',
                    hint: 'Meeting notes',
                    enabled: !formState.isLoading,
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    controller: _followUpController,
                    label: 'Follow Up',
                    hint: 'Action items after the meeting',
                    enabled: !formState.isLoading,
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Attachments',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      TextButton.icon(
                        onPressed: formState.isLoading ? null : _addAttachment,
                        icon: const Icon(Icons.attach_file),
                        label: const Text('Add file'),
                      ),
                    ],
                  ),
                  for (final a in _attachments)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.insert_drive_file_outlined),
                      title: Text(a.name),
                      trailing: IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: formState.isLoading
                            ? null
                            : () => _removeAttachment(a.id),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    label: widget.isEditing ? 'Save Changes' : 'Create Meeting',
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

  Widget _banner(String message, {required bool isError}) {
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
