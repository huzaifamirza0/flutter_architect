## 2.0.2

- Added a complete demo under `example/sample_app/`: full Clean Architecture
  snapshot (app/core/features/auth, flavors, l10n, DI wiring) for browsing on
  pub.dev / GitHub.
- Expanded `example/example.md` into an end-to-end walkthrough.

## 2.0.1

- Added `example/` per [pub package layout](https://dart.dev/tools/pub/package-layout#examples)
  (`example/example.md` + `example/main.dart` with `package:` import).
- Documented `NameUtils` constructor for complete public API docs.

## 2.0.0

Production-oriented release: stronger architecture scaffolding plus localization, flavors, CI/CD, and micro-generators.

### Architecture improvements
- Clean Architecture folder rename to plural layers (`datasources`, `repositories`).
- Models use `toEntity()` / `fromEntity()` instead of extending entities.
- Repository error mapping for `ServerException`, `CacheException`, and network failures.
- Features generate wired UseCases, presentation layers, pages, and GetIt `di/` modules.
- Hive option generates local datasources with remote-first / local-fallback templates.
- MVVM gains a `services/` layer; state management choice is respected (BLoC / Riverpod / Provider / GetX).
- Clean-only core (`UseCase`) is not generated for MVVM projects.
- Theme, config, DI, logger, constants, and loading widget boilerplate on `init`.
- `architect.yaml` stores architecture, state management, Hive, GetIt, l10n, and flavors.

### Localization
- Optional l10n setup: `l10n.yaml`, `lib/l10n/*.arb`, pubspec patch, and `App` wiring.

### Flavors & environment
- `main_development.dart` / `main_staging.dart` / `main_production.dart`.
- `.env.*` reference files and `AppConfig.bootstrap(Environment)`.
- VS Code `launch.json` configurations per flavor.

### CI/CD
- GitHub Actions and/or Codemagic templates during `init`.
- Standalone command: `flutter_architect cicd [-p github|codemagic|both]`.

### Micro-generators
- `create screen <Name> --feature <feature>`
- `create widget <Name> [--feature <feature>]`
- `create datasource <Name> --feature <feature> [--local]`

### Bug fixes (pre-publish)
- Fixed `pubspec.yaml` localization patch (`replaceFirstMapped` for flutter_localizations).
- `NoParams` is now a const constructor (fixes BLoC `const NoParams()`).
- `create datasource` also scaffolds matching model + entity stubs.
- Removed unused import from feature DI templates.
- `--no-interaction` now applies full default configuration (for CI/smoke tests).

### Breaking changes
- Feature folder layout changed (`repository` → `repositories`, `datasource` → `datasources`).
- Generated models no longer extend entities.
- MVVM feature layout now includes `services/` and SM-specific folders.
- `SetupConfig` / `architect.yaml` gained new fields (localization, flavors).

Projects generated with **1.x** are not auto-migrated; re-run generators in a new app or adapt paths manually.

---

## 1.0.0

### Initial release

- Interactive `init` for Clean Architecture or MVVM.
- State management: BLoC, Riverpod, Provider, GetX, or None.
- Routing, networking, GetIt DI.
- Generators: feature, model, entity, repository, usecase, viewmodel.
- `--dry-run` and dependency install hints.
