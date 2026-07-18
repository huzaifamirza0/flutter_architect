import 'package:flutter_architect/flutter_architect.dart';
import 'package:test/test.dart';

void main() {
  group('NameUtils', () {
    test('splits snake_case input', () {
      final n = NameUtils('user_profile');
      expect(n.snakeCase, 'user_profile');
      expect(n.pascalCase, 'UserProfile');
      expect(n.camelCase, 'userProfile');
      expect(n.kebabCase, 'user-profile');
      expect(n.titleCase, 'User Profile');
    });

    test('splits PascalCase input', () {
      final n = NameUtils('UserProfile');
      expect(n.snakeCase, 'user_profile');
      expect(n.pascalCase, 'UserProfile');
      expect(n.camelCase, 'userProfile');
    });

    test('splits camelCase input', () {
      final n = NameUtils('userProfile');
      expect(n.snakeCase, 'user_profile');
      expect(n.pascalCase, 'UserProfile');
    });

    test('splits kebab-case input', () {
      final n = NameUtils('user-profile');
      expect(n.snakeCase, 'user_profile');
      expect(n.pascalCase, 'UserProfile');
    });

    test('handles single word', () {
      final n = NameUtils('auth');
      expect(n.snakeCase, 'auth');
      expect(n.pascalCase, 'Auth');
      expect(n.camelCase, 'auth');
    });

    test('handles three-word name', () {
      final n = NameUtils('BookingHistory');
      expect(n.snakeCase, 'booking_history');
      expect(n.pascalCase, 'BookingHistory');
      expect(n.camelCase, 'bookingHistory');
      expect(n.kebabCase, 'booking-history');
      expect(n.titleCase, 'Booking History');
    });
  });
}
