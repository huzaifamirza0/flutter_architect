# flutter_architect

[![pub package](https://img.shields.io/pub/v/flutter_architect.svg)](https://pub.dev/packages/flutter_architect)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

**Build production-ready Flutter applications in minutes.**

`flutter_architect` is a CLI that scaffolds Clean Architecture or MVVM Flutter projects — with themes, DI, networking, localization, flavors, CI/CD templates, and day-to-day generators for features, screens, widgets, and more.

> Works **inside** an existing Flutter project. Create the app with `flutter create`, then run `flutter_architect init`.

---

## Installation

```bash
dart pub global activate flutter_architect
```

Ensure your PATH includes the pub cache bin directory so `flutter_architect` is available globally.

---

## Quick start

```bash
flutter create my_awesome_app
cd my_awesome_app

flutter_architect init
```

The interactive wizard asks for:

| Prompt | Options |
|--------|---------|
| Architecture | Clean Architecture · MVVM |
| State management | BLoC · Riverpod · Provider · GetX · None |
| Routing | GoRouter · AutoRoute · Navigator 2.0 · Vanilla |
| Networking | REST (Dio) · GraphQL · Both · None |
| DI | GetIt |
| Localization | Yes / No + locales (e.g. `en, ar`) |
| Flavors + env | Yes / No (dev · staging · prod) |
| CI/CD | GitHub Actions · Codemagic · Both · None |
| Auth / sample feature | Optional modules |

Then install the printed dependencies:

```bash
flutter pub add ...   # exact command printed by the CLI
flutter pub get
```

If localization was enabled:

```bash
flutter gen-l10n
# or simply: flutter run
```

---

## Commands

### `init`

Scaffolds `lib/` with app/core/features/shared, boilerplate files, and optional auth/sample features.

```bash
flutter_architect init
flutter_architect init --dry-run          # preview only
```

Writes `architect.yaml` so later `create` commands know your architecture and options.

---

### Feature & layer generators

```bash
# Full feature module
flutter_architect create feature booking
flutter_architect create feature booking --state-management bloc

# Clean Architecture layers
flutter_architect create model User --feature auth
flutter_architect create entity User --feature auth
flutter_architect create repository User --feature auth
flutter_architect create usecase Login --feature auth
flutter_architect create datasource User --feature auth --local

# MVVM
flutter_architect create viewmodel Profile --feature profile
```

---

### Micro-generators

You only pass a **name** and optional **`--feature`**. Paths are chosen from your architecture automatically.

```bash
# Screen / page (+ state stub by default)
flutter_architect create screen Settings --feature profile
flutter_architect create screen Settings --feature profile --no-with-state

# Widget (feature or shared)
flutter_architect create widget UserAvatar --feature profile
flutter_architect create widget AppButton

# Datasource (Clean only)
flutter_architect create datasource Order --feature checkout --local
```

| Command | Clean path | MVVM path |
|---------|------------|-----------|
| `screen` | `features/<f>/presentation/pages/` | `features/<f>/views/` |
| `widget --feature` | `.../presentation/widgets/` | `.../views/widgets/` |
| `widget` (no feature) | `shared/widgets/` | `shared/widgets/` |
| `datasource` | `features/<f>/data/datasources/` | — |

---

### `cicd`

Generate CI templates anytime (also available during `init`):

```bash
flutter_architect cicd
flutter_architect cicd -p github
flutter_architect cicd -p codemagic
flutter_architect cicd -p both
```

Creates:

- `.github/workflows/flutter_ci.yml`
- and/or `codemagic.yaml`

---

## What `init` generates

### App layer

```text
lib/app/
├── app.dart                 # MaterialApp (+ theme, l10n, router)
├── config/
│   ├── app_config.dart      # app name, Environment
│   └── env_config.dart      # API URLs per environment
├── di/
│   └── service_locator.dart # GetIt (+ feature registrations)
├── router/
│   └── app_router.dart
└── themes/
    ├── app_colors.dart
    ├── app_text_styles.dart
    └── app_theme.dart       # light + dark
```

### Core

```text
lib/core/
├── base/usecase.dart        # Clean only
├── network/                 # ApiClient, NetworkInfo, GraphQL client
├── errors/                  # Failures + Exceptions
├── constants/
├── logger/
├── widgets/
├── storage/
└── ...
```

### Localization (optional)

```text
l10n.yaml
lib/l10n/
├── app_en.arb
├── app_ar.arb               # + any locales you chose
└── ...
```

`app.dart` is wired with `AppLocalizations` delegates. `pubspec.yaml` is patched for `flutter_localizations`, `intl`, and `generate: true`.

### Flavors + env (optional)

```text
lib/main_development.dart
lib/main_staging.dart
lib/main_production.dart
lib/main.dart                # forwards to development
.env.development
.env.staging
.env.production
.vscode/launch.json
```

Run a flavor:

```bash
flutter run -t lib/main_development.dart
flutter run -t lib/main_staging.dart
flutter run -t lib/main_production.dart
```

Each entrypoint calls `AppConfig.bootstrap(Environment.*)` so `EnvConfig` returns the right API base URL.

---

## Folder structures

### Clean Architecture feature

```text
features/booking/
├── data/
│   ├── datasources/         # remote (+ local if Hive)
│   ├── models/              # toEntity() — does not extend Entity
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── presentation/
│   ├── bloc/ | providers/ | controllers/
│   ├── pages/
│   └── widgets/
├── di/                      # GetIt registration
└── routes/
```

Layers are wired: **Page → BLoC/Provider → UseCase → Repository → DataSource**, with proper `ServerException` / `CacheException` → `Failure` mapping.

### MVVM feature

```text
features/booking/
├── models/
├── services/
├── views/
│   └── widgets/
├── viewmodels/ | bloc/ | providers/ | controllers/
└── di/
```

State management choice is respected (ChangeNotifier, BLoC, Riverpod, or GetX).

---

## Architecture notes

- **Clean:** models use `toEntity()` / `fromEntity()` (composition, not inheritance).
- **MVVM:** does not generate UseCase / dartz; uses services + viewmodels.
- Commands that only apply to one architecture are rejected with a clear message (e.g. `entity` on MVVM).
- Feature GetIt modules are appended into `service_locator.dart` automatically.

---

## Example workflow

```bash
flutter create shop_app && cd shop_app
flutter_architect init

flutter pub add dartz equatable get_it dio flutter_bloc go_router
flutter pub get

flutter_architect create feature catalog --state-management bloc
flutter_architect create screen ProductDetail --feature catalog
flutter_architect create widget ProductCard --feature catalog

flutter run -t lib/main_development.dart
```

---

## Requirements

- Dart SDK `^3.6.2`
- An existing Flutter project (`pubspec.yaml` present)

---

## Examples

See the [`example/`](example/) folder:

- [`example/example.md`](example/example.md) — full CLI walkthrough (shown on pub.dev **Example** tab)
- [`example/main.dart`](example/main.dart) — `NameUtils` API demo
- [`example/sample_app/`](example/sample_app/) — **complete generated Clean Architecture sample** (app, core, auth feature, flavors, l10n)

---

## Contributing

Contributions are welcome — bug fixes, new generators/templates, docs, and examples.

1. Read **[CONTRIBUTING.md](CONTRIBUTING.md)**
2. Open an issue for bugs/features (templates available)
3. Fork, branch, and submit a PR

Please follow the [Code of Conduct](CODE_OF_CONDUCT.md).

## License

MIT © Huzaifa Mirza
