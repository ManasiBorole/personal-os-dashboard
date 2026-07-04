import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/core/utils/date_utils.dart' as app_date;
import 'package:personal_os_dashboard/core/utils/extensions/context_extensions.dart';
import 'package:personal_os_dashboard/core/utils/validators.dart';
import 'package:personal_os_dashboard/core/widgets/buttons/app_button.dart';
import 'package:personal_os_dashboard/core/widgets/feedback/error_view.dart';
import 'package:personal_os_dashboard/core/widgets/feedback/loading_view.dart';
import 'package:personal_os_dashboard/core/widgets/inputs/app_text_field.dart';
import 'package:personal_os_dashboard/features/projects/domain/entities/project.dart';
import 'package:personal_os_dashboard/features/projects/domain/entities/project_form_state.dart';
import 'package:personal_os_dashboard/features/projects/domain/entities/project_params.dart';
import 'package:personal_os_dashboard/features/projects/presentation/providers/projects_provider.dart';

class ProjectFormScreen extends ConsumerStatefulWidget {
  const ProjectFormScreen({super.key, this.projectId});

  final String? projectId;

  bool get isEditing => projectId != null;

  @override
  ConsumerState<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends ConsumerState<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _clientNameController = TextEditingController();
  final _clientEmailController = TextEditingController();
  final _clientCompanyController = TextEditingController();
  final _clientPhoneController = TextEditingController();
  final _budgetAmountController = TextEditingController();
  final _budgetSpentController = TextEditingController();

  ProjectStatus _status = ProjectStatus.planning;
  String _currency = 'USD';
  DateTime? _startDate;
  DateTime? _endDate;
  double _progress = 0;
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _clientNameController.dispose();
    _clientEmailController.dispose();
    _clientCompanyController.dispose();
    _clientPhoneController.dispose();
    _budgetAmountController.dispose();
    _budgetSpentController.dispose();
    super.dispose();
  }

  void _populate(Project project) {
    _nameController.text = project.name;
    _descriptionController.text = project.description;
    _clientNameController.text = project.client.name;
    _clientEmailController.text = project.client.email;
    _clientCompanyController.text = project.client.company;
    _clientPhoneController.text = project.client.phone;
    _budgetAmountController.text = project.budget.amount.toStringAsFixed(0);
    _budgetSpentController.text = project.budget.spent.toStringAsFixed(0);
    _status = project.status;
    _currency = project.budget.currency;
    _startDate = project.timeline.startDate;
    _endDate = project.timeline.endDate;
    _progress = project.progress;
    _initialized = true;
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDate: (isStart ? _startDate : _endDate) ?? DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    context.hideKeyboard();
    ref.read(projectFormControllerProvider.notifier).clearStatus();
    if (!_formKey.currentState!.validate()) return;

    final controller = ref.read(projectFormControllerProvider.notifier);
    final success = widget.isEditing
        ? await controller.update(
            UpdateProjectParams(
              id: widget.projectId!,
              name: _nameController.text,
              description: _descriptionController.text,
              status: _status.name,
              clientName: _clientNameController.text,
              clientEmail: _clientEmailController.text,
              clientCompany: _clientCompanyController.text,
              clientPhone: _clientPhoneController.text,
              budgetAmount: double.tryParse(_budgetAmountController.text) ?? 0,
              budgetCurrency: _currency,
              budgetSpent: double.tryParse(_budgetSpentController.text) ?? 0,
              startDate: _startDate,
              endDate: _endDate,
              progress: _progress,
            ),
          )
        : await controller.create(
            CreateProjectParams(
              name: _nameController.text,
              description: _descriptionController.text,
              status: _status.name,
              clientName: _clientNameController.text,
              clientEmail: _clientEmailController.text,
              clientCompany: _clientCompanyController.text,
              clientPhone: _clientPhoneController.text,
              budgetAmount: double.tryParse(_budgetAmountController.text) ?? 0,
              budgetCurrency: _currency,
              budgetSpent: double.tryParse(_budgetSpentController.text) ?? 0,
              startDate: _startDate,
              endDate: _endDate,
              progress: _progress,
            ),
          );

    if (success && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEditing && !_initialized) {
      return FutureBuilder(
        future: ref.read(getProjectByIdUseCaseProvider).call(widget.projectId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Scaffold(
              appBar: AppBar(title: const Text('Edit Project')),
              body: const LoadingView(),
            );
          }
          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(title: const Text('Edit Project')),
              body: ErrorView(message: snapshot.error.toString()),
            );
          }
          final result = snapshot.data!;
          return result.when(
            success: (project) {
              if (!_initialized) _populate(project);
              return _buildForm();
            },
            onFailure: (f) => Scaffold(
              appBar: AppBar(title: const Text('Edit Project')),
              body: ErrorView(message: f.toString()),
            ),
          );
        },
      );
    }

    return _buildForm();
  }

  Widget _buildForm() {
    final formState = ref.watch(projectFormControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Project' : 'New Project'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (formState is ProjectFormError)
                Text(formState.message,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.error)),
              _sectionTitle('Project Details'),
              AppTextField(
                controller: _nameController,
                label: 'Project name',
                validator: (v) => Validators.required(v, fieldName: 'Name'),
                enabled: !formState.isLoading,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: _descriptionController,
                label: 'Description',
                maxLines: 3,
                enabled: !formState.isLoading,
              ),
              const SizedBox(height: AppSpacing.lg),
              DropdownButtonFormField<ProjectStatus>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: [
                  for (final s in ProjectStatus.values)
                    DropdownMenuItem(value: s, child: Text(s.label)),
                ],
                onChanged: formState.isLoading
                    ? null
                    : (v) => setState(() => _status = v!),
              ),
              const SizedBox(height: AppSpacing.xl),
              _sectionTitle('Client Details'),
              AppTextField(
                controller: _clientCompanyController,
                label: 'Company',
                enabled: !formState.isLoading,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: _clientNameController,
                label: 'Contact name',
                enabled: !formState.isLoading,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: _clientEmailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return null;
                  return Validators.email(v);
                },
                enabled: !formState.isLoading,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: _clientPhoneController,
                label: 'Phone',
                keyboardType: TextInputType.phone,
                enabled: !formState.isLoading,
              ),
              const SizedBox(height: AppSpacing.xl),
              _sectionTitle('Budget & Timeline'),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _budgetAmountController,
                      label: 'Budget',
                      keyboardType: TextInputType.number,
                      enabled: !formState.isLoading,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppTextField(
                      controller: _budgetSpentController,
                      label: 'Spent',
                      keyboardType: TextInputType.number,
                      enabled: !formState.isLoading,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Start'),
                      subtitle: Text(_startDate == null
                          ? 'Not set'
                          : app_date.DateUtils.formatDisplayDate(_startDate!)),
                      onTap:
                          formState.isLoading ? null : () => _pickDate(true),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('End'),
                      subtitle: Text(_endDate == null
                          ? 'Not set'
                          : app_date.DateUtils.formatDisplayDate(_endDate!)),
                      onTap:
                          formState.isLoading ? null : () => _pickDate(false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Progress: ${(_progress * 100).round()}%',
                  style: Theme.of(context).textTheme.labelLarge),
              Slider(
                value: _progress,
                onChanged:
                    formState.isLoading ? null : (v) => setState(() => _progress = v),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppButton(
                label: widget.isEditing ? 'Save Project' : 'Create Project',
                isLoading: formState.isLoading,
                isExpanded: true,
                onPressed: formState.isLoading ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
