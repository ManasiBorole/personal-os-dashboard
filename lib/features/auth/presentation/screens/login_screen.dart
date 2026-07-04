import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:personal_os_dashboard/core/constants/app_constants.dart';
import 'package:personal_os_dashboard/core/constants/route_constants.dart';
import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/core/utils/extensions/context_extensions.dart';
import 'package:personal_os_dashboard/core/utils/validators.dart';
import 'package:personal_os_dashboard/core/widgets/buttons/app_button.dart';
import 'package:personal_os_dashboard/core/widgets/feedback/loading_view.dart';
import 'package:personal_os_dashboard/core/widgets/inputs/app_text_field.dart';
import 'package:personal_os_dashboard/features/auth/domain/entities/auth_form_state.dart';
import 'package:personal_os_dashboard/features/auth/presentation/providers/auth_provider.dart';
import 'package:personal_os_dashboard/features/auth/presentation/widgets/auth_form_card.dart';
import 'package:personal_os_dashboard/features/auth/presentation/widgets/auth_form_fields.dart';
import 'package:personal_os_dashboard/features/auth/presentation/widgets/auth_header.dart';
import 'package:personal_os_dashboard/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:personal_os_dashboard/features/auth/presentation/widgets/auth_status_banner.dart';

/// Sign-in screen for existing users.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    context.hideKeyboard();

    ref.read(loginControllerProvider.notifier).clearStatus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await ref.read(loginControllerProvider.notifier).signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );

    if (success && mounted) {
      context.go(RouteConstants.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(loginControllerProvider);
    final sessionLoading = ref.watch(authStateProvider).isLoading;

    if (sessionLoading) {
      return const AuthScaffold(
        child: LoadingView(message: 'Checking session...'),
      );
    }

    return AuthScaffold(
      child: AuthFormCard(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthHeader(
                title: 'Welcome back',
                subtitle: 'Sign in to continue to ${AppConstants.appName}',
              ),
              const SizedBox(height: AppSpacing.xl),
              AuthStatusBanner(
                state: formState,
                onDismiss: () =>
                    ref.read(loginControllerProvider.notifier).clearStatus(),
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
                textInputAction: TextInputAction.done,
                enabled: !formState.isLoading,
                validator: Validators.password,
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: formState.isLoading
                      ? null
                      : () => context.push(RouteConstants.forgotPassword),
                  child: const Text('Forgot password?'),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'Sign In',
                isLoading: formState.isLoading,
                isExpanded: true,
                onPressed: formState.isLoading ? null : _submit,
              ),
              const SizedBox(height: AppSpacing.lg),
              AuthLinkRow(
                prompt: 'Don\'t have an account?',
                actionLabel: 'Create account',
                onPressed: formState.isLoading
                    ? () {}
                    : () => context.go(RouteConstants.signup),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
