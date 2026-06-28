import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/presentation/app_ui.dart';
import '../../../../core/presentation/responsive.dart';
import '../../domain/entities/app_user.dart';
import '../providers/auth_providers.dart';
import '../widgets/app_snack_bar.dart';
import '../widgets/primary_button.dart';

class EmailVerificationPage extends ConsumerWidget {
  const EmailVerificationPage({super.key, required this.user});

  final AppUser user;

  Future<void> _checkVerification(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final error = await ref
        .read(authControllerProvider.notifier)
        .reloadCurrentUser();
    if (!context.mounted) return;

    if (error != null) {
      showAppSnackBar(context, message: error, isError: true);
      return;
    }

    final refreshedUser = ref.read(authStateProvider).value;
    showAppSnackBar(
      context,
      message: refreshedUser?.isEmailVerified == true
          ? l10n.emailVerifiedWelcome
          : l10n.emailNotVerifiedYet,
      isError: refreshedUser?.isEmailVerified != true,
    );
  }

  Future<void> _resendVerification(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final error = await ref
        .read(authControllerProvider.notifier)
        .sendEmailVerification();
    if (!context.mounted) return;

    showAppSnackBar(
      context,
      message: error ?? l10n.verificationEmailSent(user.email),
      isError: error != null,
    );
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final error = await ref.read(authControllerProvider.notifier).signOut();
    if (!context.mounted || error == null) return;
    showAppSnackBar(context, message: error, isError: true);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final responsive = AppResponsive.of(context);
    final isLoading = ref.watch(authControllerProvider).isLoading;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.horizontalPadding,
              vertical: responsive.verticalPadding,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: responsive.authMaxWidth),
              child: AppSurface(
                padding: EdgeInsets.all(responsive.compactHeight ? 20 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: AppIconTile(
                        icon: Icons.mark_email_unread_rounded,
                        color: theme.colorScheme.primary,
                        size: 64,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      l10n.confirmYourEmail,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.emailVerificationInstructions(user.email),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.mutedText,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 28),
                    PrimaryButton(
                      label: l10n.iVerifiedMyEmail,
                      icon: Icons.verified_rounded,
                      isLoading: isLoading,
                      onPressed: () => _checkVerification(context, ref),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: isLoading
                          ? null
                          : () => _resendVerification(context, ref),
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(
                        l10n.resendVerificationEmail,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: isLoading
                          ? null
                          : () => _signOut(context, ref),
                      icon: const Icon(Icons.logout_rounded),
                      label: Text(
                        l10n.useAnotherAccount,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
