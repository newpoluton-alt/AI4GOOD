# AI4Good Architecture Documentation

This document describes the changes made to the Flutter project so far, the architectural decisions behind them, the libraries added, the file structure, and the purpose of each important class, method, abstraction, provider, screen, and widget.

## Summary Of Work Completed

The original Flutter counter starter app was replaced with a Firebase-backed authentication and landing experience using Clean Architecture principles.

Implemented features:

- Firebase initialization at app startup.
- Email/password sign in.
- Email/password sign up.
- Email verification during sign up.
- Authenticated users with unverified emails are held on an email confirmation screen until verification is complete.
- Resend verification email flow.
- Manual "I verified my email" refresh flow.
- Firestore profile document creation during sign up.
- Forgot password flow using Firebase Auth password reset email.
- Auth gate that switches between authenticated and unauthenticated UI.
- Landing page after login.
- First-run language selection for English and French.
- Persisted app language preference using Riverpod and shared preferences.
- Auth-page language switcher so users can change language before signing in or signing up.
- Flutter localization delegates for app, Material, widgets, and Cupertino text.
- Responsive layout rules for mobile phones, tablets, and desktop/web monitors.
- Responsive overflow hardening for compact phones, tablets, and desktop-width layouts, including adaptive headers, loading overlays, dialogs, table/card switches, and workflow action buttons.
- English/French localization review for the authenticated profile actions and the AI Data Review workflow copy.
- Bottom navigation menu with Home and Profile on mobile/tablet.
- Navigation rail with Home and Profile on desktop-width layouts.
- Shared app UI primitives for surfaces, pills, icon tiles, sheet handles, and error states.
- A uniform Material 3 visual system across language selection, auth, email verification, Home, Profile, and Data Review screens.
- Responsive workflow menu on the authenticated Home screen using an adaptive modal bottom sheet instead of oversized stacked menu buttons.
- Profile screen with:
  - current user display
  - language change action
  - log out
  - change email using Firebase verification email flow
- AI Data Review + Analysis workflow connected to the FastAPI backend:
  - main workflow menu after login
  - Excel/CSV upload through authenticated multipart API calls
  - backend-driven data preview table with sheet selection, horizontal/vertical exploration, wrapped cell content, and page controls
  - deterministic backend data-quality review behind the **AI review** button
  - grouped issue review modal with individual, group, and reject-all-pending decisions
  - processed Excel finalization and presigned download URL opening
  - My data listing, view, delete-one, delete-all, and processed-download flows
  - finalized dataset selection, analysis instructions, job polling, Markdown report display, report copy, and authenticated PDF export
- Riverpod-based dependency injection and state management.
- Domain-level abstractions to keep business logic separate from UI and Firebase data access.
- A small unit test for domain entity value equality.

## Libraries Added

The following dependencies were added to `pubspec.yaml`.

| Library | Purpose |
| --- | --- |
| `firebase_core` | Initializes Firebase before using Firebase services. |
| `firebase_auth` | Provides Firebase email/password authentication, sign-up email verification, password reset, sign out, and email update verification. |
| `cloud_firestore` | Stores user profile metadata, email verification status, and pending email updates. |
| `flutter_riverpod` | Provides dependency injection, state management, and reactive auth state handling. |
| `flutter_localizations` | Provides Flutter's built-in localized Material, widgets, and Cupertino delegates. |
| `intl` | Normalizes and stores the active locale for internationalization behavior. |
| `shared_preferences` | Persists the user's selected language between app launches. |
| `dartz` | Provides `Either<Failure, T>` so repository methods return success or failure explicitly instead of throwing exceptions to the UI. |
| `equatable` | Provides value equality for domain entities and parameter objects. |
| `http` | Sends authenticated REST, multipart upload, and binary PDF download requests to the FastAPI backend. |
| `file_picker` | Lets users select Excel/CSV files for upload. |
| `url_launcher` | Opens presigned processed Excel download URLs returned by the backend. |
| `flutter_markdown` | Renders AI analysis `report_markdown` in the app. |
| `file_saver` | Saves authenticated PDF report bytes on supported platforms. |
| `cupertino_icons` | Existing Flutter icon dependency retained. |

Development dependency retained:

| Library | Purpose |
| --- | --- |
| `flutter_lints` | Static lint rules for cleaner Dart and Flutter code. |
| `flutter_test` | Flutter testing framework. |

## Architectural Choice

The app now follows a Clean Architecture-inspired structure:

```text
lib/
  core/
    config/
    errors/
    network/
    usecases/
  features/
    auth/
      data/
      domain/
      presentation/
    data_review/
      data/
      domain/
      presentation/
    landing/
      presentation/
```

The main goal is separation of concerns:

- `presentation` contains Flutter UI, Riverpod controllers, and widgets.
- `domain` contains business entities, repository contracts, and use cases.
- `data` contains Firebase-specific implementations.
- `core` contains shared app-level abstractions.

This means Firebase-specific code does not leak into widgets, and UI code does not directly own business rules or low-level data access.

## Dependency Direction

Dependencies flow inward:

```text
UI / Presentation
  depends on Use Cases and Providers

Domain
  defines Entities, Use Cases, Repository Interfaces

Data
  implements Repository Interfaces using Firebase Auth and Firestore
```

Important rule:

The domain layer does not import Firebase, Flutter widgets, or Riverpod. It remains pure Dart business logic.

Important testing-file rule:

Do not create feature testing, scratch testing, manual testing, experiment, sandbox, or temporary `.dart` files inside `lib/` or anywhere else in the project. Test files must only be created under the standard Flutter `test/` folder, and only when explicitly requested.

## File Structure

