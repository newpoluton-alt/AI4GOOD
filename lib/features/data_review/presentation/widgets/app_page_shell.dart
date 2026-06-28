import 'package:flutter/material.dart';

import '../../../../core/presentation/app_ui.dart';
import '../../../../core/presentation/responsive.dart';

class AppPageShell extends StatelessWidget {
  const AppPageShell({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.child,
    this.showBack = true,
    this.onBack,
    this.trailing,
  });

  final String eyebrow;
  final String title;
  final Widget child;
  final bool showBack;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final responsive = AppResponsive.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            responsive.horizontalPadding,
            responsive.compactHeight ? 12 : 20,
            responsive.horizontalPadding,
            responsive.verticalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PageHeader(
                eyebrow: eyebrow,
                title: title,
                showBack: showBack,
                onBack: onBack,
                trailing: trailing,
              ),
              SizedBox(height: responsive.isMobile ? 14 : 20),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.eyebrow,
    required this.title,
    required this.showBack,
    this.onBack,
    this.trailing,
  });

  final String eyebrow;
  final String title;
  final bool showBack;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final compact = MediaQuery.sizeOf(context).width < 430;

    final leadingAndTitle = Row(
      children: [
        if (showBack) ...[
          IconButton.filledTonal(
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: onBack ?? () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                title,
                maxLines: compact ? 3 : 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (compact && trailing != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          leadingAndTitle,
          const SizedBox(height: 12),
          Align(alignment: Alignment.centerRight, child: trailing!),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: leadingAndTitle),
        if (trailing != null) ...[const SizedBox(width: 12), trailing!],
      ],
    );
  }
}
