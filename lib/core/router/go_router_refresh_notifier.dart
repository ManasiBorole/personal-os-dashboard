import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:personal_os_dashboard/features/auth/presentation/providers/auth_provider.dart';

/// Notifies GoRouter when authentication state changes.
final class GoRouterRefreshNotifier extends ChangeNotifier {
  GoRouterRefreshNotifier(this._ref) {
    _ref.listen(authStateProvider, (_, _) => notifyListeners());
  }

  final Ref _ref;
}

final goRouterRefreshNotifierProvider = Provider<GoRouterRefreshNotifier>((ref) {
  final notifier = GoRouterRefreshNotifier(ref);
  ref.onDispose(notifier.dispose);
  return notifier;
});
