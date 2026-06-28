import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/language_widgets.dart';
import '../../../../core/presentation/app_ui.dart';
import '../../../../core/presentation/responsive.dart';
import '../providers/auth_providers.dart';
import '../widgets/app_snack_bar.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/primary_button.dart';

enum AuthMode { signIn, signUp }

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  AuthMode _mode = AuthMode.signIn;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool get _isSignUp => _mode == AuthMode.signUp;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = ref.read(authControllerProvider.notifier);
    final error = _isSignUp
        ? await controller.signUp(
            email: _emailController.text,
            password: _passwordController.text,
            displayName: _nameController.text,
          )
        : await controller.signIn(
            email: _emailController.text,
            password: _passwordController.text,
          );

    if (!mounted || error == null) return;
    showAppSnackBar(context, message: error, isError: true);
  }

  Future<void> _forgotPassword() async {
    final l10n = context.l10n;
    final email = _emailController.text.trim();
    if (!_isValidEmail(email)) {
      showAppSnackBar(context, message: l10n.enterEmailFirst, isError: true);
      return;
    }

    final error = await ref
        .read(authControllerProvider.notifier)
        .sendPasswordResetEmail(email);
    if (!mounted) return;
    showAppSnackBar(
      context,
      message: error ?? l10n.passwordResetEmailSent,
      isError: error != null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final responsive = AppResponsive.of(context);
    final isLoading = ref.watch(authControllerProvider).isLoading;

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Align(
                    alignment: Alignment.centerRight,
                    child: LanguageMenuButton(),
                  ),
                  SizedBox(height: responsive.compactHeight ? 10 : 18),
                  AppSurface(
                    padding: EdgeInsets.all(responsive.compactHeight ? 20 : 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _BrandHeader(compact: responsive.compactHeight),
                        SizedBox(height: responsive.compactHeight ? 22 : 28),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final vertical = constraints.maxWidth < 320;
                            return SegmentedButton<AuthMode>(
                              direction: vertical
                                  ? Axis.vertical
                                  : Axis.horizontal,
                              showSelectedIcon: false,
                              segments: [
                                ButtonSegment(
                                  value: AuthMode.signIn,
                                  icon: const Icon(Icons.login_rounded),
                                  label: Text(l10n.signIn),
                                ),
                                ButtonSegment(
                                  value: AuthMode.signUp,
                                  icon: const Icon(
                                    Icons.person_add_alt_1_rounded,
                                  ),
                                  label: Text(l10n.signUp),
                                ),
                              ],
                              selected: {_mode},
                              onSelectionChanged: isLoading
                                  ? null
                                  : (value) => setState(() {
                                      _mode = value.first;
                                      _formKey.currentState?.reset();
                                    }),
                            );
                          },
                        ),
                        const SizedBox(height: 22),
                        Form(
                          key: _formKey,
                          child: AnimatedSize(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOut,
                            child: Column(
                              children: [
                                if (_isSignUp) ...[
                                  AuthTextField(
                                    controller: _nameController,
                                    label: l10n.fullName,
                                    icon: Icons.badge_outlined,
                                    textInputAction: TextInputAction.next,
                                    validator: (value) {
                                      if ((value ?? '').trim().length < 2) {
                                        return l10n.enterName;
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                ],
                                AuthTextField(
                                  controller: _emailController,
                                  label: l10n.email,
                                  icon: Icons.alternate_email_rounded,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  validator: (value) {
                                    if (!_isValidEmail(value ?? '')) {
                                      return l10n.enterValidEmail;
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 14),
                                AuthTextField(
                                  controller: _passwordController,
                                  label: l10n.password,
                                  icon: Icons.lock_outline_rounded,
                                  obscureText: _obscurePassword,
                                  textInputAction: _isSignUp
                                      ? TextInputAction.next
                                      : TextInputAction.done,
                                  suffixIcon: IconButton(
                                    tooltip: _obscurePassword
                                        ? l10n.showPassword
                                        : l10n.hidePassword,
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                    ),
                                  ),
                                  validator: (value) {
                                    if ((value ?? '').length < 6) {
                                      return l10n.useAtLeastSixCharacters;
                                    }
                                    return null;
                                  },
                                ),
                                if (_isSignUp) ...[
                                  const SizedBox(height: 14),
                                  AuthTextField(
                                    controller: _confirmPasswordController,
                                    label: l10n.confirmPassword,
                                    icon: Icons.lock_reset_rounded,
                                    obscureText: _obscureConfirmPassword,
                                    textInputAction: TextInputAction.done,
                                    suffixIcon: IconButton(
                                      tooltip: _obscureConfirmPassword
                                          ? l10n.showPassword
                                          : l10n.hidePassword,
                                      onPressed: () {
                                        setState(() {
                                          _obscureConfirmPassword =
                                              !_obscureConfirmPassword;
                                        });
                                      },
                                      icon: Icon(
                                        _obscureConfirmPassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                      ),
                                    ),
                                    validator: (value) {
                                      if ((value ?? '').isEmpty) {
                                        return l10n.repeatYourPassword;
                                      }
                                      if (value != _passwordController.text) {
                                        return l10n.passwordsDoNotMatch;
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        if (!_isSignUp) ...[
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: isLoading ? null : _forgotPassword,
                              child: Text(l10n.forgotPassword),
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        PrimaryButton(
                          label: _isSignUp ? l10n.createAccount : l10n.signIn,
                          icon: _isSignUp
                              ? Icons.arrow_forward_rounded
                              : Icons.login_rounded,
                          isLoading: isLoading,
                          onPressed: _submit,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppBrandLogo(height: compact ? 58 : 68),
        SizedBox(height: compact ? 16 : 22),
        Text(
          l10n.authTagline,
          style: theme.textTheme.titleMedium?.copyWith(
            color: AppColors.mutedText,
          ),
        ),
      ],
    );
  }
}

bool _isValidEmail(String value) {
  return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim());
}