```text
lib/
  app.dart
  firebase_options.dart
  main.dart
  core/
    config/
      api_config.dart
    errors/
      failure.dart
    localization/
      app_localizations.dart
      language_controller.dart
      language_widgets.dart
    network/
      api_client.dart
    presentation/
      app_ui.dart
      responsive.dart
    usecases/
      usecase.dart
  features/
    auth/
      data/
        datasources/
          auth_remote_data_source.dart
        models/
          app_user_model.dart
        repositories/
          auth_repository_impl.dart
      domain/
        entities/
          app_user.dart
        repositories/
          auth_repository.dart
        usecases/
          change_email.dart
          reload_current_user.dart
          send_email_verification.dart
          send_password_reset_email.dart
          sign_in.dart
          sign_out.dart
          sign_up.dart
      presentation/
        pages/
          auth_gate.dart
          auth_page.dart
          email_verification_page.dart
        providers/
          auth_providers.dart
        widgets/
          app_snack_bar.dart
          auth_text_field.dart
          primary_button.dart
    landing/
      presentation/
        pages/
          landing_page.dart
        widgets/
          home_view.dart
          profile_view.dart
    data_review/
      data/
        datasources/
          data_review_remote_data_source.dart
        models/
          analysis_models.dart
          dataset_models.dart
          review_models.dart
        repositories/
          data_review_repository_impl.dart
      domain/
        repositories/
          data_review_repository.dart
      presentation/
        data_review_strings.dart
        pages/
          analysis_instruction_page.dart
          analysis_report_page.dart
          data_preview_page.dart
          data_select_page.dart
          data_upload_page.dart
          main_menu_page.dart
          my_data_page.dart
        providers/
          analysis_controller.dart
          data_preview_controller.dart
          data_review_providers.dart
          data_upload_controller.dart
          my_data_controller.dart
        widgets/
          app_page_shell.dart
          confirmation_dialog.dart
          dataset_table.dart
          empty_state.dart
          issue_review_dialog.dart
          loading_overlay.dart
test/
  app_user_test.dart
```

## Root App Files

### `lib/main.dart`

Purpose:

- App entry point.
- Ensures Flutter bindings are initialized.
- Initializes Firebase using generated platform options.
- Wraps the app with Riverpod `ProviderScope`.

Important function:

```dart
Future<void> main() async
```

Responsibilities:

- Calls `WidgetsFlutterBinding.ensureInitialized()`.
- Calls `Firebase.initializeApp(...)`.
- Runs `AI4GoodApp`.

### `lib/app.dart`

Purpose:

- Defines the root `MaterialApp`.
- Sets app title, theme, Material 3 styling, input field styling, button styling, navigation bar styling, localization delegates, supported locales, and the first screen.

Important class:

```dart
class AI4GoodApp extends ConsumerWidget
```

Responsibilities:

- Creates a contemporary visual style with Material 3.
- Watches `languageControllerProvider` to load the saved language preference.
- Supports English and French through `AppLocalizations`, `GlobalMaterialLocalizations`, `GlobalWidgetsLocalizations`, and `GlobalCupertinoLocalizations`.
- Uses `LanguageStartPage` as the app home until the user chooses a language for the first time.
- Uses `AuthGate` after language selection so authentication state decides the visible route.

### `lib/firebase_options.dart`

Purpose:

- Generated by FlutterFire CLI.
- Contains Firebase configuration for web, Android, iOS, macOS, and Windows.

Important class:

```dart
class DefaultFirebaseOptions
```

Responsibilities:

- Selects the correct `FirebaseOptions` for the current platform.

## Core Layer

The `core` layer contains abstractions shared across features.

### `lib/core/localization/app_localizations.dart`

Purpose:

- Defines the app-owned localization catalog for English and French.
- Exposes `AppLocalizations.of(context)` and the `context.l10n` extension for UI code.
- Provides the app localization delegate used by `MaterialApp`.
- Normalizes unsupported locales to English while only advertising English and French as supported locales.

Important class:

```dart
class AppLocalizations
```

Responsibilities:

- Stores translated UI strings for auth, verification, landing, profile, validation, and success messages.
- Stores profile action labels and messages for changing language, changing email, logging out, and showing the current language.
- Provides helper methods for dynamic text such as verification emails that include an address.
- Uses native language names (`English`, `Français`) in language selectors so users can recognize their language even before the UI switches.

Important delegate:

```dart
class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations>
```

Responsibilities:

- Loads the normalized app locale.
- Sets `Intl.defaultLocale` to the active language tag.
- Reports support for English and French.

### `lib/core/localization/language_controller.dart`

Purpose:

- Owns the selected app language as Riverpod state.
- Persists the language selection across app launches.

Important provider:

```dart
final languageControllerProvider =
    StateNotifierProvider<LanguageController, AsyncValue<Locale?>>
```

Important class:

```dart
class LanguageController extends StateNotifier<AsyncValue<Locale?>>
```

Responsibilities:

- Loads the saved language code from `SharedPreferences`.
- Returns `null` when no language has been selected yet so the root app can show the first-run language screen.
- Saves English or French when the user chooses a language.
- Keeps `Intl.defaultLocale` aligned with the selected locale.

### `lib/core/localization/language_widgets.dart`

Purpose:

- Provides reusable language-selection UI.

Important widgets:

```dart
class LanguageStartPage extends ConsumerWidget
```

- First screen shown when no language preference exists.
- Lets users choose English or French before auth UI appears.
- Uses the same responsive padding and max width rules as auth screens.

```dart
class LanguageMenuButton extends ConsumerWidget
```

- Popup language selector used on the auth page and profile page.
- Persists the newly selected language through `LanguageController`.
- Shows the selected language with a check mark.

### `lib/core/presentation/responsive.dart`

Purpose:

- Centralizes responsive layout decisions for mobile, tablet, and desktop/web monitor widths.

Important class:

```dart
class AppResponsive
```

Responsibilities:

- Defines tablet and desktop breakpoints (`600` and `1024` logical pixels).
- Provides shared horizontal/vertical padding.
- Provides auth and content max widths so forms and dashboards do not stretch across large monitors.
- Provides metric-grid column counts and aspect ratios for responsive dashboard cards.
- Decides when the landing shell should switch from bottom navigation to a navigation rail.
- Exposes compact-list and sheet-width decisions so table-heavy pages can switch from desktop tables to mobile-friendly cards.
- Individual pages combine these breakpoints with `LayoutBuilder` so layout decisions can use the actual available panel width, not only the full device width.

### `lib/core/presentation/app_ui.dart`

Purpose:

- Centralizes shared presentation constants and reusable UI primitives.
- Keeps auth, profile, workflow, dialogs, loading, empty, and error states visually consistent.

Important classes:

```dart
class AppColors
class AppRadii
class AppSpacing
class AppSurface
class AppInfoPill
class AppErrorView
class AppSheetHandle
class AppIconTile
```

Responsibilities:

- Provides app-level color tokens, spacing, and compact radius values.
- Provides bordered/elevated surfaces for cards, dialogs, and panels.
- Provides reusable status pills and icon tiles.
- Provides a consistent error panel with optional retry action.
- Provides a simple handle for adaptive bottom-sheet menus and dialogs.

### `lib/core/errors/failure.dart`

Purpose:

- Defines a domain-friendly error object.
- Prevents Firebase exceptions from being passed directly into UI and domain code.

Important class:

```dart
class Failure extends Equatable
```

Fields:

- `message`: human-readable error message.

Why it exists:

- Repositories return `Either<Failure, T>`.
- The UI can show a clean error message without knowing which package caused the error.

