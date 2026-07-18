## 1.0.0

### 🎉 Initial Release

The first production-ready release of `flutter_architect` — a CLI tool to instantly scaffold production-ready Flutter projects.

#### Features
- **Interactive `init` command** — Guided setup wizard to configure your entire project in seconds.
- **Dual Architecture Support:**
  - **Clean Architecture** — Full `data`, `domain`, and `presentation` layer scaffolding (Uncle Bob / Reso Coder style).
  - **MVVM** — Feature-first `models`, `viewmodels`, and `views` scaffolding.
- **State Management:** BLoC, Riverpod, Provider, GetX, or None.
- **Routing:** GoRouter, AutoRoute, Navigator 2.0, or Vanilla.
- **Networking:** REST (Dio), GraphQL, or Both.
- **Dependency Injection:** GetIt service locator setup.
- **`create feature`** — Scaffold a full feature module in one command.
- **`create model`** — Generate a Data Model with `fromJson`, `toJson`, `copyWith`.
- **`create entity`** — Generate a Domain Entity extending `Equatable`.
- **`create repository`** — Generate abstract + implementation Repository pair.
- **`create usecase`** — Generate a UseCase with the Callable Class pattern.
- **`create viewmodel`** — Generate a ViewModel + View pair (MVVM only).
- **Guard validation** — Prevents running `create` commands before `init`.
- **Smart dependency list** — Prints the exact `flutter pub add` command based on your choices.
- **`--dry-run` flag** — Preview folder structure without writing to disk.
