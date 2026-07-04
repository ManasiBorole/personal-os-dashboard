import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:personal_os_dashboard/core/di/service_locator.dart';
import 'package:personal_os_dashboard/core/error/error_handler.dart';
import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/core/widgets/buttons/app_button.dart';
import 'package:personal_os_dashboard/core/widgets/feedback/error_view.dart';
import 'package:personal_os_dashboard/core/widgets/feedback/loading_view.dart';
import 'package:personal_os_dashboard/core/widgets/inputs/app_text_field.dart';
import 'package:personal_os_dashboard/features/auth/presentation/providers/auth_provider.dart';
import 'package:personal_os_dashboard/features/notes/domain/entities/note.dart';
import 'package:personal_os_dashboard/features/notes/domain/entities/note_form_state.dart';
import 'package:personal_os_dashboard/features/notes/domain/entities/note_params.dart';
import 'package:personal_os_dashboard/features/notes/domain/usecases/note_usecases.dart';
import 'package:personal_os_dashboard/features/notes/presentation/providers/notes_provider.dart';
import 'package:personal_os_dashboard/features/notes/presentation/widgets/note_category_colors.dart';

class NoteFormScreen extends ConsumerStatefulWidget {
  const NoteFormScreen({super.key, this.noteId});

  final String? noteId;

  bool get isEditing => noteId != null;

  @override
  ConsumerState<NoteFormScreen> createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends ConsumerState<NoteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();
  final _checklistItemController = TextEditingController();