### `lib/core/usecases/usecase.dart`

Purpose:

- Defines a common use case contract.
- Provides a `NoParams` object for use cases that do not require input.

Important abstraction:

```dart
abstract class UseCase<Type, Params>
```

Important method:

```dart
Future<Either<Failure, Type>> call(Params params);
```

Why it exists:

- Each business action has a consistent API.
- Presentation code can invoke use cases the same way.

Important class:

```dart
class NoParams
```

Used by:

- `SignOut`, because signing out does not require input parameters.

## Auth Feature

The Auth feature is split into three layers:

- `domain`: business contracts and use cases.
- `data`: Firebase implementation.
- `presentation`: UI and Riverpod state.

## Auth Domain Layer

### `lib/features/auth/domain/entities/app_user.dart`

Purpose:

- Defines the app's own user entity.
- Keeps the domain independent from Firebase's `User` class.

Important class:

```dart
class AppUser extends Equatable
```

Fields:

- `id`: unique user ID, mapped from Firebase `uid`.
- `email`: user email.
- `isEmailVerified`: whether Firebase Auth has verified the user's email address.
- `displayName`: optional display name.

Why it exists:

- UI and business logic use `AppUser`, not Firebase's `User`.
- This makes the domain easier to test and change later.

### `lib/features/auth/domain/repositories/auth_repository.dart`

Purpose:

- Defines the contract that any auth data implementation must follow.
- The domain layer knows this abstraction, not Firebase.

Important abstraction:

```dart
abstract class AuthRepository
```

Methods:

```dart
Stream<AppUser?> authStateChanges();
```

- Emits the currently signed-in user or `null`.
- Used by `AuthGate` to decide whether to show auth UI, email verification UI, or landing UI.

```dart
Future<Either<Failure, AppUser>> signIn({
  required String email,
  required String password,
});
```

- Signs in a user with email and password.
- Returns either `Failure` or `AppUser`.

```dart
Future<Either<Failure, AppUser>> signUp({
  required String email,
  required String password,
  required String displayName,
});
```

- Creates a new Firebase Auth account.
- Sends a Firebase email verification message after account creation.
- Returns either `Failure` or `AppUser`.

```dart
Future<Either<Failure, void>> sendPasswordResetEmail(String email);
```

- Sends a password reset email.

```dart
Future<Either<Failure, void>> sendEmailVerification();
```

- Sends or resends the Firebase email verification message for the currently signed-in user.

```dart
Future<Either<Failure, AppUser?>> reloadCurrentUser();
```

- Reloads the current Firebase user and returns the refreshed app user.
- Used after the user clicks the email verification link and returns to the app.

```dart
Future<Either<Failure, void>> signOut();
```

- Signs out the current user.

```dart
Future<Either<Failure, void>> changeEmail(String newEmail);
```

- Starts the email-change verification flow.

### `lib/features/auth/domain/usecases/sign_in.dart`

Purpose:

- Encapsulates the sign-in business operation.

Important class:

```dart
class SignIn implements UseCase<AppUser, SignInParams>
```

Important method:

```dart
Future<Either<Failure, AppUser>> call(SignInParams params)
```

Responsibilities:

- Calls `AuthRepository.signIn(...)`.
- Keeps the presentation layer from calling repository methods directly.

Important params class:

```dart
class SignInParams extends Equatable
```

Fields:

- `email`
- `password`

### `lib/features/auth/domain/usecases/sign_up.dart`

Purpose:

- Encapsulates the sign-up business operation.

Important class:

```dart
class SignUp implements UseCase<AppUser, SignUpParams>
```

Important method:

```dart
Future<Either<Failure, AppUser>> call(SignUpParams params)
```

Responsibilities:

- Calls `AuthRepository.signUp(...)`.

Important params class:

```dart
class SignUpParams extends Equatable
```

Fields:

- `email`
- `password`
- `displayName`

### `lib/features/auth/domain/usecases/send_password_reset_email.dart`

Purpose:

- Encapsulates forgot-password behavior.

Important class:

```dart
class SendPasswordResetEmail implements UseCase<void, String>
```

Important method:

```dart
Future<Either<Failure, void>> call(String params)
```

Responsibilities:

- Calls `AuthRepository.sendPasswordResetEmail(...)`.

### `lib/features/auth/domain/usecases/send_email_verification.dart`

Purpose:

- Encapsulates sending or resending the sign-up email verification message.

Important class:

```dart
class SendEmailVerification implements UseCase<void, NoParams>
```

Important method:

```dart
Future<Either<Failure, void>> call(NoParams params)
```

Responsibilities:

- Calls `AuthRepository.sendEmailVerification()`.

### `lib/features/auth/domain/usecases/reload_current_user.dart`

Purpose:

- Encapsulates refreshing the current Firebase user after email verification.

Important class:

```dart
class ReloadCurrentUser implements UseCase<AppUser?, NoParams>
```

Important method:

```dart
Future<Either<Failure, AppUser?>> call(NoParams params)
```

Responsibilities:

- Calls `AuthRepository.reloadCurrentUser()`.
- Allows the app to discover that `emailVerified` changed after the user opened the Firebase verification link.

### `lib/features/auth/domain/usecases/sign_out.dart`

Purpose:

- Encapsulates sign-out behavior.

Important class:

```dart
class SignOut implements UseCase<void, NoParams>
```

Important method:

```dart
Future<Either<Failure, void>> call(NoParams params)
```

Responsibilities:

- Calls `AuthRepository.signOut()`.

### `lib/features/auth/domain/usecases/change_email.dart`

Purpose:

- Encapsulates email change behavior.

Important class:

```dart
class ChangeEmail implements UseCase<void, String>
```

Important method:

```dart
Future<Either<Failure, void>> call(String params)
```

Responsibilities:

- Calls `AuthRepository.changeEmail(...)`.

## Auth Data Layer

The data layer contains Firebase-specific logic.

### `lib/features/auth/data/models/app_user_model.dart`

Purpose:

- Converts Firebase `User` objects into the domain entity shape.

Important class:

```dart
class AppUserModel extends AppUser
```

Important factory:

```dart
factory AppUserModel.fromFirebaseUser(User user)
```

Responsibilities:

- Maps `user.uid` to `id`.
- Maps `user.email` to `email`.
- Maps `user.emailVerified` to `isEmailVerified`.
- Maps `user.displayName` to `displayName`.

Why it exists:

- Firebase mapping belongs in the data layer, not the domain or UI.

### `lib/features/auth/data/datasources/auth_remote_data_source.dart`

Purpose:

- Defines and implements low-level Firebase Auth and Firestore operations.

Important abstraction:

