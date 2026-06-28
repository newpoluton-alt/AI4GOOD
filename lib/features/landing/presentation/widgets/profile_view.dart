import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/language_widgets.dart';
import '../../../../core/presentation/app_ui.dart';
import '../../../../core/presentation/responsive.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/widgets/app_snack_bar.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final error = await ref.read(authControllerProvider.notifier).signOut();
    if (!context.mounted || error == null) return;
    showAppSnackBar(context, message: error, isError: true);
  }

  Future<void> _changeEmail(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final newEmail = await showDialog<String>(
      context: context,
      builder: (_) => const _ChangeEmailDialog(),
    );
    if (newEmail == null) return;

    final error = await ref
        .read(authControllerProvider.notifier)
        .changeEmail(newEmail);
    if (!context.mounted) return;
    showAppSnackBar(
      context,
      message: error ?? l10n.verificationEmailSent(newEmail),
      isError: error != null,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final responsive = AppResponsive.of(context);
    final user = ref.watch(authStateProvider).value;
    final isLoading = ref.watch(authControllerProvider).isLoading;
    final theme = Theme.of(context);
    final initial = (user?.displayName?.isNotEmpty ?? false)
        ? user!.displayName![0].toUpperCase()
        : (user?.email.isNotEmpty ?? false)
        ? user!.email[0].toUpperCase()
        : 'A';

    return SafeArea(
      child: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: responsive.horizontalPadding,
          vertical: responsive.verticalPadding,
        ),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: responsive.contentMaxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.profile,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 22),
                  AppSurface(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 34,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Text(
                            initial,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.displayName?.isNotEmpty == true
                                    ? user!.displayName!
                                    : l10n.ai4goodMember,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user?.email ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.mutedText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _LanguageProfileAction(
                    title: l10n.changeLanguage,
                    subtitle: l10n.currentLanguage(l10n.currentLanguageName),
                  ),
                  const SizedBox(height: 10),
                  _ProfileAction(
                    icon: Icons.alternate_email_rounded,
                    title: l10n.changeEmail,
                    subtitle: l10n.changeEmailSubtitle,
                    onTap: isLoading ? null : () => _changeEmail(context, ref),
                  ),
                  const SizedBox(height: 10),
                  _ProfileAction(
                    icon: Icons.logout_rounded,
                    title: l10n.signOut,
                    subtitle: l10n.leaveSession,
                    isDestructive: true,
                    onTap: isLoading ? null : () => _signOut(context, ref),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageProfileAction extends StatelessWidget {
  const _LanguageProfileAction({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return LanguageMenuButton(
      child: ListTile(
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.medium),
          side: const BorderSide(color: AppColors.border),
        ),
        leading: Icon(
          Icons.language_rounded,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.expand_more_rounded),
      ),
    );
  }
}

class _ProfileAction extends StatelessWidget {
  const _ProfileAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;

    return ListTile(
      onTap: onTap,
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.medium),
        side: const BorderSide(color: AppColors.border),
      ),
      leading: Icon(icon, color: color),
      title: Text(
        title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }
}

class _ChangeEmailDialog extends StatefulWidget {
  const _ChangeEmailDialog();

  @override
  State<_ChangeEmailDialog> createState() => _ChangeEmailDialogState();
}

class _ChangeEmailDialogState extends State<_ChangeEmailDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AlertDialog(
      scrollable: true,
      title: Text(l10n.changeEmail),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: l10n.newEmail,
            prefixIcon: const Icon(Icons.alternate_email_rounded),
          ),
          validator: (value) {
            if (!RegExp(
              r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
            ).hasMatch((value ?? '').trim())) {
              return l10n.enterValidEmail;
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.of(context).pop(_emailController.text.trim());
          },
          child: Text(l10n.sendLink),
        ),
      ],
    );
  }
}
