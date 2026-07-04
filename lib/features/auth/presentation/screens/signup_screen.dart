import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:personal_os_dashboard/core/constants/app_constants.dart';
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

/// Registration screen for new users.
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    context.hideKeyboard();
    ref.read(signupControllerProvider.notifier).clearStatus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await ref.read(signupControllerProvider.notifier).signUp(
          email: _emailController.text,
          password: _passwordController.text,
        );

    if (success && mounted) {
      context.go(RouteConstants.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(signupControllerProvider);

    return AuthScaffold(
      child: AuthFormCard(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthHeader(
                title: 'Create your account',
                subtitle: 'Start organizing your life with ${AppConstants.appName}',
              ),
              const SizedBox(height: AppSpacing.xl),
              AuthStatusBanner(
                state: formState,
                onDismiss: () =>
                    ref.read(signupControllerProvider.notifier).clearStatus(),
              ),
              AppTextField(
                controller: _emailController,
                label: 'Email address',
                hint: 'you@company.com',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autocorrect: false,
                enabled: !formState.isLoading,
                validator: Validators.email,
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              const SizedBox(height: AppSpacing.lg),
              PasswordField(
                controller: _passwordController,
                label: 'Password',
                textInputAction: TextInputAction.next,
                enabled: !formState.isLoading,
                validator: Validators.strongPassword,
              ),
              const SizedBox(height: AppSpacing.lg),
              PasswordField(
                controller: _confirmPasswordController,
                label: 'Confirm password',
                textInputAction: TextInputAction.done,
                enabled: !formState.isLoading,
                validator: (value) => Validators.confirmPassword(
                  value,
                  _passwordController.text,
                ),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppButton(
                label: 'Create Account',
                isLoading: formState.isLoading,
                isExpanded: true,
                onPressed: formState.isLoading ? null : _submit,
              ),
              const SizedBox(height: AppSpacing.lg),
              AuthLinkRow(
                prompt: 'Already have an account?',
                actionLabel: 'Sign in',
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
