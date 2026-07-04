import 'package:flutter/material.dart';

import 'package:personal_os_dashboard/core/constants/app_constants.dart';
import 'package:personal_os_dashboard/core/theme/app_spacing.dart';

/// Base scaffold with optional app bar, padding, and max content width.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.body,
    super.key,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.padding,
    this.centerContent = true,
    this.resizeToAvoidBottomInset = true,
  });

  final String? title;
  final List<Widget>? actions;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final EdgeInsetsGeometry? padding;
  final bool centerContent;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      child: body,
    );

    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: title == null
          ? null
          : AppBar(
              title: Text(title!),
              actions: actions,
            ),
      drawer: drawer,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: centerContent
          ? Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppConstants.maxContentWidth,
                ),
                child: content,
              ),
            )
          : content,
    );
  }
}