```dart
abstract class AuthRemoteDataSource
```

Methods:

- `authStateChanges()`
- `signIn(...)`
- `signUp(...)`
- `sendPasswordResetEmail(...)`
- `sendEmailVerification()`
- `reloadCurrentUser()`
- `signOut()`
- `changeEmail(...)`

Important implementation:

```dart
class FirebaseAuthRemoteDataSource implements AuthRemoteDataSource
```

Constructor dependencies:

- `FirebaseAuth firebaseAuth`
- `FirebaseFirestore firestore`

These dependencies are injected through Riverpod providers.

#### `authStateChanges`

```dart
Stream<AppUserModel?> authStateChanges()
```

Responsibilities:

- Listens to `FirebaseAuth.userChanges()`.
- Converts Firebase users into `AppUserModel`.
- Emits `null` when signed out.
- Emits user updates when Firebase user data changes, including email verification refreshes.

#### `signIn`

```dart
Future<AppUserModel> signIn({
  required String email,
  required String password,
})
```

Responsibilities:

- Calls `signInWithEmailAndPassword`.
- Trims email.
- Throws a Firebase auth exception if no user is returned.
- Returns `AppUserModel`.

#### `signUp`

```dart
Future<AppUserModel> signUp({
  required String email,
  required String password,
  required String displayName,
})
```

Responsibilities:

- Calls `createUserWithEmailAndPassword`.
- Updates Firebase Auth display name.
- Sends the first Firebase email verification message through `user.sendEmailVerification()`.
- Creates a Firestore user document in the `users` collection.
- Stores:
  - `uid`
  - `email`
  - `emailVerified`
  - `displayName`
  - `createdAt`
  - `updatedAt`
- Reloads the Firebase user.
- Returns `AppUserModel`.

Firestore path used:

```text
users/{uid}
```

#### `sendPasswordResetEmail`

```dart
Future<void> sendPasswordResetEmail(String email)
```

Responsibilities:

- Calls Firebase Auth `sendPasswordResetEmail`.

#### `sendEmailVerification`

```dart
Future<void> sendEmailVerification()
```

Responsibilities:

- Gets the current Firebase user.
- Throws if no user is signed in.
- Returns early if the email is already verified.
- Calls Firebase Auth `user.sendEmailVerification()`.

#### `reloadCurrentUser`

```dart
Future<AppUserModel?> reloadCurrentUser()
```

Responsibilities:

- Gets the current Firebase user.
- Calls `user.reload()` to refresh Firebase Auth account data.
- Reads the reloaded `FirebaseAuth.currentUser`.
- Updates Firestore `users/{uid}` with:
  - latest `email`
  - latest `emailVerified`
  - `updatedAt`
- Returns the refreshed `AppUserModel`.
- Returns `null` if no user is signed in.

#### `signOut`

```dart
Future<void> signOut()
```

Responsibilities:

- Calls Firebase Auth `signOut`.

#### `changeEmail`

```dart
Future<void> changeEmail(String newEmail)
```

Responsibilities:

- Gets the current Firebase user.
- Throws if no user is signed in.
- Calls `verifyBeforeUpdateEmail(newEmail)`.
- Writes `pendingEmail` and `updatedAt` to Firestore user document.

Why `verifyBeforeUpdateEmail` was used:

- Firebase requires email ownership verification before changing sensitive account data.
- This is safer than directly changing the email.

### `lib/features/auth/data/repositories/auth_repository_impl.dart`

Purpose:

- Implements the domain `AuthRepository`.
- Converts Firebase/data exceptions into domain-level `Failure` objects.

Important class:

```dart
class AuthRepositoryImpl implements AuthRepository
```

Constructor dependency:

```dart
AuthRepositoryImpl(this.remoteDataSource)
```

The repository depends on the `AuthRemoteDataSource` abstraction.

Implemented methods:

- `authStateChanges`
- `signIn`
- `signUp`
- `sendPasswordResetEmail`
- `sendEmailVerification`
- `reloadCurrentUser`
- `signOut`
- `changeEmail`

Important private method:

```dart
Future<Either<Failure, T>> _guard<T>(Future<T> Function() action)
```

Responsibilities:

- Runs a Firebase/data action.
- Returns `Right(value)` on success.
- Catches `FirebaseAuthException`.
- Catches generic `FirebaseException`.
- Catches unexpected exceptions.
- Returns `Left(Failure(message))` on failure.

Important private method:

```dart
String _friendlyAuthMessage(FirebaseAuthException error)
```

Responsibilities:

- Converts Firebase error codes into user-friendly messages.

Handled error codes include:

- `invalid-email`
- `user-disabled`
- `user-not-found`
- `wrong-password`
- `invalid-credential`
- `email-already-in-use`
- `weak-password`
- `requires-recent-login`
- `too-many-requests`

## Auth Presentation Layer

The presentation layer contains Riverpod providers, UI pages, and reusable UI widgets.

### `lib/features/auth/presentation/providers/auth_providers.dart`

Purpose:

- Central dependency injection setup for the Auth feature.
- Exposes Firebase services, data sources, repositories, use cases, auth state, and controller state.

Providers:

```dart
final firebaseAuthProvider = Provider<FirebaseAuth>
```

- Provides `FirebaseAuth.instance`.

```dart
final firestoreProvider = Provider<FirebaseFirestore>
```

- Provides `FirebaseFirestore.instance`.

```dart
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>
```

- Creates `FirebaseAuthRemoteDataSource`.
- Injects Firebase Auth and Firestore.

```dart
final authRepositoryProvider = Provider<AuthRepository>
```

- Creates `AuthRepositoryImpl`.
- Injects `AuthRemoteDataSource`.

```dart
final authStateProvider = StreamProvider<AppUser?>
```

- Watches `AuthRepository.authStateChanges`.
- Drives the auth gate.

Use case providers:

- `signInProvider`
- `signUpProvider`
- `sendPasswordResetEmailProvider`
- `sendEmailVerificationProvider`
- `reloadCurrentUserProvider`
- `signOutProvider`
- `changeEmailProvider`

Controller provider:

```dart
final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>
```

- Provides loading/error/success state for auth actions.

Important class:

```dart
class AuthController extends StateNotifier<AsyncValue<void>>
```

Purpose:

- Coordinates UI actions with domain use cases.
- Keeps widgets thin.

Methods:

```dart
Future<String?> signIn({
  required String email,
  required String password,
})
```

- Calls `SignIn`.
- Returns `null` on success.
- Returns error message on failure.

```dart
Future<String?> signUp({
  required String email,
  required String password,
  required String displayName,
})
```

