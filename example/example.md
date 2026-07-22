# flutter_architect — complete example / demo
#
# This Example tab follows:
# https://dart.dev/tools/pub/package-layout#examples

## 1. Quick CLI demo

```bash
dart pub global activate flutter_architect

flutter create my_app
cd my_app
flutter_architect init
```

Interactive prompts configure architecture, state management, routing,
networking, localization, flavors, and CI/CD.

Non-interactive smoke test:

```bash
flutter_architect init --no-interaction
```

---

## 2. Day-to-day generators

```bash
flutter_architect create feature booking
flutter_architect create screen Settings --feature booking
flutter_architect create widget ProductCard --feature booking
flutter_architect create widget AppButton
flutter_architect create model User --feature auth
flutter_architect create datasource User --feature auth --local
flutter_architect cicd -p both
```

Paths are chosen automatically from `architect.yaml` + `--feature`.

---

## 3. Full generated sample (`example/sample_app/`)

Browse a **complete Clean Architecture + BLoC** snapshot of `init` output:

| Path | What it shows |
|------|----------------|
| [`sample_app/README.md`](sample_app/README.md) | How to reproduce |
| `sample_app/lib/app/` | config, DI, router, themes |
| `sample_app/lib/core/` | UseCase, failures, Dio client |
| `sample_app/lib/features/auth/` | full feature: data → domain → presentation |
| `sample_app/lib/main_*.dart` | flavor entrypoints |
| `sample_app/lib/l10n/` | localization arb files |

Wiring demo inside auth:

```text
AuthPage
  → AuthBloc
    → GetAllAuthUseCase
      → AuthRepositoryImpl
        → AuthRemoteDataSourceImpl
```

Open [`sample_app/lib/features/auth/presentation/pages/auth_page.dart`](sample_app/lib/features/auth/presentation/pages/auth_page.dart)
and follow imports upward through the layers.

---

## 4. Public Dart API example

```bash
dart run example/main.dart
```

[`main.dart`](main.dart) uses `package:flutter_architect/flutter_architect.dart`
(`NameUtils`) — the same import style consumers use.

---

## 5. Typical post-init commands

```bash
flutter pub add dartz equatable get_it dio flutter_bloc go_router
flutter pub get
flutter run -t lib/main_development.dart
```

Full docs: [README.md](../README.md)
