import 'package:flutter/material.dart';
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
import 'package:personal_os_dashboard/features/goals/domain/entities/goal.dart';
import 'package:personal_os_dashboard/features/goals/domain/entities/goal_form_state.dart';
import 'package:personal_os_dashboard/features/goals/domain/entities/goal_params.dart';
import 'package:personal_os_dashboard/features/goals/presentation/providers/goals_provider.dart';
import 'package:personal_os_dashboard/features/goals/presentation/widgets/goal_progress_tracker.dart';

/// Create or edit goal form screen.
class GoalFormScreen extends ConsumerStatefulWidget {
  const GoalFormScreen({
    super.key,
    this.goalId,
  });

  final String? goalId;

  bool get isEditing => goalId != null;

  @override
  ConsumerState<GoalFormScreen> createState() => _GoalFormScreenState();
}

class _GoalFormScreenState extends ConsumerState<GoalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  GoalCategory _category = GoalCategory.personal;
  GoalPriority _priority = GoalPriority.medium;
  GoalStatus _status = GoalStatus.active;
  DateTime? _deadline;
  double _progress = 0;
  bool _initialized = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _populateFromGoal(Goal goal) {
    _titleController.text = goal.title;
    _descriptionController.text = goal.description;
    _category = goal.category;
    _priority = goal.priority;
    _status = goal.status;
    _deadline = goal.deadline;
    _progress = goal.progress;
    _initialized = true;
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
      initialDate: _deadline ?? now,
    );

    if (picked != null) {
      setState(() => _deadline = picked);
    }
  }

  Future<void> _submit() async {
    context.hideKeyboard();
    ref.read(goalFormControllerProvider.notifier).clearStatus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final controller = ref.read(goalFormControllerProvider.notifier);
    final success = widget.isEditing
        ? await controller.updateGoal(
            UpdateGoalParams(
              id: widget.goalId!,
              title: _titleController.text,
              description: _descriptionController.text,
              category: _category.name,
              priority: _priority.name,
              deadline: _deadline,
              progress: _progress,
              status: _status.name,
            ),
          )
        : await controller.createGoal(
            CreateGoalParams(
              title: _titleController.text,
              description: _descriptionController.text,
              category: _category.name,
              priority: _priority.name,
              deadline: _deadline,
              progress: _progress,
              status: _status.name,
            ),
          );

    if (success && mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEditing) {
      final goalAsync = ref.watch(goalDetailProvider(widget.goalId!));

      return goalAsync.when(
        loading: () => Scaffold(
          appBar: AppBar(title: const Text('Edit Goal')),
          body: const LoadingView(message: 'Loading goal...'),
        ),
        error: (error, _) => Scaffold(
          appBar: AppBar(title: const Text('Edit Goal')),
          body: ErrorView(message: error.toString()),
        ),
        data: (goal) {
          if (!_initialized) {
            _populateFromGoal(goal);
          }
          return _buildScaffold(context);
        },
      );
    }

    return _buildScaffold(context);
  }

  Widget _buildScaffold(BuildContext context) {
    final formState = ref.watch(goalFormControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Goal' : 'Add Goal'),
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
                  if (formState is GoalFormError)
                    _MessageBanner(
                      message: formState.message,
                      isError: true,
                    ),
                  if (formState is GoalFormSuccess)
                    _MessageBanner(
                      message: formState.message ?? 'Saved',
                      isError: false,
                    ),
                  AppTextField(
                    controller: _titleController,
                    label: 'Title',
                    hint: 'What do you want to achieve?',
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
                    hint: 'Describe your goal and success criteria',
                    maxLines: 4,
                    enabled: !formState.isLoading,
                    validator: (value) => Validators.maxLength(
                      value,
                      AppConstants.maxDescriptionLength,
                      fieldName: 'Description',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _DropdownField<GoalCategory>(
                    label: 'Category',
                    value: _category,
                    items: GoalCategory.values,
                    labelBuilder: (value) => value.label,
                    onChanged: formState.isLoading
                        ? null
                        : (value) => setState(() => _category = value!),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _DropdownField<GoalPriority>(
                    label: 'Priority',
                    value: _priority,
                    items: GoalPriority.values,
                    labelBuilder: (value) => value.label,
                    onChanged: formState.isLoading
                        ? null
                        : (value) => setState(() => _priority = value!),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _DropdownField<GoalStatus>(
                    label: 'Status',
                    value: _status,
                    items: GoalStatus.values,
                    labelBuilder: (value) => value.label,
                    onChanged: formState.isLoading
                        ? null
                        : (value) => setState(() => _status = value!),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Deadline'),
                    subtitle: Text(
                      _deadline == null
                          ? 'No deadline set'
                          : app_date.DateUtils.formatDisplayDate(_deadline!),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_deadline != null)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: formState.isLoading
                                ? null
                                : () => setState(() => _deadline = null),
                          ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today_outlined),
                          onPressed:
                              formState.isLoading ? null : _pickDeadline,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  GoalProgressTracker(
                    progress: _progress,
                    onChanged: formState.isLoading
                        ? null
                        : (value) => setState(() => _progress = value),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  AppButton(
                    label: widget.isEditing ? 'Save Changes' : 'Create Goal',
                    isLoading: formState.isLoading,
                    isExpanded: true,
                    onPressed: formState.isLoading ? null : _submit,
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

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> items;
  final String Function(T value) labelBuilder;
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
        ),
      ),
      items: [
        for (final item in items)
          DropdownMenuItem(
            value: item,
            child: Text(labelBuilder(item)),
          ),
      ],
      onChanged: onChanged,
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
      width: double.infinity,
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
