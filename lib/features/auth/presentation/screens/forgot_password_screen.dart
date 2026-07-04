import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:personal_os_dashboard/core/constants/route_constants.dart';
import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/core/utils/extensions/context_extensions.dart';
import 'package:personal_os_dashboard/core/utils/validators.dart';
import 'package:personal_os_dashboard/core/widgets/buttons/app_button.dart';
import 'package:personal_os_dashboard/core/widgets/inputs/app_text_field.dart';
import 'package:personal_os_dashboard/features/auth/domain/entities/auth_form_state.dart';
import 'package:personal_os_dashboard/features/auth/presentation/providers/auth_provider.dart';
import 'package:personal_os_dashboard/features/auth/presentation/widgets/auth_form_card.dart';
import 'package:personal_os_dashboard/features/auth/presentation/widgets/auth_form_fields.dart';
import 'package:personal_os_dashboard/features/auth/presentation/widgets/auth_header.dart';
import 'package:personal_os_dashboard/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:personal_os_dashboard/features/auth/presentation/widgets/auth_status_banner.dart';

/// Password recovery screen.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    context.hideKeyboard();
    ref.read(forgotPasswordControllerProvider.notifier).clearStatus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref.read(forgotPasswordControllerProvider.notifier).resetPassword(
          email: _emailController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(forgotPasswordControllerProvider);

    return AuthScaffold(
      showBackButton: true,
      child: AuthFormCard(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AuthHeader(
                title: 'Reset password',
                subtitle:
                    'Enter your email and we\'ll send you a link to reset your password.',
              ),
              const SizedBox(height: AppSpacing.xl),
              AuthStatusBanner(
                state: formState,
                onDismiss: () => ref
                    .read(forgotPasswordControllerProvider.notifier)
                    .clearStatus(),
              ),
              AppTextField(
                controller: _emailController,
                label: 'Email address',
                hint: 'you@company.com',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                autocorrect: false,
                enabled: !formState.isLoading,
                validator: Validators.email,
                onSubmitted: (_) => _submit(),
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppButton(
                label: 'Send Reset Link',
                isLoading: formState.isLoading,
                isExpanded: true,
                onPressed: formState.isLoading ? null : _submit,
              ),
              const SizedBox(height: AppSpacing.lg),
              AuthLinkRow(
                prompt: 'Remember your password?',
                actionLabel: 'Back to sign in',
                onPressed: formState.isLoading
                    ? () {}
                    : () => context.go(RouteConstants.login),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
