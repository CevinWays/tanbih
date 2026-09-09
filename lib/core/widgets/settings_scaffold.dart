import 'package:flutter/material.dart';

import '../styles/styles.dart';

/// Shared chrome for every settings screen: the gradient header with a back
/// button, over the page ground.
class SettingsScaffold extends StatelessWidget {
  const SettingsScaffold({
    required this.title,
    required this.children,
    super.key,
    this.actions = const [],
  });

  final String title;
  final List<Widget> children;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: AppGradients.primaryVertical,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(AppSpacing.headerRadius),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(
                  right: AppSpacing.lg,
                  bottom: AppSpacing.xl,
                ),
                child: Row(
                  children: [
                    const BackButton(color: Colors.white),
                    Expanded(
                      child: Text(title, style: AppTextStyle.onHeaderLabel),
                    ),
                    ...actions,
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.huge,
              ),
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}
