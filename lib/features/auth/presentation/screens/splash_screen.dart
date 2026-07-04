import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:personal_os_dashboard/core/constants/app_constants.dart';
import 'package:personal_os_dashboard/core/constants/route_constants.dart';
import 'package:personal_os_dashboard/core/theme/app_colors.dart';
import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/core/widgets/feedback/loading_view.dart';
import 'package:personal_os_dashboard/features/auth/domain/entities/auth_state.dart';
import 'package:personal_os_dashboard/features/auth/presentation/providers/auth_provider.dart';

/// Splash screen that resolves session state before navigation.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppConstants.defaultAnimationDuration,
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolveInitialAuthState());
  }

  void _resolveInitialAuthState() {
    if (_hasNavigated || !mounted) {
      return;
    }

    ref.read(authStateProvider).whenOrNull(
          data: _navigateForState,
          error: (_, _) => _go(RouteConstants.login),
        );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authStateProvider, (previous, next) {
      next.whenOrNull(
        data: (state) => _navigateForState(state),
        error: (_, _) => _go(RouteConstants.login),
      );
    });

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.dashboard_rounded,
                  size: 80,
                  color: AppColors.white,
                ),
                const SizedBox(height: AppSpacing.xl),
                const Text(
                  AppConstants.appName,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Theme(
                  data: ThemeData(
                    progressIndicatorTheme: const ProgressIndicatorThemeData(
                      color: AppColors.white,
                    ),
                    textTheme: const TextTheme(
                      bodyMedium: TextStyle(color: AppColors.white),
                    ),
                  ),
                  child: const LoadingView(
                    message: 'Initializing session...',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateForState(AuthState state) {
    final destination = state.isAuthenticated
        ? RouteConstants.dashboard
        : RouteConstants.login;
    _go(destination);
  }

  void _go(String route) {
    if (_hasNavigated || !mounted) {
      return;
    }

    _hasNavigated = true;
    context.go(route);
  }
}
