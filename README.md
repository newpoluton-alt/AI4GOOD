# AI4Good

AI4Good is a Flutter application for Doctors for Madagascar workflows, including authentication, profile management, dataset upload, AI-assisted data review, issue approval/decline flows, saved dataset management, and analysis report generation.

## Tech Stack

### Application

- Flutter
- Dart SDK `^3.8.1`
- Material 3 UI
- Riverpod state management with `flutter_riverpod`
- Firebase initialization with `firebase_core`
- Firebase Authentication with `firebase_auth`
- Cloud Firestore with `cloud_firestore`
- REST API integration with `http`
- Local persistence with `shared_preferences`
- Internationalization/localization with `flutter_localizations` and `intl`
- SVG rendering with `flutter_svg`
- Markdown rendering with `flutter_markdown`
- File upload selection with `file_picker`
- File export/download support with `file_saver`
- External links/download URLs with `url_launcher`
- Functional error handling with `dartz`
- Value equality with `equatable`
- Cupertino icon assets with `cupertino_icons`

### Development And Quality

- Flutter test framework with `flutter_test`
- Recommended Flutter lint rules with `flutter_lints`
- Static analysis configured in `analysis_options.yaml`
- Firebase app configuration generated through FlutterFire in `firebase.json` and `lib/firebase_options.dart`
- Git ignore rules for Flutter, Dart, Android, iOS, macOS, Linux, Windows, and generated build artifacts

### Platforms

The repository includes generated Flutter platform projects for:

- Android
- iOS
- Web
- macOS
- Linux
- Windows

Firebase configuration is currently present for Android, iOS, macOS, web, and Windows.

## Architecture

The app follows a feature-first Clean Architecture style. Code is grouped by business feature under `lib/features`, with shared application infrastructure under `lib/core`.