- Calls `SignUp`.
- Returns `null` on success.
- Returns error message on failure.

```dart
Future<String?> sendPasswordResetEmail(String email)
```

- Calls `SendPasswordResetEmail`.

```dart
Future<String?> sendEmailVerification()
```

- Calls `SendEmailVerification`.
- Used by the email confirmation screen to resend the verification email.

```dart
Future<String?> reloadCurrentUser()
```

- Calls `ReloadCurrentUser`.
- Used by the email confirmation screen after the user opens the verification link.

```dart
Future<String?> signOut()
```

- Calls `SignOut`.

```dart
Future<String?> changeEmail(String newEmail)
```

- Calls `ChangeEmail`.

Private helper:

```dart
Future<String?> _run<T>(Future<dynamic> Function() action)
```

Responsibilities:

- Sets state to `AsyncLoading`.
- Executes a use case.
- Folds the returned `Either`.
- Sets `AsyncError` and returns message on failure.
- Sets `AsyncData(null)` and returns `null` on success.

### `lib/features/auth/presentation/pages/auth_gate.dart`

Purpose:

- Decides whether the user sees the auth page, email verification page, or landing page.

Important class:

```dart
class AuthGate extends ConsumerWidget
```

Responsibilities:

- Watches `authStateProvider`.
- Shows `AuthPage` when user is `null`.
- Shows `EmailVerificationPage` when user exists but `isEmailVerified` is `false`.
- Shows `LandingPage` only when user exists and `isEmailVerified` is `true`.
- Shows a loading spinner while auth state is resolving.

### `lib/features/auth/presentation/pages/auth_page.dart`

Purpose:

- Provides the sign-in, sign-up, and forgot-password UI.
- Provides an auth-page language switcher before the user signs in.

Important enum:

```dart
enum AuthMode { signIn, signUp }
```

Purpose:

- Tracks whether the form is in sign-in or sign-up mode.

Important class:

```dart
class AuthPage extends ConsumerStatefulWidget
```

State fields:

- `_formKey`
- `_nameController`
- `_emailController`
- `_passwordController`
- `_mode`

Important methods:

```dart
Future<void> _submit()
```

Responsibilities:

- Validates the form.
- Calls `authController.signIn` or `authController.signUp`.
- Sign-up now sends a Firebase email verification message before the user can access the landing page.
- Shows a snack bar if an error occurs.

```dart
Future<void> _forgotPassword()
```

Responsibilities:

- Validates that an email exists.
- Calls `sendPasswordResetEmail`.
- Shows success or error feedback.

Private helper:

```dart
bool _isValidEmail(String value)
```

Purpose:

- Performs simple email format validation.

Important internal widget:

```dart
class _BrandHeader extends StatelessWidget
```

Purpose:

- Shows the AI4Good visual identity and short supporting copy at the top of the auth page.

UI choices:

- Material 3 segmented button for switching between sign in and sign up.
- Segmented button switches from horizontal to vertical on very narrow form widths to avoid localized-label overflow.
- Rounded input fields.
- Full-width primary action button.
- Localized labels, validation messages, tooltips, and success messages through `context.l10n`.
- Language menu in the top-right corner.
- Responsive horizontal/vertical padding from `AppResponsive`.
- Responsive max width for larger screens so the form remains readable on desktop monitors.
- Animated form size when switching modes.

### `lib/features/auth/presentation/pages/email_verification_page.dart`

Purpose:

- Holds newly registered or signed-in but unverified users outside the main landing area.
- Tells the user where the verification email was sent.
- Lets the user resend the verification email.
- Lets the user manually refresh account state after opening the verification link.
- Lets the user sign out and use another account.

Important class:

```dart
class EmailVerificationPage extends ConsumerWidget
```

Constructor input:

- `AppUser user`: the currently signed-in but unverified user.

Important methods:

```dart
Future<void> _checkVerification(BuildContext context, WidgetRef ref)
```

Responsibilities:

- Calls `authController.reloadCurrentUser()`.
- Shows an error snack bar if refresh fails.
- Shows a success message if the refreshed auth state is verified.
- Shows a reminder message if the account is still not verified.
- Once Firebase reports `emailVerified == true`, `AuthGate` allows access to `LandingPage`.

```dart
Future<void> _resendVerification(BuildContext context, WidgetRef ref)
```

Responsibilities:

- Calls `authController.sendEmailVerification()`.
- Shows success feedback when Firebase sends the email.
- Shows an error snack bar if Firebase rejects the resend request.

```dart
Future<void> _signOut(BuildContext context, WidgetRef ref)
```

Responsibilities:

- Calls `authController.signOut()`.
- Lets the user leave the verification state and return to `AuthPage`.

UI choices:

- Centered confirmation layout with max width.
- Email icon in a circular container.
- Localized text and feedback messages through `context.l10n`.
- Primary button for the email verification refresh action.
- Secondary outlined button for resending verification.
- Text button for using another account.
- Long localized button labels can wrap to avoid phone-width overflow.
- Responsive padding and max width from `AppResponsive`.

### `lib/features/auth/presentation/widgets/auth_text_field.dart`

Purpose:

- Reusable styled text field for auth forms.

Important class:

```dart
class AuthTextField extends StatelessWidget
```

Inputs:

- `controller`
- `label`
- `icon`
- `keyboardType`
- `obscureText`
- `textInputAction`
- `validator`

### `lib/features/auth/presentation/widgets/primary_button.dart`

Purpose:

- Reusable full-width primary button with optional icon and loading spinner.

Important class:

```dart
class PrimaryButton extends StatelessWidget
```

Inputs:

- `label`
- `onPressed`
- `isLoading`
- `icon`

Behavior:

- Disables itself while loading.
- Shows a `CircularProgressIndicator` while loading.
- Shows icon and label when not loading.
- Allows translated labels to wrap up to two lines with ellipsis protection.

### `lib/features/auth/presentation/widgets/app_snack_bar.dart`

Purpose:

- Central helper for consistent snack bar feedback.

Important function:

```dart
void showAppSnackBar(
  BuildContext context, {
  required String message,
  bool isError = false,
})
```

Behavior:

- Hides current snack bar.
- Shows a floating snack bar.
- Uses error color for failures.
- Uses green success color for successful operations.
- Caps snackbar width on larger screens and limits message text to four lines.

## Landing Feature

The landing feature currently only has a presentation layer. There is no domain or data layer yet because the current landing page content is static/demo UI.

## Landing Presentation Layer

### `lib/features/landing/presentation/pages/landing_page.dart`

Purpose:

- Main authenticated shell after login.
- Provides bottom navigation on mobile and tablet layouts.
- Provides a navigation rail on desktop-width layouts.
- Keeps Home and Profile tab states alive with `IndexedStack`.

