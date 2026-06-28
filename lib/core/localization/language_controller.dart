import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_localizations.dart';

final languageControllerProvider =
    StateNotifierProvider<LanguageController, AsyncValue<Locale?>>((ref) {
      final controller = LanguageController();
      controller.load();
      return controller;
    });

class LanguageController extends StateNotifier<AsyncValue<Locale?>> {
  LanguageController() : super(const AsyncLoading());

  static const _languageCodeKey = 'ai4good.languageCode';

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageCodeKey);
      final locale = _localeFromLanguageCode(languageCode);
      _setIntlLocale(locale);
      state = AsyncData(locale);
    } catch (_) {
      state = const AsyncData(null);
    }
  }

  Future<void> setLocale(Locale locale) async {
    final normalizedLocale = AppLocalizations.normalizedLocale(locale);
    _setIntlLocale(normalizedLocale);
    state = AsyncData(normalizedLocale);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageCodeKey, normalizedLocale.languageCode);
    } catch (_) {
      // The app can continue in-memory if persistence is unavailable.
    }
  }

  Locale? _localeFromLanguageCode(String? languageCode) {
    if (languageCode == null || languageCode.isEmpty) return null;
    return AppLocalizations.normalizedLocale(Locale(languageCode));
  }

  void _setIntlLocale(Locale? locale) {
    if (locale == null) return;
    Intl.defaultLocale = Intl.canonicalizedLocale(locale.toLanguageTag());
  }
}
