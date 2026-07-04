import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/core/utils/date_utils.dart' as app_date;
import 'package:personal_os_dashboard/core/utils/validators.dart';
import 'package:personal_os_dashboard/core/widgets/buttons/app_button.dart';
import 'package:personal_os_dashboard/core/widgets/feedback/error_view.dart';
import 'package:personal_os_dashboard/core/widgets/feedback/loading_view.dart';
import 'package:personal_os_dashboard/core/widgets/inputs/app_text_field.dart';
import 'package:personal_os_dashboard/features/crm/domain/entities/contact.dart';
import 'package:personal_os_dashboard/features/crm/domain/entities/contact_form_state.dart';
import 'package:personal_os_dashboard/features/crm/domain/entities/contact_params.dart';
import 'package:personal_os_dashboard/features/crm/presentation/providers/crm_provider.dart';

class ContactFormScreen extends ConsumerStatefulWidget {
  const ContactFormScreen({super.key, this.contactId});

  final String? contactId;

  bool get isEditing => contactId != null;

  @override
  ConsumerState<ContactFormScreen> createState() => _ContactFormScreenState();
}

class _ContactFormScreenState extends ConsumerState<ContactFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _tagsController = TextEditingController();
  final _noteController = TextEditingController();
  final _followUpTitleController = TextEditingController();
  final _followUpNotesController = TextEditingController();
  final _meetingTitleController = TextEditingController();
  final _meetingNotesController = TextEditingController();

  ContactCategory _category = ContactCategory.other;
  String? _companyId;
  List<ContactNote> _notes = [];
  List<ContactFollowUp> _followUps = [];
  List<ContactMeetingRecord> _meetingHistory = [];
  DateTime? _followUpDueDate;
  DateTime? _birthday;
  DateTime _meetingDate = DateTime.now();
  bool _initialized = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _tagsController.dispose();
    _noteController.dispose();
    _followUpTitleController.dispose();
    _followUpNotesController.dispose();
    _meetingTitleController.dispose();
    _meetingNotesController.dispose();
    super.dispose();
  }

  void _populate(Contact contact) {
    _firstNameController.text = contact.firstName;
    _lastNameController.text = contact.lastName;
    _phoneController.text = contact.phone ?? '';
    _emailController.text = contact.email ?? '';
    _addressController.text = contact.address ?? '';
    _category = contact.category;
    _companyId = contact.companyId;
    _notes = List<ContactNote>.from(contact.notes);
    _followUps = List<ContactFollowUp>.from(contact.followUps);
    _meetingHistory = List<ContactMeetingRecord>.from(contact.meetingHistory);
    _birthday = contact.birthday;
    _initialized = true;
  }

  List<String> _parseTags() {
    return _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
  }

  void _addNote() {
    final content = _noteController.text.trim();
    if (content.isEmpty) return;
    setState(() {
      _notes = [
        ContactNote(
          id: 'note-${DateTime.now().microsecondsSinceEpoch}',
          content: content,
          createdAt: DateTime.now(),
        ),
        ..._notes,
      ];
      _noteController.clear();
    });
  }

  void _addFollowUp() {
    final title = _followUpTitleController.text.trim();
    if (title.isEmpty) return;
    setState(() {
      _followUps = [
        ..._followUps,
        ContactFollowUp(
          id: 'fu-${DateTime.now().microsecondsSinceEpoch}',
          title: title,
          dueDate: _followUpDueDate,
          status: FollowUpStatus.pending,
          notes: _followUpNotesController.text.trim(),
        ),
      ];
      _followUpTitleController.clear();
      _followUpNotesController.clear();
      _followUpDueDate = null;
    });
  }

  void _addMeeting() {
    final title = _meetingTitleController.text.trim();
    if (title.isEmpty) return;
    setState(() {
      _meetingHistory = [
        ContactMeetingRecord(
          id: 'mh-${DateTime.now().microsecondsSinceEpoch}',
          title: title,
          meetingDate: _meetingDate,
          notes: _meetingNotesController.text.trim(),
        ),
        ..._meetingHistory,
      ];
      _meetingTitleController.clear();
      _meetingNotesController.clear();
      _meetingDate = DateTime.now();
    });
  }

  Future<void> _pickFollowUpDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDate: _followUpDueDate ?? DateTime.now(),
    );
    if (date != null) setState(() => _followUpDueDate = date);
  }

  Future<void> _pickMeetingDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDate: _meetingDate,
    );
    if (date != null) setState(() => _meetingDate = date);
  }

  Future<void> _pickBirthday() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _birthday ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (date != null) setState(() => _birthday = date);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final params = widget.isEditing
        ? UpdateContactParams(
            id: widget.contactId!,
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            phone: _nullable(_phoneController.text),
            email: _nullable(_emailController.text),
            address: _nullable(_addressController.text),
            category: _category.name,
            tags: _parseTags(),
            companyId: _companyId,
            notes: _notes,
            followUps: _followUps,
            meetingHistory: _meetingHistory,
            birthday: _birthday,
            clearCompanyId: _companyId == null,
            clearBirthday: _birthday == null,
          )
        : CreateContactParams(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            phone: _nullable(_phoneController.text),
            email: _nullable(_emailController.text),
            address: _nullable(_addressController.text),
            category: _category.name,
            tags: _parseTags(),
            companyId: _companyId,
            notes: _notes,
            followUps: _followUps,
            meetingHistory: _meetingHistory,
            birthday: _birthday,
          );

    final controller = ref.read(contactFormControllerProvider.notifier);
    final success = widget.isEditing
        ? await controller.updateContact(params as UpdateContactParams)
        : await controller.createContact(params as CreateContactParams);

    if (success && mounted) context.pop();
  }

  String? _nullable(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEditing && !_initialized) {
      final contactAsync = ref.watch(contactDetailProvider(widget.contactId!));
      return contactAsync.when(
        loading: () => Scaffold(
          appBar: AppBar(title: const Text('Edit Contact')),
          body: const LoadingView(message: 'Loading contact...'),
        ),
        error: (e, _) => Scaffold(
          appBar: AppBar(title: const Text('Edit Contact')),
          body: ErrorView(message: e.toString()),
        ),
        data: (contact) {
          if (!_initialized) _populate(contact);
          return _buildForm(context);
        },
      );
    }
    return _buildForm(context);
  }

  Widget _buildForm(BuildContext context) {
    final formState = ref.watch(contactFormControllerProvider);
    final companies = ref.watch(companiesListProvider).maybeWhen(
          data: (value) => value,
          orElse: () => const <Company>[],
        );

    ref.listen(contactFormControllerProvider, (prev, next) {
      if (next is ContactFormError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message)),
        );
        ref.read(contactFormControllerProvider.notifier).clearStatus();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Contact' : 'New Contact'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            AppTextField(
              controller: _firstNameController,
              label: 'First name',
              validator: Validators.required,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _lastNameController,
              label: 'Last name',
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _emailController,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) return null;
                return Validators.email(value);
              },
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _phoneController,
              label: 'Phone',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _addressController,
              label: 'Address',
              maxLines: 2,
            ),
            const SizedBox(height: AppSpacing.md),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Birthday'),
              subtitle: Text(
                _birthday == null
                    ? 'Not set'
                    : app_date.DateUtils.formatDate(_birthday!),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_birthday != null)
                    IconButton(
                      onPressed: () => setState(() => _birthday = null),
                      icon: const Icon(Icons.clear),
                    ),
                  IconButton(
                    onPressed: _pickBirthday,
                    icon: const Icon(Icons.cake_outlined),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<ContactCategory>(
              value: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final c in ContactCategory.values)
                  DropdownMenuItem(value: c, child: Text(c.label)),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _category = value);
              },
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String?>(
              value: _companyId,
              decoration: const InputDecoration(
                labelText: 'Company',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('None')),
                for (final company in companies)
                  DropdownMenuItem(
                    value: company.id,
                    child: Text(company.name),
                  ),
              ],
              onChanged: (value) => setState(() => _companyId = value),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _tagsController,
              label: 'Tags (comma-separated)',
            ),
            const SizedBox(height: AppSpacing.xl),
            _sectionTitle(context, 'Notes'),
            ..._notes.map(
              (note) => ListTile(
                title: Text(note.content),
                subtitle: Text(
                  app_date.DateUtils.formatDisplayDateTime(note.createdAt),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => setState(
                    () => _notes = _notes.where((n) => n.id != note.id).toList(),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _noteController,
                    label: 'Add note',
                  ),
                ),
                IconButton(
                  onPressed: _addNote,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _sectionTitle(context, 'Follow-ups'),
            ..._followUps.map(
              (fu) => ListTile(
                title: Text(fu.title),
                subtitle: Text(
                  [
                    if (fu.dueDate != null)
                      'Due: ${app_date.DateUtils.formatDisplayDate(fu.dueDate!)}',
                    fu.notes,
                  ].where((s) => s.isNotEmpty).join(' · '),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => setState(
                    () => _followUps =
                        _followUps.where((f) => f.id != fu.id).toList(),
                  ),
                ),
              ),
            ),
            AppTextField(
              controller: _followUpTitleController,
              label: 'Follow-up title',
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              controller: _followUpNotesController,
              label: 'Follow-up notes',
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: _pickFollowUpDate,
              icon: const Icon(Icons.event),
              label: Text(
                _followUpDueDate == null
                    ? 'Set due date'
                    : app_date.DateUtils.formatDisplayDate(_followUpDueDate!),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _addFollowUp,
                icon: const Icon(Icons.add),
                label: const Text('Add follow-up'),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _sectionTitle(context, 'Meeting history'),
            ..._meetingHistory.map(
              (m) => ListTile(
                title: Text(m.title),
                subtitle: Text(
                  '${app_date.DateUtils.formatDisplayDate(m.meetingDate)}'
                  '${m.notes.isNotEmpty ? ' · ${m.notes}' : ''}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => setState(
                    () => _meetingHistory =
                        _meetingHistory.where((h) => h.id != m.id).toList(),
                  ),
                ),
              ),
            ),
            AppTextField(
              controller: _meetingTitleController,
              label: 'Meeting title',
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              controller: _meetingNotesController,
              label: 'Meeting notes',
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: _pickMeetingDate,
              icon: const Icon(Icons.event),
              label: Text(
                app_date.DateUtils.formatDisplayDate(_meetingDate),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _addMeeting,
                icon: const Icon(Icons.add),
                label: const Text('Add meeting'),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: widget.isEditing ? 'Save changes' : 'Create contact',
              isLoading: formState.isLoading,
              isExpanded: true,
              onPressed: formState.isLoading ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
