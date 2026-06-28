import 'package:ai4good/features/auth/domain/entities/app_user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AppUser uses value equality', () {
    const first = AppUser(
      id: 'user-1',
      email: 'person@example.com',
      isEmailVerified: true,
      displayName: 'Person',
    );
    const second = AppUser(
      id: 'user-1',
      email: 'person@example.com',
      isEmailVerified: true,
      displayName: 'Person',
    );

    expect(first, second);
  });
}