Important class:

```dart
class LandingPage extends StatefulWidget
```

State:

- `_selectedIndex`

UI:

- `NavigationBar` with:
  - Home
  - Profile
- `NavigationRail` with the same destinations when `AppResponsive.useNavigationRail` is true.
- Localized navigation labels through `context.l10n`.

Important behavior:

```dart
onDestinationSelected: (index) {
  setState(() => _selectedIndex = index);
}
```

- Switches visible tab.

### `lib/features/landing/presentation/widgets/home_view.dart`

Purpose:

- Home tab UI after login.
- Presents AI4Good brand and starter dashboard metrics.

Important class:

```dart
class HomeView extends StatelessWidget
```

UI sections:

- Header with AI4Good icon and title.
- Contemporary dark feature panel.
- Localized hero copy and metric labels.
- Content constrained to the shared desktop max width.
- Responsive metric grid that uses shared column and aspect-ratio rules from `AppResponsive`.

Important internal widget:

```dart
class _HomeMetric extends StatelessWidget
```

Purpose:

- Reusable metric card for dashboard-style stats.

Inputs:

- `icon`
- `label`
- `value`

Current static metrics:

- Ideas
- Collaborators
- Milestones
- Communities

Responsive behavior:

- Mobile widths use two metric columns with a compact aspect ratio.
- Tablet and desktop widths use four metric columns.
- Large monitor content is centered and capped by `AppResponsive.contentMaxWidth`.

### `lib/features/landing/presentation/widgets/profile_view.dart`

Purpose:

- Profile tab UI.
- Shows current authenticated user.
- Provides language switching after login.
- Provides log out and change email actions.
- Localizes profile copy, dialog labels, validation messages, and success messages.
- Constrains content width on desktop monitors.
- Caps profile action titles/subtitles to controlled line counts so English and French labels do not overflow on narrow screens.

Important class:

```dart
class ProfileView extends ConsumerWidget
```

Dependencies:

- Watches `authStateProvider` to display current user.
- Watches `authControllerProvider` for loading state.
- Calls `AuthController` methods for profile actions.

Important methods:

```dart
Future<void> _signOut(BuildContext context, WidgetRef ref)
```

Responsibilities:

- Calls `authController.signOut`.
- Shows error snack bar if log out fails.

```dart
Future<void> _changeEmail(BuildContext context, WidgetRef ref)
```

Responsibilities:

- Opens `_ChangeEmailDialog`.
- Calls `authController.changeEmail`.
- Shows success or error snack bar.

Important internal widget:

```dart
class _LanguageProfileAction extends StatelessWidget
```

Purpose:

- Presents language switching as a normal profile action row.
- Uses `LanguageMenuButton` as the popup trigger.
- Shows the current language in the row subtitle.
- Updates `languageControllerProvider`, which immediately refreshes `context.l10n` strings across the profile, auth, and data-review screens.

Important internal widget:

```dart
class _ProfileAction extends StatelessWidget
```

Purpose:

- Reusable list tile for profile actions.
- Used by the change-email and log-out rows so profile actions share shape, icon placement, and localized title/subtitle behavior.

Inputs:

- `icon`
- `title`
- `subtitle`
- `onTap`
- `isDestructive`

Important internal widget:

```dart
class _ChangeEmailDialog extends StatefulWidget
```

Purpose:

- Dialog that asks the user for a new email address.

Behavior:

- Validates email format.
- Uses `context.l10n` for the title, new-email label, cancel action, send-link action, validation message, and verification-email success message.
- Submits the new address through `AuthController.changeEmail`, which starts Firebase's verified email-change flow.
- Returns the new email through `Navigator.pop`.
- Cancels without changes when dismissed.

## Authentication Flow

### Startup Flow

```text
main()
  -> Firebase.initializeApp()
  -> ProviderScope
  -> AI4GoodApp
  -> AuthGate
  -> authStateProvider
```

If no user is signed in:

```text
AuthGate -> AuthPage
```

If a user is signed in:

```text
AuthGate -> EmailVerificationPage when email is not verified
AuthGate -> LandingPage when email is verified
```

### Sign In Flow

```text
AuthPage._submit()
  -> AuthController.signIn()
  -> SignIn use case
  -> AuthRepository.signIn()
  -> AuthRepositoryImpl.signIn()
  -> FirebaseAuthRemoteDataSource.signIn()
  -> FirebaseAuth.signInWithEmailAndPassword()
```

Success:

- Firebase auth state changes.
- `authStateProvider` emits an `AppUser`.
- `AuthGate` shows `EmailVerificationPage` if `isEmailVerified` is `false`.
- `AuthGate` shows `LandingPage` if `isEmailVerified` is `true`.

Failure:

- Firebase exception is converted into `Failure`.
- `AuthController` returns an error message.
- `AuthPage` displays a snack bar.

### Sign Up Flow

```text
AuthPage._submit()
  -> AuthController.signUp()
  -> SignUp use case
  -> AuthRepository.signUp()
  -> AuthRepositoryImpl.signUp()
  -> FirebaseAuthRemoteDataSource.signUp()
  -> FirebaseAuth.createUserWithEmailAndPassword()
  -> user.updateDisplayName()
  -> user.sendEmailVerification()
  -> Firestore users/{uid}.set(...)
```

Success:

- Firebase auth state changes.
- Firestore profile document is created.
- Firebase sends an email verification link to the new account email.
- `AuthGate` shows `EmailVerificationPage` until the user verifies the email.

### Email Verification Flow

```text
EmailVerificationPage._checkVerification()
  -> AuthController.reloadCurrentUser()
  -> ReloadCurrentUser use case
  -> AuthRepository.reloadCurrentUser()
  -> FirebaseAuthRemoteDataSource.reloadCurrentUser()
  -> FirebaseAuth.currentUser.reload()
  -> Firestore users/{uid}.set({ email, emailVerified, updatedAt }, merge: true)
```

Success when verified:

- Firebase Auth reports `emailVerified == true`.
- Firestore profile document stores `emailVerified: true`.
- `authStateProvider` emits the refreshed `AppUser`.
- `AuthGate` shows `LandingPage`.

Success when still unverified:

- The user remains on `EmailVerificationPage`.
- A snack bar asks the user to check their inbox.

### Resend Email Verification Flow

```text
EmailVerificationPage._resendVerification()
  -> AuthController.sendEmailVerification()
  -> SendEmailVerification use case
  -> AuthRepository.sendEmailVerification()
  -> FirebaseAuthRemoteDataSource.sendEmailVerification()
  -> FirebaseAuth.currentUser.sendEmailVerification()
```