```text
lib/
  app.dart
  main.dart
  firebase_options.dart
  core/
    config/
    errors/
    localization/
    network/
    presentation/
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

### Clean Architecture Terms Used

- `presentation`: Flutter pages, widgets, controllers, and Riverpod providers.
- `domain`: business-facing contracts, entities, and use cases.
- `data`: remote data sources, DTO/models, and repository implementations.
- `entities`: domain objects such as authenticated app users.
- `models`: API/Firebase data representations and JSON mapping types.
- `repositories`: abstractions in the domain layer and implementations in the data layer.
- `remote data sources`: Firebase and REST API integration classes.
- `use cases`: single-purpose domain actions, especially in the authentication feature.
- `providers`: Riverpod dependency injection and state exposure.
- `controllers`: `StateNotifier` classes that coordinate UI actions and async state.
- `failures`: user-facing error abstraction in `core/errors`.
- `Either`: functional success/failure return type from `dartz`.

## Feature Areas

### Authentication

Authentication is implemented with Firebase Authentication and Firestore-backed user metadata.

Supported flows include:

- Sign in
- Sign up
- Sign out
- Password reset email
- Email verification
- Reload current user
- Verify-before-update email change
- Auth state observation through Firebase user changes

Key files:

- `lib/features/auth/domain/repositories/auth_repository.dart`
- `lib/features/auth/data/datasources/auth_remote_data_source.dart`
- `lib/features/auth/data/repositories/auth_repository_impl.dart`
- `lib/features/auth/presentation/providers/auth_providers.dart`
- `lib/features/auth/presentation/pages/auth_gate.dart`
- `lib/features/auth/presentation/pages/auth_page.dart`

### Data Review

The data review module talks to a token-authenticated backend API and supports spreadsheet-oriented review workflows.

Supported flows include:

- Dataset upload through multipart requests
- Excel and CSV file selection
- Dataset preview with pagination
- Dataset save/delete
- Original and processed dataset download links
- "My Data" listing and bulk deletion
- Review run creation
- Issue group loading
- Individual issue accept/decline
- Group-level accept/decline
- Decline all pending issues
- Patch-set undo
- Review finalization
- Eligible dataset selection for analysis
- Analysis job creation and polling
- Analysis report retrieval
- PDF report download

Key files:

- `lib/features/data_review/domain/repositories/data_review_repository.dart`
- `lib/features/data_review/data/datasources/data_review_remote_data_source.dart`
- `lib/features/data_review/data/repositories/data_review_repository_impl.dart`
- `lib/features/data_review/presentation/providers/data_review_providers.dart`
- `lib/features/data_review/presentation/providers/data_upload_controller.dart`
- `lib/features/data_review/presentation/providers/analysis_controller.dart`

### Localization

The app supports English and French localization. Locale selection is stored locally with `shared_preferences`, applied to Flutter localization delegates, and propagated to backend requests through the `Accept-Language` header.

Key files:

- `lib/core/localization/app_localizations.dart`
- `lib/core/localization/language_controller.dart`
- `lib/core/localization/language_widgets.dart`

### UI System

Shared UI tokens and responsive helpers live in `lib/core/presentation`.

The app uses:

- Material 3 theming
- Shared color, radius, spacing, and typography constants
- Responsive layout helpers
- Reusable page shells, tables, dialogs, loading overlays, buttons, and form fields

## Backend Integration

The Flutter app integrates with the AI4GOOD backend that we developed in a separate repository:

- Frontend repository: [newpoluton-alt/AI4GOOD](https://github.com/newpoluton-alt/AI4GOOD)
- Backend repository: [newpoluton-alt/AI4GOOD_BACKEND](https://github.com/newpoluton-alt/AI4GOOD_BACKEND)

The default production backend is:

```text
https://d2x9le8skhxjh4.cloudfront.net
```

That endpoint is the production CloudFront URL in front of the FastAPI Application Load Balancer. The Flutter client sends Firebase ID tokens as bearer tokens:

```text
Authorization: Bearer <firebase_id_token>
```

The API client also sends:

- `Accept: application/json`
- `Accept-Language: <selected_language>`
- `Content-Type: application/json` for JSON requests

The backend URL is configured in `lib/core/config/api_config.dart` and can be overridden at build or run time with `API_BASE_URL`.

## Important Libraries

| Package | Purpose |
| --- | --- |
| `flutter_riverpod` | Dependency injection, providers, and `StateNotifier` async UI state |
| `firebase_core` | Firebase app initialization |
| `firebase_auth` | Email/password authentication and Firebase ID tokens |
| `cloud_firestore` | User profile and metadata persistence |
| `http` | REST API, JSON requests, downloads, and multipart upload |
| `dartz` | `Either<Failure, T>` functional error handling |
| `equatable` | Value equality for domain/data objects |
| `shared_preferences` | Persisting selected language |
| `intl` | Locale formatting and default locale configuration |
| `flutter_localizations` | Flutter localization delegates |
| `file_picker` | Selecting `.xlsx`, `.xls`, `.xlsm`, and `.csv` files |
| `file_saver` | Saving generated/downloaded files |
| `url_launcher` | Opening external download links |
| `flutter_markdown` | Rendering generated analysis/report content |
| `flutter_svg` | Rendering SVG branding assets |
| `cupertino_icons` | Cupertino icon font assets |

## Project Structure

```text
android/                 Android Flutter host project
ios/                     iOS Flutter host project
web/                     Flutter web project files and icons
macos/                   macOS Flutter host project
linux/                   Linux Flutter host project
windows/                 Windows Flutter host project
assets/branding/         Doctors for Madagascar SVG branding
lib/                     Dart application source
test/                    Flutter tests
pubspec.yaml             Package metadata, dependencies, and asset registration
firebase.json            FlutterFire app mapping
analysis_options.yaml    Dart analyzer and lint configuration
ARCHITECTURE.md          Extended architecture notes
```

## Local Setup

Install Flutter and fetch packages:

```bash
flutter pub get
```

Run tests:

```bash
flutter test
```

Run static analysis:

```bash
flutter analyze
```

Run on Chrome:

```bash
flutter run -d chrome --web-hostname localhost --web-port 3000
```

## Local Web Development

The production FastAPI backend allows browser requests from these local origins:

- `http://localhost:3000`
- `http://localhost:8080`
- `http://localhost:5000`

When running Flutter web against the production backend, use one of those ports:

```bash
flutter run -d chrome --web-hostname localhost --web-port 3000
```

or:

```bash
flutter run -d chrome --web-hostname localhost --web-port 8080
```

Using Flutter's random web port can make the browser block upload/API requests with a CORS-style `Failed to fetch` error unless that origin is added to the backend CORS allowlist.

For local backend development, override the API base URL:

```bash
flutter run -d chrome --web-hostname localhost --web-port 3000 --dart-define=API_BASE_URL=http://localhost:8000
```

For local HTTP testing against the ALB instead of CloudFront:

```bash
flutter run -d chrome --web-hostname localhost --web-port 3000 --dart-define=API_BASE_URL=http://ai-dat-LoadB-8liHDRYQDOe8-1492154657.us-west-2.elb.amazonaws.com
```

## Build Examples

Build the web app with the production backend:

```bash
flutter build web
```

Build the web app with a custom backend:

```bash
flutter build web --dart-define=API_BASE_URL=https://your-backend.example.com
```

## Notes

- This repository contains the Flutter client. The FastAPI backend lives in [newpoluton-alt/AI4GOOD_BACKEND](https://github.com/newpoluton-alt/AI4GOOD_BACKEND), with CloudFront and the ALB exposed as external services consumed by the app.
- Firebase client configuration files are included so the Flutter app can initialize Firebase on supported platforms.
- Generated build outputs such as `build/`, `.dart_tool/`, platform ephemeral folders, and CocoaPods dependencies are ignored.
