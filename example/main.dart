/// Example: converting a feature name into casing variants used by generators.
///
/// Run from the package root:
/// ```bash
/// dart run example/main.dart
/// ```
library;

import 'package:flutter_architect/flutter_architect.dart';

void main() {
  final names = NameUtils('userProfile');

  print('Input:      userProfile');
  print('snakeCase: ${names.snakeCase}'); // user_profile
  print('pascalCase:${names.pascalCase}'); // UserProfile
  print('camelCase: ${names.camelCase}'); // userProfile
  print('kebabCase: ${names.kebabCase}'); // user-profile
  print('titleCase: ${names.titleCase}'); // User Profile

  // Typical generator paths derived from a feature name:
  final feature = NameUtils('booking');
  print('\nFeature folders:');
  print('  lib/features/${feature.snakeCase}/');
  print('  ${feature.pascalCase}Page / ${feature.pascalCase}Repository');
}
