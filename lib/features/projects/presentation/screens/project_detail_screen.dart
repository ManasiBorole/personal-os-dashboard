import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:personal_os_dashboard/core/constants/app_constants.dart';
import 'package:personal_os_dashboard/core/constants/route_constants.dart';
import 'package:personal_os_dashboard/core/theme/app_colors.dart';
import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/core/utils/date_utils.dart' as app_date;
import 'package:personal_os_dashboard/core/utils/extensions/context_extensions.dart';
import 'package:personal_os_dashboard/core/widgets/feedback/error_view.dart';
import 'package:personal_os_dashboard/core/widgets/feedback/loading_view.dart';
import 'package:personal_os_dashboard/features/projects/domain/entities/project.dart';
import 'package:personal_os_dashboard/features/projects/presentation/providers/projects_provider.dart';
import 'package:personal_os_dashboard/features/projects/presentation/widgets/project_status_chip.dart';

/// Project dashboard hub with client, budget, timeline, members, tasks, files, notes.
class ProjectDetailScreen extends ConsumerWidget {
  const ProjectDetailScreen({required this.projectId, super.key});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(projectDashboardProvider(projectId));
    final isWide = context.isDesktop || context.isTablet;

    return Scaffold(
      body: dashboardAsync.when(
        loading: () => const LoadingView(message: 'Loading project dashboard...'),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () =>
              ref.read(projectDashboardProvider(projectId).notifier).refresh(),
        ),
        data: (dashboard) => RefreshIndicator(
          onRefresh: () =>
              ref.read(projectDashboardProvider(projectId).notifier).refresh(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 160,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => context.push(
                      RouteConstants.projectEdit.replaceFirst(':id', projectId),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    dashboard.project.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: ProjectStatusChip(status: dashboard.project.status),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppConstants.maxContentWidth,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _KpiRow(project: dashboard.project),
                          const SizedBox(height: AppSpacing.lg),
                          if (isWide)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _ClientSection(
                                    client: dashboard.project.client,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.lg),
                                Expanded(
                                  child: _BudgetSection(
                                    budget: dashboard.project.budget,
                                  ),
                                ),
                              ],
                            )
                          else ...[
                            _ClientSection(client: dashboard.project.client),
                            const SizedBox(height: AppSpacing.lg),
                            _BudgetSection(budget: dashboard.project.budget),
                          ],
                          const SizedBox(height: AppSpacing.lg),
                          _TimelineSection(timeline: dashboard.project.timeline),
                          const SizedBox(height: AppSpacing.lg),
                          _ProgressSection(project: dashboard.project),
                          const SizedBox(height: AppSpacing.lg),
                          _MembersSection(
                            projectId: projectId,
                            members: dashboard.members,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          _TasksSection(tasks: dashboard.tasks),
                          const SizedBox(height: AppSpacing.lg),
                          _FilesSection(files: dashboard.files),
                          const SizedBox(height: AppSpacing.lg),
                          _NotesSection(
                            projectId: projectId,
                            notes: dashboard.notes,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KpiRow extends StatelessWidget {
  const _KpiRow({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        _KpiCard(
          label: 'Progress',
          value: '${project.progressPercent}%',
          icon: Icons.trending_up,
        ),
        _KpiCard(
          label: 'Tasks',
          value: '${project.completedTasks}/${project.totalTasks}',
          icon: Icons.task_alt_outlined,
        ),
        _KpiCard(
          label: 'Budget used',
          value:
              '${(project.budget.utilization * 100).round()}%',
          icon: Icons.payments_outlined,
        ),
        _KpiCard(
          label: 'Remaining',
          value:
              '${project.budget.currency} ${project.budget.remaining.toStringAsFixed(0)}',
          icon: Icons.account_balance_wallet_outlined,
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(height: AppSpacing.sm),
              Text(value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      )),
              Text(label, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            child,
          ],
        ),
      ),
    );
  }
}

class _ClientSection extends StatelessWidget {
  const _ClientSection({required this.client});

  final ClientDetails client;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Client Details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (client.company.isNotEmpty)
            _InfoRow(Icons.business, client.company),
          if (client.name.isNotEmpty) _InfoRow(Icons.person, client.name),
          if (client.email.isNotEmpty) _InfoRow(Icons.email, client.email),
          if (client.phone.isNotEmpty) _InfoRow(Icons.phone, client.phone),
          if (client.isEmpty) const Text('No client details provided.'),
        ],
      ),
    );
  }
}

class _BudgetSection extends StatelessWidget {
  const _BudgetSection({required this.budget});

