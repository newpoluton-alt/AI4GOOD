import 'package:flutter/material.dart';

import '../../../../core/presentation/app_ui.dart';
import '../../../../core/presentation/responsive.dart';

Future<bool> showAdaptiveConfirmationDialog({
  required BuildContext context,
  required String title,
  String? message,
  required String cancelLabel,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final responsive = AppResponsive.of(context);
  final content = _ConfirmationContent(
    title: title,
    message: message,
    cancelLabel: cancelLabel,
    confirmLabel: confirmLabel,
    destructive: destructive,
  );

  if (responsive.isMobile) {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 12,
            right: 12,
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom + 12,
          ),
          child: content,
        ),
      ),
    );
    return result ?? false;
  }

  final result = await showDialog<bool>(
    context: context,
    builder: (_) => Dialog(
      insetPadding: const EdgeInsets.all(24),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: content,
      ),
    ),
  );
  return result ?? false;
}

Future<void> showAdaptiveMessageDialog({
  required BuildContext context,
  required String title,
  required String closeLabel,
}) async {
  await showAdaptiveConfirmationDialog(
    context: context,
    title: title,
    cancelLabel: '',
    confirmLabel: closeLabel,
  );
}

class _ConfirmationContent extends StatelessWidget {
  const _ConfirmationContent({
    required this.title,
    required this.cancelLabel,
    required this.confirmLabel,
    required this.destructive,
    this.message,
  });

  final String title;
  final String? message;
  final String cancelLabel;
  final String confirmLabel;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final responsive = AppResponsive.of(context);
    final showCancel = cancelLabel.isNotEmpty;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadii.medium),
      clipBehavior: Clip.antiAlias,
      elevation: 18,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              responsive.isMobile ? 20 : 28,
              responsive.isMobile ? 20 : 28,
              responsive.isMobile ? 20 : 28,
              responsive.isMobile ? 20 : 28,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                    letterSpacing: 0,
                  ),
                ),
                if (message != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    message!,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.mutedText,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                if (showCancel)
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(cancelLabel),
                  ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 40),
                    backgroundColor: destructive
                        ? AppColors.danger
                        : AppColors.primaryDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.medium),
                    ),
                  ),
                  child: Text(confirmLabel),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
