# Contributing to flutter_architect

Thanks for helping improve `flutter_architect`! Contributions of all kinds are welcome — bug reports, docs, new generators, templates, and CLI UX.

## Ways to contribute

| Type | How |
|------|-----|
| Report a bug | [Open an issue](https://github.com/huzaifamirza0/flutter_architect/issues/new?template=bug_report.md) |
| Request a feature | [Open an issue](https://github.com/huzaifamirza0/flutter_architect/issues/new?template=feature_request.md) |
| Fix / improve code | Fork → branch → PR |
| Improve docs / examples | Same as code PRs |
| Share feedback | Discussions or issues |

Good first areas:

- New micro-generators (`create screen` style)
- Better templates (Firebase, GraphQL, Drift, etc.)
- Docs, examples, translations of README
- Tests for `NameUtils`, generators, or pubspec helpers
- `flutter_architect doctor` / project creator (`create my_app`)

## Development setup

```bash
git clone https://github.com/huzaifamirza0/flutter_architect.git
cd flutter_architect
dart pub get
```

Run the CLI from source:

```bash
dart run bin/flutter_architect.dart --help
dart pub global activate --source path .
```

Smoke-test against a Flutter app:

```bash
flutter create /tmp/fa_demo && cd /tmp/fa_demo
flutter_architect init --no-interaction
flutter_architect create screen Settings --feature auth
```

## Project layout

```text
bin/                 # CLI entrypoint
lib/src/
  commands/          # init, create/*, cicd
  generators/        # boilerplate writer
  templates/         # string templates for generated Dart
  prompts/           # interactive setup
  utils/             # NameUtils, ValidationUtils, PubspecUtils
example/             # pub.dev example + sample_app demo
test/                # unit tests
```

## Coding guidelines

- Match existing style (keep generators/templates consistent).
- Prefer small, focused PRs over huge refactors.
- Generated code should analyze cleanly in a real Flutter app.
- If you change templates, update `example/sample_app/` and/or docs when relevant.
- Add/update tests when fixing logic in `utils/` or shared helpers.
- Run before opening a PR:

```bash
dart analyze
dart test
dart format .
```

## Pull request process

1. Create a branch: `fix/...`, `feat/...`, or `docs/...`
2. Describe **what** and **why** in the PR (not only what files changed)
3. Link related issues
4. Include a short test plan (commands you ran)
5. Keep the PR focused — one feature or fix per PR when possible

Maintainers may ask for changes; that’s normal. Once approved, we’ll merge.

## Issue guidelines

**Bugs** — include:

- `flutter_architect` version (`dart pub global list`)
- Dart / Flutter versions
- Steps to reproduce
- Expected vs actual behavior
- Architecture chosen (Clean / MVVM) if relevant

**Features** — include:

- Problem you’re solving
- Proposed CLI UX (commands / flags)
- Whether it belongs in `init`, `create`, or a new command

## Code of conduct

Be respectful and constructive. Harassment or bad-faith behavior is not welcome. See [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

## License

By contributing, you agree that your contributions are licensed under the same [MIT License](LICENSE) as the project.

---

Questions? Open an issue — we’re happy to help you get started.