  final ProjectBudget budget;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Budget',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${budget.currency} ${budget.spent.toStringAsFixed(0)} / ${budget.amount.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
            child: LinearProgressIndicator(
              value: budget.utilization,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${budget.currency} ${budget.remaining.toStringAsFixed(0)} remaining',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _TimelineSection extends StatelessWidget {
  const _TimelineSection({required this.timeline});

  final ProjectTimeline timeline;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Timeline',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (timeline.startDate != null)
            _InfoRow(
              Icons.play_arrow,
              'Start: ${app_date.DateUtils.formatDisplayDate(timeline.startDate!)}',
            ),
          if (timeline.endDate != null)
            _InfoRow(
              Icons.flag,
              'End: ${app_date.DateUtils.formatDisplayDate(timeline.endDate!)}',
            ),
          if (timeline.durationDays != null)
            _InfoRow(Icons.schedule, '${timeline.durationDays} days'),
          if (timeline.elapsedPercent != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: LinearProgressIndicator(value: timeline.elapsedPercent),
            ),
        ],
      ),
    );
  }
}

class _ProgressSection extends StatelessWidget {
  const _ProgressSection({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Progress',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Overall completion'),
              Text(
                '${project.progressPercent}%',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          LinearProgressIndicator(value: project.progress, minHeight: 10),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${project.completedTasks} of ${project.totalTasks} tasks completed',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _MembersSection extends ConsumerWidget {
  const _MembersSection({
    required this.projectId,
    required this.members,
  });

  final String projectId;
  final List<ProjectMember> members;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SectionCard(
      title: 'Members (${members.length})',
      trailing: IconButton(
        icon: const Icon(Icons.person_add_outlined),
        onPressed: () => _showAddMember(context, ref),
      ),
      child: members.isEmpty
          ? const Text('No members assigned yet.')
          : Column(
              children: [
                for (final m in members)
                  ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        m.name.isNotEmpty
                            ? m.name[0].toUpperCase()
                            : '?',
                      ),
                    ),
                    title: Text(m.name),
                    subtitle: Text('${m.role} • ${m.email}'),
                  ),
              ],
            ),
    );
  }

  Future<void> _showAddMember(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final roleController = TextEditingController(text: 'Member');

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add member'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: roleController,
              decoration: const InputDecoration(labelText: 'Role'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (ok == true && nameController.text.isNotEmpty) {
      await ref.read(projectFormControllerProvider.notifier).addMember(
            projectId: projectId,
            name: nameController.text,
            email: emailController.text,
            role: roleController.text,
          );
    }
  }
}

class _TasksSection extends StatelessWidget {
  const _TasksSection({required this.tasks});

  final List<ProjectTaskItem> tasks;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Tasks (${tasks.length})',
      child: tasks.isEmpty
          ? const Text('No tasks linked to this project.')
          : Column(
              children: [
                for (final t in tasks)
                  ListTile(
                    leading: Icon(
                      t.status == 'completed'
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: t.status == 'completed'
                          ? AppColors.success
                          : null,
                    ),
                    title: Text(t.title),
                    subtitle: Text(
                      '${t.priority} • ${t.status}'
                      '${t.dueDate != null ? ' • ${app_date.DateUtils.formatDisplayDate(t.dueDate!)}' : ''}',
                    ),
                  ),
              ],
            ),
    );
  }
}

class _FilesSection extends StatelessWidget {
  const _FilesSection({required this.files});

  final List<ProjectFile> files;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Files (${files.length})',
      child: files.isEmpty
          ? const Text('No files uploaded.')
          : Column(
              children: [
                for (final f in files)
                  ListTile(
                    leading: const Icon(Icons.insert_drive_file_outlined),
                    title: Text(f.name),
                    subtitle: Text(
                      '${(f.sizeBytes / 1024).toStringAsFixed(1)} KB • ${f.mimeType}',
                    ),
                  ),
              ],
            ),
    );
  }
}

class _NotesSection extends ConsumerWidget {
  const _NotesSection({
    required this.projectId,
    required this.notes,
  });

  final String projectId;
  final List<ProjectNote> notes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SectionCard(
      title: 'Notes (${notes.length})',
      trailing: IconButton(
        icon: const Icon(Icons.note_add_outlined),
        onPressed: () => _showAddNote(context, ref),
      ),
      child: notes.isEmpty
          ? const Text('No notes yet.')
          : Column(
              children: [
                for (final n in notes)
                  ListTile(
                    title: Text(n.title),
                    subtitle: Text(
                      n.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      app_date.DateUtils.formatRelative(n.updatedAt),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
              ],
            ),
    );
  }

  Future<void> _showAddNote(BuildContext context, WidgetRef ref) async {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(labelText: 'Content'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (ok == true && titleController.text.isNotEmpty) {
      await ref.read(projectFormControllerProvider.notifier).addNote(
            projectId: projectId,
            title: titleController.text,
            content: contentController.text,
          );
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
