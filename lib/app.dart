import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/localization/app_localizations.dart';
import 'core/localization/language_controller.dart';
import 'core/localization/language_widgets.dart';
import 'core/presentation/app_ui.dart';
import 'features/auth/presentation/pages/auth_gate.dart';

class AI4GoodApp extends ConsumerWidget {
  const AI4GoodApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const seed = AppColors.primary;
    final languageState = ref.watch(languageControllerProvider);
    final selectedLocale = languageState.valueOrNull;

    return MaterialApp(
      title: 'Doctors for Madagascar',
      onGenerateTitle: (context) => context.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      locale: selectedLocale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (selectedLocale != null) return selectedLocale;
        if (locale != null && locale.languageCode.toLowerCase() == 'fr') {
          return const Locale('fr');
        }
        return const Locale('en');
      },
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
          primary: AppColors.primary,
          secondary: const Color(0xFF2457D6),
          tertiary: const Color(0xFFB66016),
          error: AppColors.danger,
          surface: AppColors.surface,
          surfaceContainerHighest: AppColors.surfaceAlt,
        ),
        scaffoldBackgroundColor: AppColors.background,
        dividerTheme: const DividerThemeData(
          color: AppColors.border,
          thickness: 1,
          space: 1,
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.medium),
            side: const BorderSide(color: AppColors.border),
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.medium),
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          modalBackgroundColor: Colors.transparent,
          showDragHandle: false,
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.medium),
          ),
          contentTextStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadii.medium),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadii.medium),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadii.medium),
            borderSide: const BorderSide(color: seed, width: 1.4),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadii.medium),
            borderSide: const BorderSide(color: AppColors.danger),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadii.medium),
            borderSide: const BorderSide(color: AppColors.danger, width: 1.4),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.medium),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            foregroundColor: AppColors.primaryDark,
            side: const BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.medium),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.medium),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          height: 68,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          indicatorShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.medium),
          ),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            return TextStyle(
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w700
                  : null,
            );
          }),
        ),
        navigationRailTheme: const NavigationRailThemeData(
          backgroundColor: Colors.white,
          selectedIconTheme: IconThemeData(color: AppColors.primaryDark),
          unselectedIconTheme: IconThemeData(color: AppColors.softText),
          selectedLabelTextStyle: TextStyle(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.w800,
          ),
          unselectedLabelTextStyle: TextStyle(color: AppColors.mutedText),
        ),
      ),
      home: languageState.isLoading
          ? const _AppStartupPage()
          : selectedLocale == null
          ? const LanguageStartPage()
          : const AuthGate(),
    );
  }
}

class _AppStartupPage extends StatelessWidget {
  const _AppStartupPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
