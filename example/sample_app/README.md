# Sample app (generated-output demo)

This folder is a **complete Clean Architecture snapshot** of what
`flutter_architect init` produces (with BLoC, GetIt, REST, flavors, l10n, and an `auth` feature).

It is meant for browsing on pub.dev / GitHub — not as a standalone publishable app.
Platform folders (`android/`, `ios/`, …) are omitted on purpose to keep the package small.

## Reproduce this yourself

```bash
flutter create my_app && cd my_app
dart pub global activate flutter_architect
flutter_architect init
# choose: Clean · BLoC · GoRouter · REST · GetIt · l10n · flavors · Auth
flutter pub add dartz equatable get_it dio flutter_bloc go_router
flutter pub get
flutter run -t lib/main_development.dart
```

## Layout

```text
lib/
├── main.dart / main_*.dart
├── app/          # App widget, config, DI, router, themes
├── core/         # network, errors, usecase, logger, …
├── features/
│   └── auth/     # data · domain · presentation · di
├── l10n/         # arb files
└── shared/
```

Open the Dart files under `lib/` to see the wired boilerplate
(Page → BLoC → UseCase → Repository → DataSource).