  NoteType _type = NoteType.text;
  NoteCategory _category = NoteCategory.other;
  List<NoteChecklistItem> _checklist = [];
  List<NoteAttachment> _images = [];
  List<NoteAttachment> _documents = [];
  final List<({String name, Uint8List bytes, bool isImage, String? contentType})>
      _pendingUploads = [];
  bool _isPinned = false;
  bool _isArchived = false;
  bool _initialized = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    _checklistItemController.dispose();
    super.dispose();
  }

  void _populate(Note note) {
    _titleController.text = note.title;
    _contentController.text = note.content;
    _tagsController.text = note.tags.join(', ');
    _type = note.type;
    _category = note.category;
    _checklist = List<NoteChecklistItem>.from(note.checklist);
    _images = List<NoteAttachment>.from(note.images);
    _documents = List<NoteAttachment>.from(note.documents);
    _isPinned = note.isPinned;
    _isArchived = note.isArchived;
    _initialized = true;
  }

  List<String> _parseTags() {
    return _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
  }

  void _addChecklistItem() {
    final text = _checklistItemController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _checklist = [
        ..._checklist,
        NoteChecklistItem(
          id: 'item-${DateTime.now().microsecondsSinceEpoch}',
          text: text,
          isChecked: false,
        ),
      ];
      _checklistItemController.clear();
    });
  }

  void _toggleChecklistItem(String id) {
    setState(() {
      _checklist = _checklist
          .map(
            (item) => item.id == id
                ? item.copyWith(isChecked: !item.isChecked)
                : item,
          )
          .toList();
    });
  }

  Future<void> _pickAttachment({required bool isImage}) async {
    final result = await FilePicker.platform.pickFiles(
      type: isImage ? FileType.image : FileType.custom,
      allowedExtensions: isImage ? null : ['pdf', 'doc', 'docx', 'txt', 'xlsx'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) return;

    if (widget.isEditing) {
      final attachment = await ref
          .read(noteFormControllerProvider.notifier)
          .uploadAttachment(
            noteId: widget.noteId!,
            bytes: bytes,
            fileName: file.name,
            isImage: isImage,
            contentType: _mimeType(file.extension, isImage),
          );
      if (attachment != null && mounted) {
        setState(() {
          if (isImage) {
            _images = [..._images, attachment];
          } else {
            _documents = [..._documents, attachment];
          }
        });
      }
    } else {
      setState(() {
        final pendingId = 'pending-${DateTime.now().microsecondsSinceEpoch}';
        _pendingUploads.add((
          name: file.name,
          bytes: bytes,
          isImage: isImage,
          contentType: _mimeType(file.extension, isImage),
        ));
        final pending = NoteAttachment(
          id: pendingId,
          name: file.name,
          storagePath: '',
          publicUrl: '',
          mimeType: _mimeType(file.extension, isImage) ??
              'application/octet-stream',
          isImage: isImage,
        );
        if (isImage) {
          _images = [..._images, pending];
        } else {
          _documents = [..._documents, pending];
        }
      });
    }
  }

  String? _mimeType(String? extension, bool isImage) {
    if (isImage) {
      return switch (extension?.toLowerCase()) {
        'jpg' || 'jpeg' => 'image/jpeg',
        'png' => 'image/png',
        'webp' => 'image/webp',
        'gif' => 'image/gif',
        _ => 'image/jpeg',
      };
    }
    return switch (extension?.toLowerCase()) {
      'pdf' => 'application/pdf',
      'doc' => 'application/msword',
      'docx' =>
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'txt' => 'text/plain',
      'xlsx' =>
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      _ => 'application/octet-stream',
    };
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = ref.read(noteFormControllerProvider.notifier);

    if (widget.isEditing) {
      final success = await controller.updateNote(
        UpdateNoteParams(
          id: widget.noteId!,
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          type: _type.name,
          checklist: _checklist,
          category: _category.name,
          tags: _parseTags(),
          images: _images,
          documents: _documents,
          isPinned: _isPinned,
          isArchived: _isArchived,
        ),
      );
      if (success && mounted) context.pop();
      return;
    }

    final userId = ref.read(currentUserProvider)?.id ?? 'local-user';
    final createResult = await ref.read(createNoteUseCaseProvider).call(
          CreateNoteRequest(
            userId: userId,
            note: CreateNoteParams(
              title: _titleController.text.trim(),
              content: _contentController.text.trim(),
              type: _type.name,
              checklist: _checklist,
              category: _category.name,
              tags: _parseTags(),
              images: const [],
              documents: const [],
              isPinned: _isPinned,
            ),
          ),
        );

    Note? created;
    createResult.when(
      success: (note) {
        created = note;
        ref.invalidate(notesListProvider);
      },
      onFailure: (f) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(sl<ErrorHandler>().getUserMessage(f))),
        );
      },
    );

    if (created == null || !mounted) return;

    if (_pendingUploads.isNotEmpty) {
      var images = <NoteAttachment>[];
      var documents = <NoteAttachment>[];

      for (final pending in _pendingUploads) {
        final attachment = await controller.uploadAttachment(
          noteId: created!.id,
          bytes: pending.bytes,
          fileName: pending.name,
          isImage: pending.isImage,
          contentType: pending.contentType,
        );
        if (attachment != null) {
          if (pending.isImage) {
            images = [...images, attachment];
          } else {
            documents = [...documents, attachment];
          }
        }
      }

      if (images.isNotEmpty || documents.isNotEmpty) {
        await controller.updateNote(
          UpdateNoteParams(
            id: created!.id,
            title: _titleController.text.trim(),
            content: _contentController.text.trim(),
            type: _type.name,
            checklist: _checklist,
            category: _category.name,
            tags: _parseTags(),
            images: images,
            documents: documents,
            isPinned: _isPinned,
            isArchived: false,
          ),
        );
      }
    }

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEditing && !_initialized) {
      final noteAsync = ref.watch(noteDetailProvider(widget.noteId!));
      return noteAsync.when(
        loading: () => Scaffold(
          appBar: AppBar(title: const Text('Edit Note')),
          body: const LoadingView(message: 'Loading note...'),
        ),
        error: (e, _) => Scaffold(
          appBar: AppBar(title: const Text('Edit Note')),
          body: ErrorView(message: e.toString()),
        ),
        data: (note) {
          if (!_initialized) _populate(note);
          return _buildForm(context);
        },
      );
    }
    return _buildForm(context);
  }

  Widget _buildForm(BuildContext context) {
    final formState = ref.watch(noteFormControllerProvider);
    final theme = Theme.of(context);
    final accent = NoteCategoryColors.color(_category);

    ref.listen(noteFormControllerProvider, (prev, next) {
      if (next is NoteFormError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message)),
        );
        ref.read(noteFormControllerProvider.notifier).clearStatus();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Note' : 'New Note'),
        actions: [
          IconButton(
            icon: Icon(
              _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              color: _isPinned ? theme.colorScheme.primary : null,
            ),
            tooltip: _isPinned ? 'Unpin' : 'Pin',
            onPressed: () => setState(() => _isPinned = !_isPinned),
          ),
          if (widget.isEditing)
            IconButton(
              icon: const Icon(Icons.archive_outlined),
              tooltip: _isArchived ? 'Unarchive' : 'Archive',
              onPressed: () => setState(() => _isArchived = !_isArchived),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: _titleController,
              label: 'Title',
            ),
            const SizedBox(height: AppSpacing.md),
            SegmentedButton<NoteType>(
              segments: [
                for (final t in NoteType.values)
                  ButtonSegment(
                    value: t,
                    label: Text(t.label),
                    icon: Icon(
                      t == NoteType.text
                          ? Icons.notes
                          : Icons.checklist_rtl,
                    ),
                  ),
              ],
              selected: {_type},
              onSelectionChanged: (selection) {
                setState(() => _type = selection.first);
              },
            ),
            const SizedBox(height: AppSpacing.md),
            if (_type == NoteType.text)
              AppTextField(
                controller: _contentController,
                label: 'Content',
                maxLines: 8,
              )
            else ...[
              ..._checklist.map(
                (item) => CheckboxListTile(
                  value: item.isChecked,
                  onChanged: (_) => _toggleChecklistItem(item.id),
                  title: Text(item.text),
                  secondary: IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: () => setState(
                      () => _checklist =
                          _checklist.where((i) => i.id != item.id).toList(),
                    ),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _checklistItemController,
                      label: 'Add checklist item',
                      onSubmitted: (_) => _addChecklistItem(),
                    ),
                  ),
                  IconButton(
                    onPressed: _addChecklistItem,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<NoteCategory>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final c in NoteCategory.values)
                  DropdownMenuItem(value: c, child: Text(c.label)),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _category = value);
              },
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _tagsController,
              label: 'Tags (comma-separated)',
            ),
            const SizedBox(height: AppSpacing.lg),
            _sectionHeader(context, 'Images'),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final img in _images)
                  InputChip(
                    avatar: const Icon(Icons.image_outlined, size: 18),
                    label: Text(img.name, overflow: TextOverflow.ellipsis),
                    onDeleted: () => setState(
                      () => _images = _images.where((i) => i.id != img.id).toList(),
                    ),
                  ),
                ActionChip(
                  avatar: const Icon(Icons.add_photo_alternate_outlined, size: 18),
                  label: const Text('Add image'),
                  onPressed: () => _pickAttachment(isImage: true),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _sectionHeader(context, 'Documents'),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final doc in _documents)
                  InputChip(
                    avatar: const Icon(Icons.description_outlined, size: 18),
                    label: Text(doc.name, overflow: TextOverflow.ellipsis),
                    onDeleted: () => setState(
                      () => _documents =
                          _documents.where((d) => d.id != doc.id).toList(),
                    ),
                  ),
                ActionChip(
                  avatar: const Icon(Icons.attach_file, size: 18),
                  label: const Text('Add document'),
                  onPressed: () => _pickAttachment(isImage: false),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: widget.isEditing ? 'Save changes' : 'Create note',
              isLoading: formState.isLoading,
              isExpanded: true,
              onPressed: formState.isLoading ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
