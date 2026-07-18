# flutter_architect 🏗️

[![pub package](https://img.shields.io/pub/v/flutter_architect.svg)](https://pub.dev/packages/flutter_architect)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

**The Flutter starter kit you wish existed.**

Instead of spending two hours manually creating folders, writing generic entity classes, and wiring up Dio/GetIt every time you start a new project, `flutter_architect` generates a complete, production-ready Clean Architecture boilerplate in seconds.

## 🚀 Quick Start

Activate the CLI globally:
```bash
dart pub global activate flutter_architect
```

Go to your new Flutter project and initialize the architecture:
```bash
flutter create my_awesome_app
cd my_awesome_app

flutter_architect init
```

The CLI will launch an interactive menu. Use your arrow keys to select your preferred tech stack (State Management, Routing, Networking, Dependency Injection, etc.). 

![Interactive Menu Preview](https://raw.githubusercontent.com/huzaifamirza0/flutter_architect/main/doc/demo.gif) *(Add a gif here later!)*

---

## 🛠️ Commands

### `init`
Scaffolds the entire `lib/` directory using Clean Architecture principles (`app/`, `core/`, `features/`, `shared/`). Automatically generates networking clients, error handling, and wires your state management into `main.dart`.

```bash
flutter_architect init
```

### `create feature <name>`
Generates a complete, modular feature folder including `data`, `domain`, and `presentation` layers, and wires up the boilerplate for your chosen state management (BLoC, Riverpod, Provider, or GetX).

```bash
flutter_architect create feature booking --state-management bloc
```

### `create model <name>`
Scaffolds a Data Model with `fromJson`, `toJson`, `copyWith`, and `Equatable` automatically generated.

```bash
flutter_architect create model User --feature auth
```

### `create entity <name>`
Scaffolds a Domain Entity extending `Equatable`.

```bash
flutter_architect create entity User --feature auth
```

### `create repository <name>`
Generates an abstract Repository class and its implementation class, wired to return `Either<Failure, T>`.

```bash
flutter_architect create repository User --feature auth
```

### `create usecase <name>`
Scaffolds a UseCase implementing the Callable Class pattern with error handling.

```bash
flutter_architect create usecase Login --feature auth
```

---

## 🏗️ The Architecture

`flutter_architect` enforces a strict, scalable "Feature-First" Clean Architecture:

```text
lib/
├── app/               # App-level config, DI, Routing, Themes
├── core/              # Network clients, Base Classes, Errors, Utils
├── features/
│   ├── auth/          # Each feature is completely modular
│   │   ├── data/      # Models, Repositories, DataSources
│   │   ├── domain/    # Entities, UseCases, Repository Interfaces
│   │   └── presentation/ # UI, BLoCs/Controllers
│   └── booking/
├── shared/            # Reusable widgets and shared entities
└── main.dart          # Automatically wired with your state management
```

## 🤝 Contributing
We welcome contributions! Please open an issue or submit a pull request if you have ideas for new templates, state management options, or CLI improvements.

## 📄 License
This project is licensed under the MIT License.
