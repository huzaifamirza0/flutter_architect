/// Utility class for converting a raw name into every casing variant
/// needed by code generators.
///
/// Example — input `"userProfile"`:
///   snakeCase   → `user_profile`
///   pascalCase  → `UserProfile`
///   camelCase   → `userProfile`
///   kebabCase   → `user-profile`
///   titleCase   → `User Profile`
class NameUtils {
  /// Creates casing helpers from [raw] (`snake_case`, `PascalCase`,
  /// `camelCase`, or `kebab-case`).
  NameUtils(String raw) : _words = _split(raw);

  final List<String> _words;

  /// `user_profile`
  String get snakeCase => _words.join('_').toLowerCase();

  /// `UserProfile`
  String get pascalCase => _words.map(_capitalize).join();

  /// `userProfile`
  String get camelCase {
    if (_words.isEmpty) return '';
    return _words.first.toLowerCase() +
        _words.skip(1).map(_capitalize).join();
  }

  /// `user-profile`
  String get kebabCase => _words.join('-').toLowerCase();

  /// `User Profile`
  String get titleCase => _words.map(_capitalize).join(' ');

  // ── helpers ──────────────────────────────────────────────────────

  static String _capitalize(String w) =>
      w.isEmpty ? w : w[0].toUpperCase() + w.substring(1).toLowerCase();

  /// Splits any of: `snake_case`, `PascalCase`, `camelCase`, `kebab-case`.
  static List<String> _split(String input) {
    // Insert underscores before uppercase letters that follow lowercase ones
    // (handles PascalCase / camelCase).
    final withUnderscores = input
        .replaceAllMapped(
          RegExp(r'([a-z])([A-Z])'),
          (m) => '${m[1]}_${m[2]}',
        )
        .replaceAll('-', '_'); // normalise kebab

    return withUnderscores
        .split('_')
        .where((w) => w.isNotEmpty)
        .toList();
  }
}
