import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class AppLocalizations {
  const AppLocalizations._(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('en'), Locale('fr')];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final localizations = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    assert(localizations != null, 'AppLocalizations not found in context.');
    return localizations!;
  }

  static Locale normalizedLocale(Locale locale) {
    return Locale(_normalizeLanguageCode(locale.languageCode));
  }

  static String nativeLanguageName(Locale locale) {
    return normalizedLocale(locale).languageCode == 'fr'
        ? 'Français'
        : 'English';
  }

  static bool isSupported(Locale locale) {
    final languageCode = locale.languageCode.toLowerCase();
    return languageCode == 'en' || languageCode == 'fr';
  }

  static String _normalizeLanguageCode(String languageCode) {
    return languageCode.toLowerCase() == 'fr' ? 'fr' : 'en';
  }

  String get languageCode => _normalizeLanguageCode(locale.languageCode);

  Map<String, String> get _values {
    return _localizedValues[languageCode] ?? _localizedValues['en']!;
  }

  String _text(String key) {
    return _values[key] ?? _localizedValues['en']![key] ?? key;
  }

  String get appTitle => _text('appTitle');
  String get chooseLanguageTitle => _text('chooseLanguageTitle');
  String get chooseLanguageSubtitle => _text('chooseLanguageSubtitle');
  String get englishLanguage => _text('englishLanguage');
  String get frenchLanguage => _text('frenchLanguage');
  String get changeLanguage => _text('changeLanguage');
  String get currentLanguageName {
    return nativeLanguageName(locale);
  }

  String currentLanguage(String language) {
    return _text('currentLanguage').replaceAll('{language}', language);
  }

  String languageNameFor(Locale locale) {
    return nativeLanguageName(locale);
  }

  String get authTagline => _text('authTagline');
  String get signIn => _text('signIn');
  String get signUp => _text('signUp');
  String get fullName => _text('fullName');
  String get email => _text('email');
  String get password => _text('password');
  String get confirmPassword => _text('confirmPassword');
  String get showPassword => _text('showPassword');
  String get hidePassword => _text('hidePassword');
  String get forgotPassword => _text('forgotPassword');
  String get createAccount => _text('createAccount');
  String get enterEmailFirst => _text('enterEmailFirst');
  String get passwordResetEmailSent => _text('passwordResetEmailSent');
  String get enterName => _text('enterName');
  String get enterValidEmail => _text('enterValidEmail');
  String get useAtLeastSixCharacters => _text('useAtLeastSixCharacters');
  String get repeatYourPassword => _text('repeatYourPassword');
  String get passwordsDoNotMatch => _text('passwordsDoNotMatch');

  String get confirmYourEmail => _text('confirmYourEmail');
  String emailVerificationInstructions(String email) {
    return _text('emailVerificationInstructions').replaceAll('{email}', email);
  }

  String get emailVerifiedWelcome => _text('emailVerifiedWelcome');
  String get emailNotVerifiedYet => _text('emailNotVerifiedYet');
  String verificationEmailSent(String email) {
    return _text('verificationEmailSent').replaceAll('{email}', email);
  }

  String get iVerifiedMyEmail => _text('iVerifiedMyEmail');
  String get resendVerificationEmail => _text('resendVerificationEmail');
  String get useAnotherAccount => _text('useAnotherAccount');

  String get home => _text('home');
  String get profile => _text('profile');
  String get homeHeroTitle => _text('homeHeroTitle');
  String get homeHeroSubtitle => _text('homeHeroSubtitle');
  String get ideas => _text('ideas');
  String get collaborators => _text('collaborators');
  String get milestones => _text('milestones');
  String get communities => _text('communities');

  String get ai4goodMember => _text('ai4goodMember');
  String get changeEmail => _text('changeEmail');
  String get changeEmailSubtitle => _text('changeEmailSubtitle');
  String get signOut => _text('signOut');
  String get leaveSession => _text('leaveSession');
  String get newEmail => _text('newEmail');
  String get cancel => _text('cancel');
  String get sendLink => _text('sendLink');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.isSupported(locale);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final normalizedLocale = AppLocalizations.normalizedLocale(locale);
    Intl.defaultLocale = Intl.canonicalizedLocale(
      normalizedLocale.toLanguageTag(),
    );
    return AppLocalizations._(normalizedLocale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

const _localizedValues = <String, Map<String, String>>{
  'en': {
    'appTitle': 'Doctors for Madagascar',
    'chooseLanguageTitle': 'Choose your language',
    'chooseLanguageSubtitle':
        'Select the language you want to use in Doctors for Madagascar.',
    'englishLanguage': 'English',
    'frenchLanguage': 'French',
    'changeLanguage': 'Change language',
    'currentLanguage': 'Current language: {language}',
    'authTagline': 'Build positive impact with intelligent tools.',
    'signIn': 'Sign in',
    'signUp': 'Sign up',
    'fullName': 'Full name',
    'email': 'Email',
    'password': 'Password',
    'confirmPassword': 'Confirm password',
    'showPassword': 'Show password',
    'hidePassword': 'Hide password',
    'forgotPassword': 'Forgot password?',
    'createAccount': 'Create account',
    'enterEmailFirst': 'Enter your email first.',
    'passwordResetEmailSent': 'Password reset email sent.',
    'enterName': 'Enter your name.',
    'enterValidEmail': 'Enter a valid email.',
    'useAtLeastSixCharacters': 'Use at least 6 characters.',
    'repeatYourPassword': 'Repeat your password.',
    'passwordsDoNotMatch': 'Passwords do not match.',
    'confirmYourEmail': 'Confirm your email',
    'emailVerificationInstructions':
        'We sent a verification link to {email}. Open it, then come back and check verification.',
    'emailVerifiedWelcome': 'Email verified. Welcome in.',
    'emailNotVerifiedYet':
        'Email is not verified yet. Please check your inbox.',
    'verificationEmailSent': 'Verification email sent to {email}.',
    'iVerifiedMyEmail': 'I verified my email',
    'resendVerificationEmail': 'Resend verification email',
    'useAnotherAccount': 'Use another account',
    'home': 'Home',
    'profile': 'Profile',
    'homeHeroTitle': 'Create measurable good with focused AI.',
    'homeHeroSubtitle':
        'Track ideas, shape projects, and keep your impact work moving.',
    'ideas': 'Ideas',
    'collaborators': 'Collaborators',
    'milestones': 'Milestones',
    'communities': 'Communities',
    'ai4goodMember': 'Doctors for Madagascar member',
    'changeEmail': 'Change email',
    'changeEmailSubtitle': 'Send a verification link to a new address',
    'signOut': 'Log out',
    'leaveSession': 'End this session',
    'newEmail': 'New email',
    'cancel': 'Cancel',
    'sendLink': 'Send link',
  },
  'fr': {
    'appTitle': 'Doctors for Madagascar',
    'chooseLanguageTitle': 'Choisissez votre langue',
    'chooseLanguageSubtitle':
        'Sélectionnez la langue que vous voulez utiliser dans Doctors for Madagascar.',
    'englishLanguage': 'Anglais',
    'frenchLanguage': 'Français',
    'changeLanguage': 'Changer de langue',
    'currentLanguage': 'Langue actuelle : {language}',
    'authTagline': 'Créez un impact positif avec des outils intelligents.',
    'signIn': 'Se connecter',
    'signUp': "S'inscrire",
    'fullName': 'Nom complet',
    'email': 'Adresse e-mail',
    'password': 'Mot de passe',
    'confirmPassword': 'Confirmer le mot de passe',
    'showPassword': 'Afficher le mot de passe',
    'hidePassword': 'Masquer le mot de passe',
    'forgotPassword': 'Mot de passe oublié ?',
    'createAccount': 'Créer un compte',
    'enterEmailFirst': "Saisissez d'abord votre adresse e-mail.",
    'passwordResetEmailSent': 'E-mail de réinitialisation envoyé.',
    'enterName': 'Saisissez votre nom.',
    'enterValidEmail': 'Saisissez une adresse e-mail valide.',
    'useAtLeastSixCharacters': 'Utilisez au moins 6 caractères.',
    'repeatYourPassword': 'Répétez votre mot de passe.',
    'passwordsDoNotMatch': 'Les mots de passe ne correspondent pas.',
    'confirmYourEmail': 'Confirmez votre adresse e-mail',
    'emailVerificationInstructions':
        "Nous avons envoyé un lien de vérification à {email}. Ouvrez-le, puis revenez vérifier la confirmation.",
    'emailVerifiedWelcome': 'Adresse e-mail vérifiée. Bienvenue.',
    'emailNotVerifiedYet':
        "L'adresse e-mail n'est pas encore vérifiée. Vérifiez votre boîte de réception.",
    'verificationEmailSent': 'E-mail de vérification envoyé à {email}.',
    'iVerifiedMyEmail': "J'ai vérifié mon adresse e-mail",
    'resendVerificationEmail': "Renvoyer l'e-mail de vérification",
    'useAnotherAccount': 'Utiliser un autre compte',
    'home': 'Accueil',
    'profile': 'Profil',
    'homeHeroTitle': 'Créez un impact mesurable avec une IA ciblée.',
    'homeHeroSubtitle':
        "Suivez vos idées, structurez vos projets et faites avancer votre travail d'impact.",
    'ideas': 'Idées',
    'collaborators': 'Collaborateurs',
    'milestones': 'Jalons',
    'communities': 'Communautés',
    'ai4goodMember': 'Membre Doctors for Madagascar',
    'changeEmail': "Changer l'adresse e-mail",
    'changeEmailSubtitle':
        'Envoyer un lien de vérification à une nouvelle adresse',
    'signOut': 'Se déconnecter',
    'leaveSession': 'Quitter cette session',
    'newEmail': 'Nouvelle adresse e-mail',
    'cancel': 'Annuler',
    'sendLink': 'Envoyer le lien',
  },
};
