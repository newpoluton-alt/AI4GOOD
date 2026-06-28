import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../presentation/app_ui.dart';
import '../presentation/responsive.dart';
import 'app_localizations.dart';
import 'language_controller.dart';

class LanguageMenuButton extends ConsumerWidget {
  const LanguageMenuButton({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final selectedLocale =
        ref.watch(languageControllerProvider).valueOrNull ??
        AppLocalizations.normalizedLocale(Localizations.localeOf(context));

    return PopupMenuButton<Locale>(
      tooltip: l10n.changeLanguage,
      initialValue: selectedLocale,
      icon: child == null ? const Icon(Icons.language_rounded) : null,
      onSelected: ref.read(languageControllerProvider.notifier).setLocale,
      itemBuilder: (context) {
        return AppLocalizations.supportedLocales.map((locale) {
          final isSelected = selectedLocale.languageCode == locale.languageCode;
          return PopupMenuItem<Locale>(
            value: locale,
            child: Row(
              children: [
                Expanded(
                  child: Text(AppLocalizations.nativeLanguageName(locale)),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              ],
            ),
          );
        }).toList();
      },
      child: child,
    );
  }
}

class LanguageStartPage extends ConsumerWidget {
  const LanguageStartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final responsive = AppResponsive.of(context);

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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _LanguageBrandMark(
                        compact: responsive.compactHeight,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      l10n.chooseLanguageTitle,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                            letterSpacing: 0,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.chooseLanguageSubtitle,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.mutedText,
                        height: 1.45,
                      ),
                    ),
                    SizedBox(height: responsive.compactHeight ? 20 : 30),
                    _LanguageChoiceButton(
                      locale: const Locale('en'),
                      icon: Icons.translate_rounded,
                      onSelected: (locale) {
                        ref
                            .read(languageControllerProvider.notifier)
                            .setLocale(locale);
                      },
                    ),
                    const SizedBox(height: 12),
                    _LanguageChoiceButton(
                      locale: const Locale('fr'),
                      icon: Icons.language_rounded,
                      onSelected: (locale) {
                        ref
                            .read(languageControllerProvider.notifier)
                            .setLocale(locale);
                      },
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

class _LanguageBrandMark extends StatelessWidget {
  const _LanguageBrandMark({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return AppBrandLogo(height: compact ? 58 : 68);
  }
}

class _LanguageChoiceButton extends StatelessWidget {
  const _LanguageChoiceButton({
    required this.locale,
    required this.icon,
    required this.onSelected,
  });

  final Locale locale;
  final IconData icon;
  final ValueChanged<Locale> onSelected;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => onSelected(locale),
      icon: Icon(icon),
      label: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          AppLocalizations.nativeLanguageName(locale),
          textAlign: TextAlign.center,
        ),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    );
  }
}