Success:

- Firebase sends another verification email to the signed-in user's email address.

### Forgot Password Flow

```text
AuthPage._forgotPassword()
  -> AuthController.sendPasswordResetEmail()
  -> SendPasswordResetEmail use case
  -> AuthRepository.sendPasswordResetEmail()
  -> FirebaseAuthRemoteDataSource.sendPasswordResetEmail()
  -> FirebaseAuth.sendPasswordResetEmail()
```

Success:

- Snack bar confirms password reset email was sent.

### Sign Out Flow

```text
ProfileView._signOut()
  -> AuthController.signOut()
  -> SignOut use case
  -> AuthRepository.signOut()
  -> FirebaseAuthRemoteDataSource.signOut()
  -> FirebaseAuth.signOut()
```

Success:

- Firebase auth state emits `null`.
- `AuthGate` returns to `AuthPage`.

### Change Email Flow

```text
ProfileView._changeEmail()
  -> _ChangeEmailDialog
  -> AuthController.changeEmail()
  -> ChangeEmail use case
  -> AuthRepository.changeEmail()
  -> FirebaseAuthRemoteDataSource.changeEmail()
  -> FirebaseAuth.currentUser.verifyBeforeUpdateEmail()
  -> Firestore users/{uid}.set({ pendingEmail, updatedAt }, merge: true)
```

Success:

- Firebase sends verification email to the new email address.
- Firestore stores the pending email for tracking.
- Snack bar tells the user to check the verification email.

## Error Handling Strategy

The app uses `Either<Failure, T>` for repository and use case results.

Success example:

```dart
Right(AppUser(...))
```

Failure example:

```dart
Left(Failure('The email or password is incorrect.'))
```

Benefits:

- UI does not need to catch Firebase exceptions.
- Errors are explicit in return types.
- Use cases can be tested without Firebase.
- Repositories are responsible for translating low-level errors into app-level failures.

## Dependency Injection Strategy

Riverpod providers are used for dependency injection.

Dependency graph:

```text
FirebaseAuth.instance
FirebaseFirestore.instance
        ↓
FirebaseAuthRemoteDataSource
        ↓
AuthRepositoryImpl
        ↓
Use Cases
        ↓
AuthController
        ↓
UI Widgets
```

Benefits:

- Dependencies can be overridden in tests.
- UI does not instantiate Firebase classes directly.
- The app can swap Firebase implementation later by providing a different repository/data source.

## Firestore Data Model

Collection:

```text
users
```

Document ID:

```text
Firebase Auth uid
```

Fields created on sign up:

| Field | Type | Purpose |
| --- | --- | --- |
| `uid` | string | Firebase Auth user ID. |
| `email` | string | User email at account creation. |
| `emailVerified` | boolean | Whether Firebase Auth has verified the user's email. Initially `false` for new sign-ups. |
| `displayName` | string | User profile display name. |
| `createdAt` | server timestamp | Account profile creation time. |
| `updatedAt` | server timestamp | Last profile update time. |

Fields updated during email verification refresh:

| Field | Type | Purpose |
| --- | --- | --- |
| `email` | string | Latest email from Firebase Auth. |
| `emailVerified` | boolean | Latest verification state from Firebase Auth. |
| `updatedAt` | server timestamp | Time of the verification-state refresh. |

Fields written during email change:

| Field | Type | Purpose |
| --- | --- | --- |
| `pendingEmail` | string | New email waiting for Firebase verification. |
| `updatedAt` | server timestamp | Time of requested email update. |

## UI And Design Choices

The UI uses a contemporary Material 3 interface with shared primitives from `core/presentation/app_ui.dart`.

Design choices:

- Material 3 enabled through `useMaterial3: true`.
- Seed color: `Color(0xFF0F8B8D)`, with additional blue, warning, success, danger, and neutral tokens in `AppColors`.
- Soft app background: `Color(0xFFF4F7F6)`.
- Compact 6-8 logical pixel radii for cards, dialogs, inputs, and buttons.
- Filled primary buttons.
- Segmented control for sign in/sign up mode.
- Dedicated email confirmation page for unverified users.
- Bottom `NavigationBar` for authenticated landing navigation.
- Profile cards, workflow rows, and action rows with clear icons.
- Responsive auth form width for wider screens.
- Auth, language selection, email verification, data review, profile, dialogs, loading overlays, empty states, and error states share `AppSurface`, `AppIconTile`, and `AppErrorView`.
- Shared loading overlays constrain their width and wrap long status text so job-status labels remain readable on small screens.
- `IndexedStack` used to preserve tab state in the landing page.

## AI Data Review + Analysis Feature

The `data_review` feature connects authenticated users to the FastAPI backend described in `API_REFERENCE.md`.

Important ownership rule:

Flutter is UI and orchestration only. The backend owns file storage, parsing, validation rules, accepted/rejected preprocessing decisions, processed Excel generation, anonymization, and Bedrock-backed AI analysis. Flutter does not edit Excel files locally, call AWS, call Bedrock, or write dataset issue state to Firestore.

### API Configuration And Client

`lib/core/config/api_config.dart`

- Stores the production ALB base URL.
- Supports `--dart-define=API_BASE_URL=...` for local development.
- Keeps endpoint URLs out of widgets.

`lib/core/network/api_client.dart`

- Wraps `http.Client`.
- Fetches `FirebaseAuth.instance.currentUser?.getIdToken()` immediately before each `/v1/*` request.
- Sends `Authorization: Bearer <firebase_id_token>`.
- Sends `Accept-Language` using the active app language.
- Supports JSON GET/POST/DELETE, multipart upload, and authenticated binary download.
- Parses backend error envelopes into `ApiException`.
- Converts lower-level `http.ClientException` failures, such as browser CORS blocks or unreachable hosts, into a clearer `NETWORK_ERROR` `ApiException`.

### Data And Domain Layers

`DataReviewRepository` defines the feature contract used by controllers.

`DataReviewRemoteDataSourceImpl` maps typed operations to backend endpoints:

- `POST /v1/datasets/upload`
- `GET /v1/datasets/{dataset_id}/preview`
- `POST /v1/datasets/{dataset_id}/review/run`
- review-session issue group, issue decision, decline-all, undo, and finalize endpoints
- `GET /v1/my-data` and delete endpoints
- analysis eligible-dataset, job, job-status, report, and report-PDF endpoints

Models in `analysis_models.dart`, `dataset_models.dart`, and `review_models.dart` convert backend JSON into typed Dart objects used by controllers and widgets.

### Data Review Localization

