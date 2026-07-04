import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:personal_os_dashboard/core/constants/route_constants.dart';
import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/core/utils/extensions/context_extensions.dart';
import 'package:personal_os_dashboard/core/widgets/feedback/empty_state_view.dart';
import 'package:personal_os_dashboard/core/widgets/feedback/error_view.dart';
import 'package:personal_os_dashboard/core/widgets/feedback/loading_view.dart';
import 'package:personal_os_dashboard/features/crm/domain/entities/contact.dart';
import 'package:personal_os_dashboard/features/crm/domain/entities/contact_params.dart';
import 'package:personal_os_dashboard/features/crm/presentation/providers/crm_provider.dart';
import 'package:personal_os_dashboard/features/crm/presentation/widgets/company_card.dart';
import 'package:personal_os_dashboard/features/crm/presentation/widgets/contact_card.dart';
import 'package:personal_os_dashboard/features/crm/presentation/widgets/contact_filters_bar.dart';
import 'package:personal_os_dashboard/features/crm/presentation/widgets/contact_search_bar.dart';

class CrmScreen extends ConsumerWidget {
  const CrmScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(crmListTabProvider);
    final isDesktop = context.isDesktop;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (tab == CrmListTab.contacts) {
            context.push(RouteConstants.contactCreate);
          } else {
            context.push(RouteConstants.companyCreate);
          }
        },
        icon: const Icon(Icons.add),
        label: Text(tab == CrmListTab.contacts ? 'Add Contact' : 'Add Company'),
      ),
      body: tab == CrmListTab.contacts
          ? _ContactsTab(isDesktop: isDesktop)
          : _CompaniesTab(isDesktop: isDesktop),
    );
  }
}

class _ContactsTab extends ConsumerWidget {
  const _ContactsTab({required this.isDesktop});

  final bool isDesktop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(contactsListProvider);
    final filtered = ref.watch(filteredContactsProvider);

    return contactsAsync.when(
      loading: () => const LoadingView(message: 'Loading contacts...'),
      error: (e, _) => ErrorView(
        message: e.toString(),
        onRetry: () => ref.read(contactsListProvider.notifier).refresh(),
      ),
      data: (_) => RefreshIndicator(
        onRefresh: () => ref.read(contactsListProvider.notifier).refresh(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _CrmHeader(isDesktop: isDesktop)),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: ContactFiltersBar(),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
            if (filtered.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyStateView(
                  title: 'No contacts found',
                  message: 'Add your first contact or adjust your filters.',
                  icon: Icons.people_outline,
                  actionLabel: 'Add Contact',
                  onAction: () => context.push(RouteConstants.contactCreate),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final contact = filtered[index];
                      return ContactCard(
                        contact: contact,
                        onTap: () => context.push(
                          RouteConstants.contactDetail
                              .replaceFirst(':id', contact.id),
                        ),
                        onEdit: () => context.push(
                          RouteConstants.contactEdit
                              .replaceFirst(':id', contact.id),
                        ),
                        onDelete: () => _confirmDeleteContact(
                          context,
                          ref,
                          contact,
                        ),
                      );
                    },
                    childCount: filtered.length,
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteContact(
    BuildContext context,
    WidgetRef ref,
    Contact contact,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete contact?'),
        content: Text('Remove ${contact.fullName} from your CRM?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final success = await ref
        .read(contactFormControllerProvider.notifier)
        .deleteContact(contact.id);
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contact deleted')),
      );
    }
  }
}

class _CompaniesTab extends ConsumerWidget {
  const _CompaniesTab({required this.isDesktop});

  final bool isDesktop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companiesAsync = ref.watch(companiesListProvider);
    final filtered = ref.watch(filteredCompaniesProvider);

    return companiesAsync.when(
      loading: () => const LoadingView(message: 'Loading companies...'),
      error: (e, _) => ErrorView(
        message: e.toString(),
        onRetry: () => ref.read(companiesListProvider.notifier).refresh(),
      ),
      data: (_) => RefreshIndicator(
        onRefresh: () => ref.read(companiesListProvider.notifier).refresh(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _CrmHeader(isDesktop: isDesktop)),
            if (filtered.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyStateView(
                  title: 'No companies found',
                  message: 'Add companies to link with your contacts.',
                  icon: Icons.business_outlined,
                  actionLabel: 'Add Company',
                  onAction: () => context.push(RouteConstants.companyCreate),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final company = filtered[index];
                      return CompanyCard(
                        company: company,
                        onTap: () => context.push(
                          RouteConstants.companyEdit
                              .replaceFirst(':id', company.id),
                        ),
                        onEdit: () => context.push(
                          RouteConstants.companyEdit
                              .replaceFirst(':id', company.id),
                        ),
                        onDelete: () => _confirmDeleteCompany(
                          context,
                          ref,
                          company,
                        ),
                      );
                    },
                    childCount: filtered.length,
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteCompany(
    BuildContext context,
    WidgetRef ref,
    Company company,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete company?'),
        content: Text('Remove ${company.name}? Linked contacts will be unlinked.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final success = await ref
        .read(companyFormControllerProvider.notifier)
        .deleteCompany(company.id);
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Company deleted')),
      );
    }
  }
}

class _CrmHeader extends ConsumerWidget {
  const _CrmHeader({required this.isDesktop});

  final bool isDesktop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(crmListTabProvider);
    final filteredContacts = ref.watch(filteredContactsProvider);
    final filteredCompanies = ref.watch(filteredCompaniesProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        isDesktop ? AppSpacing.xl : AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isDesktop)
            Text(
              'CRM',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          if (!isDesktop) const SizedBox(height: AppSpacing.lg),
          const ContactSearchBar(),
          const SizedBox(height: AppSpacing.md),
          SegmentedButton<CrmListTab>(
            segments: [
              for (final t in CrmListTab.values)
                ButtonSegment(value: t, label: Text(t.label)),
            ],
            selected: {tab},
            onSelectionChanged: (selection) {
              ref.read(crmListTabProvider.notifier).state = selection.first;
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            tab == CrmListTab.contacts
                ? '${filteredContacts.length} contact${filteredContacts.length == 1 ? '' : 's'}'
                : '${filteredCompanies.length} compan${filteredCompanies.length == 1 ? 'y' : 'ies'}',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
