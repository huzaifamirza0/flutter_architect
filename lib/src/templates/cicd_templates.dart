abstract class CicdTemplates {
  static const String githubActions = '''name: Flutter CI

on:
  push:
    branches: [main, master, develop]
  pull_request:
    branches: [main, master, develop]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true

      - name: Install dependencies
        run: flutter pub get

      - name: Check formatting
        run: dart format --set-exit-if-changed .

      - name: Analyze
        run: flutter analyze

      - name: Run tests
        run: flutter test

      - name: Build APK (debug)
        run: flutter build apk --debug
''';

  static const String githubActionsWithFlavors = '''name: Flutter CI

on:
  push:
    branches: [main, master, develop]
  pull_request:
    branches: [main, master, develop]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true

      - name: Install dependencies
        run: flutter pub get

      - name: Check formatting
        run: dart format --set-exit-if-changed .

      - name: Analyze
        run: flutter analyze

      - name: Run tests
        run: flutter test

      - name: Build APK (dev)
        run: flutter build apk --debug -t lib/main_development.dart
''';

  static const String codemagic = '''workflows:
  flutter-workflow:
    name: Flutter Workflow
    max_build_duration: 60
    instance_type: mac_mini_m1
    environment:
      flutter: stable
    scripts:
      - name: Get dependencies
        script: flutter pub get
      - name: Analyze
        script: flutter analyze
      - name: Test
        script: flutter test
      - name: Build Android APK
        script: flutter build apk --debug
    artifacts:
      - build/**/outputs/**/*.apk
''';

  static const String codemagicWithFlavors = '''workflows:
  flutter-workflow:
    name: Flutter Workflow
    max_build_duration: 60
    instance_type: mac_mini_m1
    environment:
      flutter: stable
    scripts:
      - name: Get dependencies
        script: flutter pub get
      - name: Analyze
        script: flutter analyze
      - name: Test
        script: flutter test
      - name: Build Android APK (dev)
        script: flutter build apk --debug -t lib/main_development.dart
    artifacts:
      - build/**/outputs/**/*.apk
''';
}
