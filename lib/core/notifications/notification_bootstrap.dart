import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:personal_os_dashboard/core/di/service_locator.dart';
import 'package:personal_os_dashboard/core/router/app_router.dart';
import 'package:personal_os_dashboard/features/auth/presentation/providers/auth_provider.dart';
import 'package:personal_os_dashboard/features/notifications/data/services/notification_coordinator.dart';

/// Initializes push notifications and reminder sync at app startup.
class NotificationBootstrap extends ConsumerStatefulWidget {
  const NotificationBootstrap({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<NotificationBootstrap> createState() =>
      _NotificationBootstrapState();
}

class _NotificationBootstrapState extends ConsumerState<NotificationBootstrap> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  Future<void> _initialize() async {
    try {
      final userId = ref.read(currentUserProvider)?.id ?? 'local-user';
      final router = ref.read(appRouterProvider);
      await sl<NotificationCoordinator>().initialize(
        userId: userId,
        onNotificationTap: (route) {
          if (route != null && route.isNotEmpty) {
            router.push(route);
          }
        },
      );
    } on Object {
      // Notification services are optional in tests and offline environments.
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
