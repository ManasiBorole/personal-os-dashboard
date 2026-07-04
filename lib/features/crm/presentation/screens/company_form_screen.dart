import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/core/utils/validators.dart';
import 'package:personal_os_dashboard/core/widgets/buttons/app_button.dart';
import 'package:personal_os_dashboard/core/widgets/feedback/error_view.dart';
import 'package:personal_os_dashboard/core/widgets/feedback/loading_view.dart';
import 'package:personal_os_dashboard/core/widgets/inputs/app_text_field.dart';
import 'package:personal_os_dashboard/features/crm/domain/entities/contact.dart';
import 'package:personal_os_dashboard/features/crm/domain/entities/contact_form_state.dart';
import 'package:personal_os_dashboard/features/crm/domain/entities/contact_params.dart';
import 'package:personal_os_dashboard/features/crm/presentation/providers/crm_provider.dart';

class CompanyFormScreen extends ConsumerStatefulWidget {
  const CompanyFormScreen({super.key, this.companyId});

  final String? companyId;

  bool get isEditing => companyId != null;

  @override
  ConsumerState<CompanyFormScreen> createState() => _CompanyFormScreenState();
}

class _CompanyFormScreenState extends ConsumerState<CompanyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _industryController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _websiteController = TextEditingController();
  final _tagsController = TextEditingController();
  final _notesController = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _industryController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _websiteController.dispose();
    _tagsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _populate(Company company) {
    _nameController.text = company.name;
    _industryController.text = company.industry;
    _phoneController.text = company.phone ?? '';
    _emailController.text = company.email ?? '';
    _addressController.text = company.address ?? '';
    _websiteController.text = company.website ?? '';
    _tagsController.text = company.tags.join(', ');
    _notesController.text = company.notes;
    _initialized = true;
  }

  List<String> _parseTags() {
    return _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
  }

  String? _nullable(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = ref.read(companyFormControllerProvider.notifier);
    final success = widget.isEditing
        ? await controller.updateCompany(
            UpdateCompanyParams(
              id: widget.companyId!,
              name: _nameController.text.trim(),
              industry: _industryController.text.trim(),
              phone: _nullable(_phoneController.text),
              email: _nullable(_emailController.text),
              address: _nullable(_addressController.text),
              website: _nullable(_websiteController.text),
              tags: _parseTags(),
              notes: _notesController.text.trim(),
            ),
          )
        : await controller.createCompany(
            CreateCompanyParams(
              name: _nameController.text.trim(),
              industry: _industryController.text.trim(),
              phone: _nullable(_phoneController.text),
              email: _nullable(_emailController.text),
              address: _nullable(_addressController.text),
              website: _nullable(_websiteController.text),
              tags: _parseTags(),
              notes: _notesController.text.trim(),
            ),
          );

    if (success && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEditing && !_initialized) {
      final companyAsync = ref.watch(companyDetailProvider(widget.companyId!));
      return companyAsync.when(
        loading: () => Scaffold(
          appBar: AppBar(title: const Text('Edit Company')),
          body: const LoadingView(message: 'Loading company...'),
        ),
        error: (e, _) => Scaffold(
          appBar: AppBar(title: const Text('Edit Company')),
          body: ErrorView(message: e.toString()),
        ),
        data: (company) {
          if (!_initialized) _populate(company);
          return _buildForm(context);
        },
      );
    }
    return _buildForm(context);
  }

  Widget _buildForm(BuildContext context) {
    final formState = ref.watch(companyFormControllerProvider);

    ref.listen(companyFormControllerProvider, (prev, next) {
      if (next is CompanyFormError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message)),
        );
        ref.read(companyFormControllerProvider.notifier).clearStatus();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Company' : 'New Company'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            AppTextField(
              controller: _nameController,
              label: 'Company name',
              validator: Validators.required,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _industryController,
              label: 'Industry',
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
            AppTextField(
              controller: _websiteController,
              label: 'Website',
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _tagsController,
              label: 'Tags (comma-separated)',
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _notesController,
              label: 'Notes',
              maxLines: 4,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: widget.isEditing ? 'Save changes' : 'Create company',
              isLoading: formState.isLoading,
              isExpanded: true,
              onPressed: formState.isLoading ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