`lib/features/data_review/presentation/data_review_strings.dart`

- Provides feature-specific English/French copy for upload, preview, review, My data, dataset selection, analysis instructions, and analysis report screens.
- Reads the active language from `context.l10n.languageCode` so it stays aligned with the global language preference controlled by `LanguageController`.
- Keeps backend API language behavior aligned with UI language because upload/review/analysis calls pass the same language code into controllers and `ApiClient` sends `Accept-Language`.
- French copy uses proper accents and phrasing for visible data-review labels, confirmation prompts, status messages, and action buttons.
- English copy uses sentence-style labels such as "Data upload", "Go back", "Next step", and "AI analysis report" for consistency with the rest of the Material UI.

### Presentation Flow

The authenticated Home tab renders `MainMenuPage` as a compact dashboard. The header workflow icon button and hero `Open menu` button were removed, so navigation now happens through the three pressable dashboard tiles:

- Data upload pushes `DataUploadPage`.
- My data pushes `MyDataPage`.
- AI data analysis pushes `DataSelectPage`.

`DataUploadPage`

- Uses `file_picker` with allowed extensions `.xlsx`, `.xls`, `.xlsm`, and `.csv`.
- Uploads selected bytes directly to the backend.
- Navigates to `DataPreviewPage` with the returned dataset ID, review session ID, sheets, and preview.
- Reduces prompt padding and upload icon size on narrow panels so the upload card fits phone screens cleanly.

`DataPreviewPage`

- Renders backend preview rows and columns through `DatasetTable`.
- Uses horizontal and vertical scrolling for wide spreadsheets.
- Uses the backend `page`, `page_size`, and `total_rows` values to show page controls when a spreadsheet does not fit on one page.
- Lets users switch between returned Excel sheets without leaving preview mode.
- Wraps cell text instead of truncating it so values remain explorable in view mode.
- Highlights cells using backend `cell_status`.
- Runs backend validation rules when the user presses **AI review**.
- Opens `IssueReviewDialog` when issues are returned.
- Shows a success dialog when no pending issues remain.
- Calls finalize on close and opens the processed Excel presigned URL.
- Shows the AI review action as a full-width button on phone layouts and as a trailing action on wider layouts.

`IssueReviewDialog`

- Shows grouped issues and counters.
- Lazy-loads group issues from the review-session issue endpoint.
- Supports individual accept/reject.
- Supports group accept-all/reject-all.
- Supports rejecting all pending issues across all groups.
- Uses bottom-sheet presentation on phone/tablet and centered dialogs on desktop.
- Keeps accept/reject actions inside responsive rows instead of fixed trailing controls that can overflow.
- Uses the sheet/dialog context for responsive sizing so tablet sheets and phone sheets measure the correct viewport.
- Stacks the header and issue counters on smaller widths, wraps footer actions, and truncates long group labels/pills safely.

`MyDataPage`

- Lists datasets returned by `/v1/my-data`.
- Uses a desktop table on wider panels and compact dataset cards when the actual available panel width is tight.
- Opens previews for existing datasets.
- Soft-deletes one dataset or all datasets with confirmation.
- Opens processed download URLs when available.
- Shows the delete-all action full-width in compact card layouts.

`DataSelectPage`, `AnalysisInstructionPage`, and `AnalysisReportPage`

- List finalized datasets eligible for analysis.
- Use desktop tables on wider panels and compact selectable cards when the actual available panel width is tight.
- Collect natural-language analysis instructions.
- Create an async analysis job and poll job status until completion or failure.
- Fetch and render `report_markdown`.
- Copy report text to the clipboard.
- Download authenticated PDF bytes and save them with `file_saver`.
- Keep dataset filenames to controlled line counts in card layouts so long filenames do not break phone layouts.
- Keep the next-step action full-width in compact selection layouts.
- Make the analysis-instruction panel scrollable with reduced compact padding and smaller text-field row counts on small screens.
- Reduce report padding on phone layouts so the Markdown report area has more usable reading space.

`AppPageShell`, `LoadingOverlay`, and confirmation dialogs

- `AppPageShell` lets compact page titles wrap to three lines and moves any trailing header action below the title on very narrow screens.
- `LoadingOverlay` constrains overlay width and wraps long status labels to avoid horizontal overflow.
- `showAdaptiveConfirmationDialog` uses modal bottom sheets on phones and centered dialogs on larger screens, with compact padding and correct keyboard inset handling.

### Platform HTTP Setup

The backend production ALB currently uses HTTP. The app includes project-scoped platform settings for testing:

- Android adds `INTERNET` permission and `android/app/src/main/res/xml/network_security_config.xml` with cleartext allowed only for the backend host, `localhost`, and Android emulator host `10.0.2.2`.
- iOS adds an ATS exception only for the backend ALB host.
- Flutter web is subject to browser CORS rules. The current backend allows local browser origins `http://localhost:3000` and `http://localhost:8080`; use `flutter run -d chrome --web-hostname localhost --web-port 3000` or the same command with port `8080` when testing uploads locally.

## Tests Added

### `test/app_user_test.dart`

Purpose:

- Verifies that `AppUser` uses value equality through `Equatable`.

Test:

```dart
test('AppUser uses value equality', () {
  ...
  expect(first, second);
});
```

Why it matters:

- Domain entities should compare by value, not by object identity.
- This helps testing and state comparisons.

## Verification Performed

The following commands were run successfully:

```bash
flutter pub get
dart format lib test
flutter analyze
flutter test
```

Results:

- Dependencies resolved successfully.
- Code formatted successfully.
- Analyzer found no issues.
- Tests passed.

## Important Notes

- `firebase_options.dart` already existed in the project and was reused.
- The app assumes Firebase Auth email/password provider is enabled in the Firebase console.
- The app assumes Firebase Auth email verification emails are enabled and correctly configured in the Firebase console.
- Firestore rules must allow the signed-in user to create and update their own `users/{uid}` document.
- Sign-up now sends a verification email immediately and does not allow access to the landing page until Firebase reports `emailVerified == true`.
- Change email uses Firebase `verifyBeforeUpdateEmail`, so the user must confirm the new email address before Firebase Auth updates it.
- The authenticated Home tab now serves as the AI Data Review + Analysis main menu.

## Suggested Future Improvements

- Add route management with `go_router` when the app grows beyond auth and landing.
- Add repository unit tests with fake data sources.
- Add widget tests with provider overrides.
- Add Firestore security rules for user-owned profile documents.
- Add re-authentication flow before changing email for users whose session is old.
- Add profile editing beyond email, such as display name and avatar.
- Add loading overlays or disabled states for profile actions during long Firebase operations.
